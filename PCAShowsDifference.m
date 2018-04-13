

clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));

%%

folderNames = {'P1353_15p', 'P1353_16p', 'P1353_17p', 'P1353_18p', 'P1958_24p', 'P1958_25p', 'P1958_27p'};
outputNames = {'thN15p75_50', 'thN16p75_50', 'thN17p75_50', 'thN18p75_50', 'thN24p75_50', 'thN25p75_50', 'thN27p75_50'};

for rat = 2:2%numel(folderNames)

fprintf('rat %d \n ', rat);
folderPath = ['E:\New folder\' folderNames{rat} '\']; 

data = CreateAllData(folderPath, []);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 120, 1);
%%
[timestamps, binData, binLoc, trial] = BinData(data, 20, 0);
choice = [data.trInfo.choice];
ramp   = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sideOff    = [data.trInfo.SideOff];
centerOff  = [data.trInfo.centralOff];

binLoc = MapToRect(binLoc, trial, data);
plot(binLoc(1, :), binLoc(2, :), '.');

choiceOne  = data.trials(choice(data.trials) == 1);
choiceZero = data.trials(choice(data.trials) == 0 );
minNum     = min(numel(choiceOne), numel(choiceZero));

AllTrials = [choiceOne choiceZero];


selectedOne  = randsample(choiceOne , floor(minNum * .70));
selectedZero = randsample(choiceZero, floor(minNum * .70));

feederCode = zeros(1, length(timestamps));
selectedTrials = [selectedZero selectedOne];
selector = false(1, length(timestamps));
for tt = 1:numel(selectedTrials)
    sideInd = timestamps > sideOff(selectedTrials(tt)) & timestamps <= (sideOff(selectedTrials(tt)) + 20*75);
    centerInd = (timestamps > centerOff(selectedTrials(tt)) & timestamps <= (centerOff(selectedTrials(tt)) + 8*75));
    ind = sideInd | centerInd;
    if choice(selectedTrials(tt)) == 0
        feederCode(sideInd) = 1;
    else
        feederCode(sideInd) = 2;
    end
    feederCode(centerInd) = 3;
    selector(ind) = true;
end
feederCode(feederCode == 0) = [];


% freeChoiceTrials   = find(freeChoice);
% forcedChoiceTrials = find(freeChoice == 0);

trainIndices =  ~selector;%& ismember(trial, selectedTrials )
testIndices  =  selector;

train = binData(:, trainIndices);
loc_t = binLoc (:, trainIndices);
trIndex_t = trial(trainIndices);

valid = binData(:, testIndices);
loc_v = binLoc(:, testIndices) ;
trIndex_v = trial(testIndices) ;
timestamp_v = timestamps(testIndices);

% Animate(loc_v(:, error<0.25), resNew(:, error<0.25), 0.005, [-3 3 -3 3], 0, trIndex_v, data.trInfo, []);

save('data', 'train', 'loc_t', 'valid', 'loc_v');
system('python E:\Proj\Scripts\main.py True ./modelWeights');
a = load('data_out');
resValid = a.resValid{end}';

marker = MarkReplay3(loc_v, resValid, trIndex_v);
% 
startIdx = find(marker == 1);
endIdx   = find(marker == 2);

error = sqrt(sum((resValid - loc_v) .^ 2, 1));

good = error < 0.15;

bad = zeros(1, numel(good));
for iii = 1:numel(startIdx)
    bad(startIdx(iii):endIdx(iii)) = 1;   
end

% bad  = error > 0.35;


% 
% validTrial = unique(trIndex_v);
% 
% data = [];
% label = [];
% 
% for i = 1:numel(validTrial)    
%    tr = validTrial(i);
%    errorTrial = error(trIndex_v == tr);
%    dataTrail = a.resValid{1}(trIndex_v == tr, :)';   
%    
%    [erMax, indMax] = max(errorTrial);
%    [erMin, indMin] = min(errorTrial);
%    
%    if(choice(tr) == 1)
%        if(erMax > 0.7)       
%            sample = dataTrail(:, indMax);  
%             label = [label 0];
%             data = [data sample];
%        elseif(erMax < 0.2)
%            sample = dataTrail(:, indMin);  
%             label = [label 1];
%             data = [data sample];
%        end
%    end      
% end
% finalData = [data; label];
% 
% 
% goodData = valid(:, good);
% badData = valid(:, bad);
% 
% goodLabel = zeros(1, length(goodData));
% badLabel = ones(1, length(badData));
% 
% FinalGood = [goodData; goodLabel];
% FinalBad  = [badData; badLabel];
% 
% FinalData = [FinalGood FinalBad];
% FinalData = FinalData(:, randperm(length(FinalData)));


colorArr = {[.80, 0.88, .97], [0.94, 0.87, 0.87], [.84 .91 .85] };
colorArr_2 = {[0.31, 0.40, 0.58], [0.42, 0.25, 0.39], [.11 .31 .21] };


figure 
resValid = a.resValid;
for i = 1:numel(resValid)    
    subplot(3,2,i)
    hold on
    [coeff,score,latent] = pca(resValid{i});    
    for fc = 1:3        
        %plot(score(feederCode == fc & error < 0.25, 1), score(feederCode == fc & error < 0.25, 2), '.', 'Color', colorArr{fc}  )
        plot(score(feederCode == fc & good, 1), score(feederCode == fc & good, 2), '.', 'Color', colorArr{fc}  )
    end
    for fc = 1:3
        %plot(score(feederCode == fc & error > 2.3, 1), score(feederCode == fc & error > 2.3, 2), '+', 'Color',  colorArr_2{fc} ,'MarkerSize', 8, 'LineWidth', 1)
        plot(score(feederCode == fc & bad, 1), score(feederCode == fc & bad, 2), '+', 'Color',  colorArr_2{fc} ,'MarkerSize', 8, 'LineWidth', 1)
    end
    
    axis equal
    set(gca, 'XTickLabel', [])
    set(gca, 'YTickLabel', [])
    set(gca, 'XTick', [])
    set(gca, 'YTick', [])
    set(gca, 'Box', 'on')
end

% figure
% resValid = a.resValid;
% for i = 1:numel(resValid)    
%     subplot(3,2,i)
%     [coeff,score,latent] = pca(resValid{i});    
%     for fc = 1:3
%         hold on  
%         plot(score(feederCode == fc & error < 0.25, 1), score(feederCode == fc & error < 0.25, 2), '.')
% 
%     end
%     axis equal
% end

end

return;
