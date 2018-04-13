
clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));
%%

folderPath = 'E:\New folder\P1353_17p\';

%%

load('Ratio.mat')
[data, FTS] = CreateAllData(folderPath, [], 'vtm1.pvd');
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 150, 1);
choice = [data.trInfo.choice];
ramp = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sfc = [data.trInfo.SideOff];

%%
[timestamps, binData, binLoc, trial] = BinData(data, 50, 0);
[timestamps, binData_Org, binLoc, trial] = BinData(data, 50, 1);
binLoc = MapToRect(binLoc, trial, data);

selectedTrials = find((choice == 0) & (reward == 0) & (ramp == 0));


xRatio = 114.3 / 3.35;
yRatio = 101.6 / 3.25;
% 
binLoc(1, :) = binLoc(1, :) * xRatio;% * 100;
binLoc(2, :) = binLoc(2, :) * yRatio;% * 100;

% [binLoc, mu, sigma] = zscore(binLoc, 0, 2);
% plot(binLoc(1, :), binLoc(2, :), '.');


%%

for it = 1:10

AllSelected = selectedTrials;

r = rand(1, numel(AllSelected));
% 
% trainTrials = AllSelected(1:round(numel(AllSelected)/2));
% testTrials  = AllSelected(round(numel(AllSelected)/2) + 1:end);

trainTrials = AllSelected(1:2:end);
testTrials  = AllSelected(2:2:end);

ComputeStatistics(trainTrials, choice, reward, ramp, freeChoice);
ComputeStatistics(testTrials, choice, reward, ramp, freeChoice);

trainIndices = ismember(trial, trainTrials);
testIndices  = ismember(trial, testTrials);

train = binData(:, trainIndices);
loc_t = binLoc(:, trainIndices);
%code_t = code(trainIndices);

indices = randperm(length(loc_t));
train = train(:, indices);
loc_t = loc_t(:, indices);
%code_t = code_t(indices);

valid = binData(:, testIndices);
loc_v = binLoc(:, testIndices);
%code_v = code(testIndices);

trial_t = trial(trainIndices);
trial_v = trial(testIndices);

timestamps_t = timestamps(trainIndices);
timestamps_v = timestamps(testIndices);

%%
save('data', 'train', 'loc_t', 'valid', 'loc_v');
system('python .\main.py True');
a = load('data_out');
res = a.resValid{end}';
res2 = a.resTrain{end}';

error = loc_v - res;
% error(1, :) = error(1, :) * xRatio(6);
% error(2, :) = error(2, :) * yRatio(6);

%err(it) = sqrt(  sum(sum(error .^ 2)) / numel(error)  );
errNet(it) = mean(sqrt(sum(error .^ 2)));
% errNet(it) = mean(sum(abs(error)));


end

mean(err)

return
% 6.6867    4.5988    5.3039    3.7702    5.6673

% 8.6951
% 8.0515

% 8.4032
% 8.4656

% 5.7130
% 6.5173

% 6.6286
% 7.5005