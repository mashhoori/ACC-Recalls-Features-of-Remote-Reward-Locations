
clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));

%%

folderNames = {'P1353_15p', 'P1353_16p', 'P1353_17p', 'P1353_18p', 'P1958_24p', 'P1958_25p', 'P1958_27p'};
outputNames = {'thN15p75_50', 'thN16p75_50', 'thN17p75_50', 'thN18p75_50', 'thN24p75_50', 'thN25p75_50', 'thN27p75_50'};

accuracy_All = [];
auc_ALL = [];
CM_ALL = [];
accuracy_s_ALL = [];
auc_s_ALL = [];
CM_s_ALL = [];
accuracy_n_ALL = [];
auc_n_ALL = [];
CM_n_ALL = [];

for rat = 1:numel(folderNames)

fprintf('rat %d \n ', rat);
folderPath = ['E:\New folder\' folderNames{rat} '\']; 

data = CreateAllData(folderPath, []);

choice = [data.trInfo.choice];
ramp   = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sideOff    = [data.trInfo.SideOff];
centerOff  = [data.trInfo.centralOff];


%%
timestamps = data.data(data.timeIndex, :);
dataShuffled = data;
selectedTrials = data.trials;
selector = false(1, length(timestamps));
for tt = 1:numel(selectedTrials)
    ind = timestamps > sideOff(selectedTrials(tt)) & timestamps <= (sideOff(selectedTrials(tt)) + 20*75);
    ind2 = timestamps > centerOff(selectedTrials(tt)) & timestamps <= (centerOff(selectedTrials(tt)) + 10*75);
    selector(ind | ind2 ) = true;
end

dataShuffled.data(data.dataIndex, :) = ShuffleSpikes(dataShuffled.data(dataShuffled.dataIndex, :), selector);
dataShuffled.data(data.dataIndex, :) = smoother(dataShuffled.data(data.dataIndex, :), 120, 1);
[~, binDataShuffled, ~, ~] = BinData(dataShuffled, 20, 0);

%%

dataNoisy = data;
selectedTrials = data.trials;
selectorCenter = false(1, length(timestamps));
selectorSide_0 = false(1, length(timestamps));
selectorSide_1 = false(1, length(timestamps));

for tt = 1:numel(selectedTrials)
    ind = timestamps > sideOff(selectedTrials(tt)) & timestamps <= (sideOff(selectedTrials(tt)) + 20*75);
    selectorCenter = selectorCenter | timestamps > centerOff(selectedTrials(tt)) & timestamps <= (centerOff(selectedTrials(tt)) + 10*75);
    selectorSide_0 = selectorSide_0 | (ind & choice(selectedTrials(tt)) == 0);
    selectorSide_1 = selectorSide_1 | (ind & choice(selectedTrials(tt)) == 1);        
end
dataNoisy.data(dataNoisy.dataIndex, :) = AddNoiseToSpikes(dataNoisy.data(dataNoisy.dataIndex, :), selectorCenter, 0.25);
dataNoisy.data(dataNoisy.dataIndex, :) = AddNoiseToSpikes(dataNoisy.data(dataNoisy.dataIndex, :), selectorSide_0, 0.25);
dataNoisy.data(dataNoisy.dataIndex, :) = AddNoiseToSpikes(dataNoisy.data(dataNoisy.dataIndex, :), selectorSide_1, 0.25);

dataNoisy.data(data.dataIndex, :) = smoother(dataNoisy.data(data.dataIndex, :), 120, 1);
[~, binDataNoisy, ~, ~] = BinData(dataNoisy, 20, 0);


%%
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 120, 1);
[timestamps, binData, binLoc, trial] = BinData(data, 20, 0);

%%

choiceOne  = data.trials(choice(data.trials) == 1);
choiceZero = data.trials(choice(data.trials) == 0);

AllTrials = [choiceOne choiceZero];

feederCode = zeros(1, length(timestamps));
selector = false(1, length(timestamps));
for tt = 1:numel(selectedTrials)
  
    sideInd = timestamps > sideOff(selectedTrials(tt)) & timestamps <= (sideOff(selectedTrials(tt)) + 20*75);
    centerInd = (timestamps > centerOff(selectedTrials(tt)) & timestamps <= (centerOff(selectedTrials(tt)) + 10*75));

    if choice(selectedTrials(tt)) == 0
        feederCode(sideInd) = 1;
    else
        feederCode(sideInd) = 2;
    end
      feederCode(centerInd) = 3;
    selector(sideInd | centerInd) = true;   
 
end

allData = binData(:, selector);
alltrials = trial(:, selector);
allfeederCode = feederCode(selector);

allDataShuffled =  binDataShuffled(:, selector);
allDataNoisy =  binDataNoisy(:, selector);

minNum     = min(numel(choiceOne), numel(choiceZero));


accuracy = [];
auc = [];
accuracy_s = [];
auc_s = [];
CM = [];
CM_s = [];

for hhh = 1:10

%%    
    
hhh
   
selectedOne  = randsample(choiceOne , floor(minNum * .50));
selectedZero = randsample(choiceZero, floor(minNum * .50));
selectedTrials = [selectedZero selectedOne];

trainIndices =  ismember(alltrials, selectedTrials );
testIndices  =  ~trainIndices;

train = allData(:, trainIndices);
train_target = allfeederCode(:, trainIndices);
train_trial = alltrials(trainIndices);

valid = allData(:, testIndices);
test_target = allfeederCode(:, testIndices);
test_trial = alltrials(testIndices);

% temp = templateTree(  ... 
%     'SplitCriterion', 'deviance', ...
%     'MaxNumSplits', 10, ...
%     'Surrogate', 'off', ...
%     'ClassNames', [1; 2; 3]);
% Mdl  = fitctree(...
%     train', ...
%     train_target', ...
%     'SplitCriterion', 'gdi', ...
%     'MaxNumSplits', 20, ...
%     'Surrogate', 'off', ...
%     'ClassNames', [1; 2; 3]);
% Mdl = fitctree(train',train_target','MinLeafSize', 5);
temp = templateSVM('Standardize',1);

Mdl = fitcecoc(train',train_target', 'Learners',temp, 'FitPosterior',1, 'verbose', 2);
[predicted, scores]= predict(Mdl , valid');

C = confusionmat(test_target(:), predicted);
C = bsxfun(@rdivide, C, sum(C, 2));

CM{hhh} = C;

for i = 1:3
    [~,~,~,auc{hhh}(i)] = perfcurve( test_target(:),scores(:, i), i);
    accuracy(hhh) = mean(predicted(:) == test_target(:));
end

fprintf('acc:  %0.2f, auc:  %0.2f \n', accuracy(hhh), mean(auc{hhh}));

%%

train = allDataShuffled(:, trainIndices);
train_target = allfeederCode(:, trainIndices);

valid = allDataShuffled(:, testIndices);
test_target = allfeederCode(:, testIndices);

[predicted, scores] = predict(Mdl , valid');

C_s = confusionmat(test_target(:), predicted);
C_s = bsxfun(@rdivide, C_s, sum(C_s, 2));

CM_s{hhh} = C_s;

for i = 1:3
    [~,~,~,auc_s{hhh}(i)] = perfcurve( test_target(:), scores(:, i), i);
    accuracy_s(hhh) = mean(predicted(:) == test_target(:));
end

fprintf('acc_s:  %0.2f, auc_s:  %0.2f \n', accuracy_s(hhh), mean(auc_s{hhh}));

%%

train = allDataNoisy(:, trainIndices);
train_target = allfeederCode(:, trainIndices);

valid = allDataNoisy(:, testIndices);
test_target = allfeederCode(:, testIndices);

[predicted, scores] = predict(Mdl , valid');

C_n = confusionmat(test_target(:), predicted);
C_n = bsxfun(@rdivide, C_n, sum(C_n, 2));

CM_n{hhh} = C_n;

for i = 1:3
    [~,~,~,auc_n{hhh}(i)] = perfcurve( test_target(:), scores(:, i), i);
    accuracy_n(hhh) = mean(predicted(:) == test_target(:));
end

fprintf('acc_n:  %0.2f, auc_n:  %0.2f \n', accuracy_n(hhh), mean(auc_n{hhh}));

end

CM_ALL{rat} = CM;
accuracy_All{rat} = accuracy;
auc_ALL{rat} = auc;

accuracy_s_ALL{rat} = accuracy_s;
auc_s_ALL{rat} = auc_s;
CM_s_ALL{rat} = CM_s;

accuracy_n_ALL{rat} = accuracy_n;
auc_n_ALL{rat} = auc_n;
CM_n_ALL{rat} = CM_n;

end

save('FeederClassification_5', 'accuracy_All', 'auc_ALL', 'CM_ALL', 'accuracy_s_ALL', 'auc_s_ALL', 'CM_s_ALL', 'accuracy_n_ALL', 'auc_n_ALL', 'CM_n_ALL')
