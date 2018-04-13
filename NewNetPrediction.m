
clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));

%%
folderPath = 'E:\New folder\P1958_27p\'; 
data = CreateAllData(folderPath, []);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 300, 1);

%%
binWidth = 50;

timepoints = data.data(data.timeIndex, :);
timepoints = timepoints(1:binWidth:end);

d = data.data(data.dataIndex, :);
d = reshape(d, size(d, 1), binWidth, []);
binData = squeeze(sum(d, 2));

loc = data.data(data.locIndex, :);
loc = reshape(loc, size(loc, 1), binWidth, []);
binLoc = squeeze(mean(loc, 2));
% figure
% plot(binLoc(1, :), binLoc(2, :), '.');

trial = data.data(data.trialIndex, :);
trial = trial(1:binWidth:end);

binData = sqrt(binData);
binData = zscore(binData, 0, 2);
binLoc = zscore(binLoc, 0, 2);

a = find(binLoc(1, :) < -0.5, 1);
b = find(binLoc(1, :) > 1, 1, 'last');

binData = binData(:, a:b);
binLoc  = binLoc(:, a:b);
trial   = trial(a:b);
timepoints = timepoints(a:b);

%%
% 
% gridWith = 0.05;
% [code, codeMap, gridDim] = GridLocations(binLoc, gridWith);

%%

AllTrial = 2:numel(data.trInfo);
trainTrial = AllTrial( mod(AllTrial, 4) < 3);
testTrial = setdiff(AllTrial, trainTrial);


trainIndices = ismember(trial, trainTrial);
testIndices  = ismember(trial, testTrial);


train = binData(:, trainIndices);
loc_t = binLoc(:, trainIndices);

indices = randperm(length(loc_t));
train = train(:, indices);
loc_t = loc_t(:, indices);

valid = binData(:, testIndices);
loc_v = binLoc(:, testIndices);
trial_t = trial(trainIndices);
trial_v = trial(testIndices);
% ripples_t = ripples(1:num);
% ripples_v = ripples(num + 1:end);
% timepoints_t = timepoints(1:num);
% timepoints_v = timepoints(num+1:end);
% code_t = code(1:num);
% code_v = code(num+1:end);
% loc_v = codeMap(:, code_v);
% loc_t = codeMap(:, code_t);
%%

save('data', 'train', 'loc_t', 'valid', 'loc_v');
system('python C:\Users\a.mashhoori\Desktop\Proj\Scripts\main.py');
a = load('data_out');

res = a.res';
res2 = a.res2';

% Animate(loc_v, res, 0.001, [-3 3 -3 3], 0, trial_v, data.trInfo);
sum(sum((loc_v - res) .^ 2)) / numel(loc_v)


return
%%

plot(res(1, :), res(2, :), '.')
