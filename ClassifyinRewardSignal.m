clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));

%%
% folderPath = 'E:\New folder\P1958_25p\';

folderNames = {'P1353_15p', 'P1353_16p', 'P1353_17p', 'P1353_18p', 'P1958_24p', 'P1958_25p', 'P1958_27p'};
% outputNames = {'thN15p100', 'thN16p100', 'thN17p100', 'thN18p100', 'thN24p100', 'thN25p100', 'thN27p100'};
% outputNames = {'thN15p75', 'thN16p75', 'thN17p75', 'thN18p75', 'thN24p75', 'thN25p75', 'thN27p75'};
outputNames = {'thN15p75_50', 'thN16p75_50', 'thN17p75_50', 'thN18p75_50', 'thN24p75_50', 'thN25p75_50', 'thN27p75_50'};

for rat = 1:numel(folderNames)

fprintf('rat %d \n ', rat);
folderPath = ['E:\New folder\' folderNames{rat} '\']; 

data = CreateAllData(folderPath, []);
% dorg = data.data(data.dataIndex, :);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 120, 1);
%%
[timestamps, binData, binLoc, trial] = BinData(data, 20, 0)   ;
choice = [data.trInfo.choice];
ramp   = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sideOff    = [data.trInfo.SideOff];
centerOff  = [data.trInfo.centralOff];

binLoc = MapToRect(binLoc, trial, data);

plot(binLoc(1, :), binLoc(2, :), '.');

choiceOneLow  = data.trials(choice(data.trials) == 1 & reward(data.trials) == 0 & freeChoice(data.trials) == 0);
choiceZeroLow = data.trials(choice(data.trials) == 0 & reward(data.trials) == 0 & freeChoice(data.trials) == 0);

choiceOneHigh  = data.trials(choice(data.trials) == 1 & reward(data.trials) == 1 & freeChoice(data.trials) == 0);
choiceZeroHigh = data.trials(choice(data.trials) == 0 & reward(data.trials) == 1 & freeChoice(data.trials) == 0);

minNumLow     = min(numel(choiceOneLow), numel(choiceZeroLow));
minNumHigh    = min(numel(choiceOneHigh), numel(choiceZeroHigh));

minNum = min(minNumLow, minNumHigh);

ooo = [];
jjj = [];
kkk = [];

for hhh = 1:5


   
selectedOneLow  = randsample(choiceOneLow , minNum);
selectedZeroLow = randsample(choiceZeroLow, minNum);
selectedOneHigh  = randsample(choiceOneHigh , minNum);
selectedZeroHigh = randsample(choiceZeroHigh, minNum);

selectedTrials = [selectedZeroLow selectedOneLow selectedZeroHigh selectedOneHigh];


rewardArray = zeros(1, length(timestamps));
selector = false(1, length(timestamps));
for tt = 1:numel(sideOff)
    ind = timestamps > sideOff(tt) & timestamps <= (sideOff(tt) + 20*75);
    selector(ind) = true;
    rewardArray(ind) = reward(tt) + 1;
end

selectedIndices = ismember(trial, selectedTrials);


r = rand(size(selectedTrials));
included = r <= 0.7;
excluded = r >  0.7;

trainIndices = selector & ismember(trial, selectedTrials(included));
testIndices  = selector & ismember(trial, selectedTrials(excluded));

train = binData(:, trainIndices);
loc_t = binLoc (:, trainIndices);
reward_t = rewardArray(trainIndices);

indices = randperm(length(loc_t));
train = train(:, indices);
loc_t = loc_t(:, indices);
reward_t = reward_t(indices);

valid = binData(:, testIndices);
loc_v = binLoc(:, testIndices) ;
reward_v = rewardArray(testIndices);


SVMStruct = fitcsvm(train', reward_t', 'KernelFunction', 'polynomial', 'PolynomialOrder', 2);
preds = predict(SVMStruct, valid');


mean(preds(:) == reward_v(:))



end

% save(outputNames{rat}, 'tr', 'tr_c', 'sig0', 'sig1', 'loc_val', 'pred_val', 'ooo', 'jjj', 'kkk');
end

return;
