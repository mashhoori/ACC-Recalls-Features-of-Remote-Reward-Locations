
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
sideOff    = [data.trInfo.SideOff];
binLoc = MapToRect(binLoc, trial, data);


choiceOne  = data.trials(choice(data.trials) == 1);
choiceZero = data.trials(choice(data.trials) == 0 );
minNum     = min(numel(choiceOne), numel(choiceZero));
AllTrials = [choiceOne choiceZero];


selectedOne  = randsample(choiceOne , floor(minNum * .50));
selectedZero = randsample(choiceZero, floor(minNum * .50));
selectedTrials = [selectedZero selectedOne];


selector = false(1, length(timestamps));
for tt = 1:numel(AllTrials)
    sideInd = timestamps > sideOff(AllTrials(tt)) & timestamps <= (sideOff(AllTrials(tt)) + 20*75);
    selector(sideInd) = true;
end
netSelector = selector & ismember(trial, selectedTrials );

svmTrainSelector = selector & ~ismember(trial, selectedTrials );
svmTestSelector  = selector &  ismember(trial, selectedTrials );

svmTrainData = binData(:, svmTrainSelector);
svmTrainTarget  = choice(trial(svmTrainSelector));
svmTestData = binData(:, svmTestSelector);
svmTestTarget  = choice(trial(svmTestSelector));
svmTestTrials = trial(svmTestSelector);

SVMModel = fitcsvm(svmTrainData', svmTrainTarget', 'Standardize', true, 'BoxConstraint', 1);
[predicted, scores]= predict(SVMModel, svmTestData');
[~, ~, ~, auc] = perfcurve( svmTestTarget(:), scores(:, 1), 0);

thingyTrials_SVM = unique(svmTestTrials(svmTestTarget(:) ~= predicted));


%%


trainIndices =  ~netSelector ;
testIndices  =  netSelector;

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

%%
marker = MarkReplay3(loc_v, resValid, trIndex_v);
 
startIdx = find(marker == 1);
endIdx   = find(marker == 2);

thingyTrials_Net = unique(trIndex_v(startIdx)); 
%%







end

return;
