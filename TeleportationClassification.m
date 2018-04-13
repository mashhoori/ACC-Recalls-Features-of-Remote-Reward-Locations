

clear
folderNames = {'P1353_15p', 'P1353_16p', 'P1353_17p', 'P1353_18p', 'P1958_24p', 'P1958_25p', 'P1958_27p'};
outputNames = {'thN15p75_50', 'thN16p75_50', 'thN17p75_50', 'thN18p75_50', 'thN24p75_50', 'thN25p75_50', 'thN27p75_50'};


AUC = {};

for rat = 1:5 %numel(folderNames)
    
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

%AUC = zeros(4, 10);

for i = 1:10 
    
    sel = ismember(trial, RD.tr_c{i});
    validData = binData(:, sel);    
    validTrial = trial(sel);
    validChoice = choiceSel(sel);
     
    choiceTel = [];
    telData = [];
    for j = 1:numel(RD.middleMarker{i}) - 1
        indices = RD.middleMarker{i}(j)-3 : min(length(validData), RD.middleMarker{i}(j)+3 );
        telData = [telData mean(validData(:, indices), 2)];
        choiceTel = [choiceTel  validChoice(min(length(validData), RD.middleMarker{i}(j)))];
    end    
            
%     cnt = 1;
%     choiceNotTel = [];
%     notTelData = [];
%     notTelTrials = setdiff(RD.tr_c{i}, RD.tr{i});    
%     for j = 1:numel(notTelTrials) 
%         indices = find(validTrial == notTelTrials(j));        
% %         slice = mod(RD.middleMarker{i}(cnt)-3:   min(length(validData), RD.middleMarker{i}(cnt)+3   ), 75);
% %         slice(slice == 0) = 75;        
% %         indices = indices(slice);        
%         notTelData = [notTelData mean(validData(:, indices), 2)];
%         choiceNotTel = [choiceNotTel choice(notTelTrials(j)) ];
%         
%         cnt = mod((cnt+1), numel(RD.middleMarker{i}) );          
%         if(cnt == 0)
%             cnt =  numel(RD.middleMarker{i});
%         end
%     end    
        
%     telData_0 = telData(:, choiceTel == 0 );
%     telData_1 = telData(:, choiceTel == 1 );    
%     nTelData_0 = notTelData(:, choiceNotTel == 0 );
%     nTelData_1 = notTelData(:, choiceNotTel == 1 );
%     
%     allData = [telData_1 nTelData_1];
%     label = [ones(1, size(telData_1, 2)) zeros(1, size(nTelData_1, 2))];        
%     Tataritutu{1} = [allData; label];     
%     
%     allData = [telData_0 nTelData_0];
%     label = [ones(1, size(telData_0, 2)) zeros(1, size(nTelData_0, 2))];        
%     Tataritutu{2} = [allData; label]; 
%     
%     allData = [telData_0 nTelData_1];
%     label = [ones(1, size(telData_0, 2)) zeros(1, size(nTelData_1, 2))];        
%     Tataritutu{3} = [allData; label]; 
    
%     allData = [telData_1 nTelData_0];
%     label = [ones(1, size(telData_1, 2)) zeros(1, size(nTelData_0, 2))];        
%     Tataritutu{4} = [allData; label]; 
        

% 
%     for jfk = 1:2       
%         [trainedClassifier, validationAccuracy, validationScores] = trainClassifierSVM(Tataritutu{jfk});
%         [~,~,~,AUC{jfk, i}] = perfcurve( Tataritutu{jfk}(end, :), validationScores(:, 2) , 1, 'NBoot', 100);        
%     end        

    
    allData = telData;
    label = choiceTel;
    
    
    
%     allChoice = [choiceTel choiceNotTel];
%     allData = [telData notTelData];
     
% %   choiceTel = choiceTel(randperm(numel(choiceTel)));
     
%     Tataritutu = [telData; choiceTel];          
%     label = [ones(1, size(telData, 2)) zeros(1, size(notTelData, 2))];    
%     label = label(randperm(numel(label)));
     
     
     Tataritutu = [allData; label];  
%     Tataritutu = Tataritutu(:, allChoice == 0); 
%    Tataritutu = Tataritutu(:, allChoice == 1); ; 
    

     [trainedClassifier, validationAccuracy, validationScores] = trainClassifierSVM(Tataritutu);
     [~,~,~,AUC{rat, i}] = perfcurve( Tataritutu(end, :), validationScores(:, 2) , 1, 'NBoot', 100);
    
%     AUC(i)    
%     numel(choiceTel)
    
end 

% AUC
%mean(AUC, 2)

end






%   0.8756  0.8531  0.6937   0.5681
%   0.9048  0.9713  0.9910   0.9525


% mean([0.7313 0.7727 0.6983 0.8809 0.6835])


 % 0.9931 0.9453 0.9384 0.9047 0.9371 0.9765
 % 0.9752 0.9759 0.8317 0.9737 0.9429 0.8432

%  0.9668  0.9565  0.9454   0.9738 0.9593 0.8559  0.7942
%  0.9255  0.9749  0.9760   0.9464 0.9852 0.9583  0.8858


%  0.6446  0.7409  0.7400  0.6695  0.5768  0.5465  0.5090
%  0.6577  0.7463  0.5949  0.7338  0.6558  0.6182  
%  0.6127  0.8278 0.7545 0.7743 0.7238 0.6803

