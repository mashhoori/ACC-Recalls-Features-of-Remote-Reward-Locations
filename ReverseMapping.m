

clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));
%%
folderPath = 'E:\New folder\P1353_15p\'; 
[data, FTS] = CreateAllData(folderPath, []);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 150, 1);
choice = [data.trInfo.choice];
ramp = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sfc = [data.trInfo.SideOff];
%%
[timestamps, binData, binLoc, trial] = BinData(data, 100, 0);
%%
posTrial = data.trials(choice(data.trials) == 1);
negTrial = data.trials(choice(data.trials) == 0);
minNum = min(numel(posTrial), numel(negTrial));

for it = 1:10

    
    
selectedPos = randsample(posTrial, minNum);
selectedNeg = randsample(negTrial, minNum);

AllSelected = [selectedPos selectedNeg];

r = rand(1, numel(AllSelected));
trainTrials = AllSelected(r <= 0.85);
testTrials  = AllSelected(r >  0.85);

ComputeStatistics(trainTrials, choice, reward, ramp, freeChoice);
ComputeStatistics(testTrials, choice, reward, ramp, freeChoice);

trainIndices = ismember(trial, trainTrials);
testIndices  = ismember(trial, testTrials);

trainIndices(1) = 0;

speed = [[0 0]', diff(binLoc, [], 2)];

train = binData(:, trainIndices);
loc_t = binLoc(:, trainIndices);
loc_t_pre = binLoc(:, find(trainIndices)-1);
speed_t = speed(:, trainIndices);
trial_t = trial(trainIndices);
trial_v = trial(testIndices);

indices = randperm(length(loc_t));
train = train(:, indices);
speed_t = speed_t(:, indices);
loc_t_pre = loc_t_pre(: , indices);
loc_t = loc_t(:, indices);

loc_t11 = [loc_t; loc_t_pre; speed_t; reward(trial_t-1); reward(trial_t); choice(trial_t)];

valid = binData(:, testIndices);
loc_v = binLoc(:, testIndices);
loc_t_pre = binLoc(:, find(testIndices)-1);
speed_v = speed(:, testIndices);
loc_v11 = [ loc_v; loc_t_pre; speed_v; reward(trial_v-1); reward(trial_v); choice(trial_v)];


timestamps_t = timestamps(trainIndices);
timestamps_v = timestamps(testIndices);

%%

save('data', 'train', 'loc_t11', 'valid', 'loc_v11');
system('python C:\Users\a.mashhoori\Desktop\Proj\Scripts\main200.py');
a = load('data_out');
res = a.res';
res2 = a.res2';

% errD = sum((loc_v - res) .^ 2);

err(it) = sum(sum((valid - res) .^ 2)) / numel(valid);
fprintf('The error for it %d is %f \n', it, err(it));

end
