

clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));

%%

folderNames = {'P1353_15p', 'P1353_16p', 'P1353_17p', 'P1353_18p', 'P1958_24p', 'P1958_25p', 'P1958_27p'};
outputNames = {'thN15p75_50', 'thN16p75_50', 'thN17p75_50', 'thN18p75_50', 'thN24p75_50', 'thN25p75_50', 'thN27p75_50'};

nonFavSide = [0 1 0 1 0 0 0];

for rat = 6:6%numel(folderNames)

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


AUC = [];
ValACC = [];

for iter = 1:6

selectedOne  = randsample(choiceOne , floor(minNum * .50));
selectedZero = randsample(choiceZero, floor(minNum * .50));

feederCode = zeros(1, length(timestamps));
selectedTrials = [selectedZero selectedOne];
selector = false(1, length(timestamps));
for tt = 1:numel(selectedTrials)
    sideInd = timestamps > sideOff(selectedTrials(tt)) & timestamps <= (sideOff(selectedTrials(tt)) + 20*75);        
    selector(sideInd) = true;
end

trainIndices =  ~selector ;
testIndices  =  selector;

train = binData(:, trainIndices);
loc_t = binLoc (:, trainIndices);
trIndex_t = trial(trainIndices);

valid = binData(:, testIndices);
loc_v = binLoc(:, testIndices) ;
trIndex_v = trial(testIndices) ;
timestamp_v = timestamps(testIndices);


save('data', 'train', 'loc_t', 'valid', 'loc_v');
system('python E:\Proj\Scripts\main.py True ./modelWeights');
a = load('data_out');
resValid = a.resValid{end}';

marker = MarkReplay3(loc_v, resValid, trIndex_v);
% 
startIdx = find(marker == 1);
endIdx   = find(marker == 2);

ThingyTrials = unique(trIndex_v(startIdx)); 

%

error = sqrt(sum((resValid - loc_v) .^ 2, 1));


validTrial = unique(trIndex_v);

data = [];
label = [];

for i = 1:numel(validTrial)    
   tr = validTrial(i);
   errorTrial = error(trIndex_v == tr);
   dataTrial = a.resValid{1}(trIndex_v == tr, :)';   
   
   [erMax, indMax] = max(errorTrial);
   [erMin, indMin] = min(errorTrial);
   
   if(choice(tr) == nonFavSide(rat))
       if( ismember(tr, ThingyTrials))
           sample = mean(dataTrial(:, max(indMax-3, 1):min(indMax+3, size(dataTrial, 2))), 2);  
            label = [label 0];
            data = [data sample];
       else
           sample = mean(dataTrial(:, max(indMin-3, 1): min(indMin+3, size(dataTrial, 2))), 2);  
           label = [label 1];
           data = [data sample];
       end
   end      
end
finalData = [data; label];

[trainedClassifier, validationAccuracy, validationScores] = trainClassifierSVM(finalData);
[~, ~, ~, auc] = perfcurve(label, validationScores(:, 2) , 1);
AUC(iter) = auc; 
ValACC(iter) = validationAccuracy;

end

% [predicted, scores]= predict(SVMModel, valid');
% [~,~,~,auc(hhh)] = perfcurve( test_target(:),scores(:, 1), 1);

end

return;
