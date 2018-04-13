
clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));

%%
folderPath = 'E:\New folder\P1958_24p\'; 
data = CreateAllData(folderPath, []);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 150, 1);

%%
binWidth = 50;

d = data.data(data.dataIndex, :);
d = reshape(d, size(d, 1), binWidth, []);
binData = squeeze(sum(d, 2));

% binData = smoother(binData, 4, 1);


loc = data.data(data.locIndex, :);
loc = reshape(loc, size(loc, 1), binWidth, []);
binLoc = squeeze(mean(loc, 2));
figure


trial = data.data(data.trialIndex, :);
trial = trial(1:binWidth:end);

% binData = sqrt(binData);
% binData = zscore(binData, 0, 2);
binLoc = zscore(binLoc, 0, 2);

a = find(binLoc(1, :) < -0.5, 1);
b = find(binLoc(1, :) > 1, 1, 'last');

binData = binData(:, a:b);
binLoc  = binLoc(:, a:b);
trial   = trial(a:b);

%%
gridWith = 0.1;
[code, codeMap, gridDim] = GridLocations(binLoc, gridWith);

%%

% num = floor(length(binData) * 4 / 5);
% 
% train = binData(:, 1:num);
% loc_t = binLoc(:, 1:num);
% valid = binData(:, num + 1:end);
% loc_v = binLoc(:, num + 1:end);
% trial_v = trial(num + 1:end);
% code_t = code(1:num);
% code_v = code(num+1:end);

AllTrial = 2:numel(data.trInfo);
trainTrial = AllTrial( mod(AllTrial, 4) < 2);
testTrial = setdiff(AllTrial, trainTrial);

trainIndices = ismember(trial, trainTrial);
testIndices  = ismember(trial, testTrial);

train = binData(:, trainIndices);
loc_t = binLoc(:, trainIndices);

valid = binData(:, testIndices);
loc_v = binLoc(:, testIndices);

trial_t = trial(trainIndices);
trial_v = trial(testIndices);

code_t = code(trainIndices);
code_v = code(testIndices);

%%
                                                
prior = GetPrior(code_t, gridDim, 100);
meanFR = GetMeanFiringRateByCell(train, code_t, size(codeMap, 2));

[predCode, probs] = BayesianPrediction(valid, meanFR, prior);
Animate_3(code_v, probs, 0.01, gridDim)

res = codeMap(:, predCode);
loc_v_d = codeMap(:, code_v);
plot(loc_v_d(1, :), loc_v_d(2, :), '.') 

% Animate(loc_v_d, res, 0.001, [-3 3 -3 3], 0, trial_v, data.trInfo);
sum(sum((loc_v_d - res) .^ 2)) / numel(loc_v_d)
