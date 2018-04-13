
clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));
%%

SessionNum = {'26', '28', '37', '41', '38', '39', '43', '44'};
folderNames = {'P1068_26p', 'P1068_28p', 'P1068_37p', 'P1068_41p', 'R0935_38p', 'R0935_39p', 'R0935_43p', 'R0935_44p'};

for rat = numel(folderNames):numel(folderNames)

folderPath = ['E:\New folder\' folderNames{rat} '\']; 

data = CreateAllData(folderPath, []);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 150, 1);
choice = [data.trInfo.choice];
ramp = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sfc = [data.trInfo.SideOff];
%%
[timestamps, binData, binLoc, trial] = BinData(data, 50, 0);
binLoc = MapToRect(binLoc, trial, data);
plot(binLoc(1, :), binLoc(2, :), '.');

%%
gridWith = [0.1 0.1];
[code, codeMap, gridDim] = GridLocations(binLoc, gridWith);

%%
posTrial = data.trials(choice(data.trials) == 1);
negTrial = data.trials(choice(data.trials) == 0);
minNum = min(numel(posTrial), numel(negTrial));

for it = 1:10

selectedPos = randsample(posTrial, minNum);
selectedNeg = randsample(negTrial, minNum);

AllSelected = [selectedPos selectedNeg];

r = rand(1, numel(AllSelected));
trainTrials = AllSelected(r <= 0.75);
testTrials  = AllSelected(r >  0.75);

ComputeStatistics(trainTrials, choice, reward, ramp, freeChoice);
ComputeStatistics(testTrials, choice, reward, ramp, freeChoice);

trainIndices = ismember(trial, trainTrials);
testIndices  = ismember(trial, testTrials);

train = binData(:, trainIndices);
loc_t = binLoc(:, trainIndices);
code_t = code(trainIndices);

indices = randperm(length(loc_t));
train = train(:, indices);
loc_t = loc_t(:, indices);
code_t = code_t(indices);

valid = binData(:, testIndices);
loc_v = binLoc(:, testIndices);
code_v = code(testIndices);

trial_t = trial(trainIndices);
trial_v = trial(testIndices);

timestamps_t = timestamps(trainIndices);
timestamps_v = timestamps(testIndices);

%%

save('data', 'train', 'loc_t', 'valid', 'loc_v');
system('python C:\Users\a.mashhoori\Desktop\Proj\Scripts\main.py');
a = load('data_out');
res = a.res';
res2 = a.res2';


A(it).pred_v = res;
A(it).real_v = loc_v;
A(it).code_v = code_v;
A(it).trial_v = trial_v;

A(it).pred_t = res2;
A(it).real_t = loc_t;
A(it).code_t = code_t;
A(it).trial_t = trial_t;

% Animate(loc_v, res, 0.001, [-3 3 -3 3], 0, trial_v, data.trInfo, [] );
% sum(sum((loc_t - res2) .^ 2)) / numel(loc_t)
err(it) = sum(sum((loc_v - res) .^ 2)) / numel(loc_v);
fprintf('The error for it %d is %f \n', it, err(it));

end


save(['err', SessionNum{rat}], 'A');

end
