

clear
folderNames = {'P1353_15p', 'P1353_16p', 'P1353_17p', 'P1353_18p', 'P1958_24p', 'P1958_25p', 'P1958_27p'};
outputNames = {'thN15p75_50', 'thN16p75_50', 'thN17p75_50', 'thN18p75_50', 'thN24p75_50', 'thN25p75_50', 'thN27p75_50'};

for rat = 1:6 
    
fprintf('rat %d \n ', rat);
folderPath = ['E:\New folder\' folderNames{rat} '\']; 

data = CreateAllData(folderPath, []);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 120, 1);
[timestamps, binData, binLoc, trial] = BinData(data, 20, 0);

choice = [data.trInfo.choice];
ramp   = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sideOff    = [data.trInfo.SideOff];
centerOff  = [data.trInfo.centralOff];

selector = false(1, length(timestamps));
for tt = 1:numel(sideOff)
    ind = timestamps > sideOff(tt) & timestamps <= (sideOff(tt) + 20*75);
    selector(ind) = true;
end

timestamps = timestamps(selector);
binData    = binData(:, selector);
trial      = trial(selector);
choiceSel     = choice(trial);

load(outputNames{rat});


count = zeros(1, max(data.trials));
for i = 1:10 
    ggg = RD.tr{i};
    count(ggg) = count(ggg) +  1;
end   
badTrails = find(count >= 5);


selectedTrial = [];
choiceTel = [];
telData = [];

for i = 1:10 
    
    sel = ismember(trial, RD.tr_c{i});
    validData = binData(:, sel);    
    validTrial = trial(sel);
    validChoice = choiceSel(sel);     
    
    for j = 1:numel(RD.middleMarker{i}) - 1
        
        if(ismember(RD.tr{i}(j), badTrails) && ~ismember(RD.tr{i}(j), selectedTrial)) 
            
            selectedTrial = [selectedTrial RD.tr{i}(j)];
            
            indices = RD.middleMarker{i}(j)-3 : min(length(validData), RD.middleMarker{i}(j)+3 );
            telData = [telData mean(validData(:, indices), 2)];
            choiceTel = [choiceTel  choice(RD.tr{i}(j))];        
            %choiceTel = [choiceTel  validChoice(min(length(validData), RD.middleMarker{i}(j)))];        
        end
    end            
       
end    
    
    
Tataritutu = [telData; choiceTel]; 
[trainedClassifier, validationAccuracy, validationScores] = trainClassifierSVM(Tataritutu);
[~,~,~,AUC] = perfcurve( Tataritutu(end, :), validationScores(:, 2) , 1);

%     AUC(i)       
%     numel(choiceTel)
% end 

mean(AUC)


end


% mean([0.7313 0.7727 0.6983 0.8809 0.6835])



%  0.9668  0.9565  0.9454   0.9738 0.9593 0.8559  0.7942
%  0.9255  0.9749  0.9760   0.9464 0.9852 0.9583  0.8858


%  0.6446  0.7409  0.7400  0.6695  0.5768  0.5465  0.5090
%  0.6577  0.7463  0.5949  0.7338  0.6558  0.6182  
%  0.6127  0.8278 0.7545 0.7743 0.7238 0.6803

