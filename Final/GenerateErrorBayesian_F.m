
clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));

%%
folderPath = 'E:\New folder\P1958_25p\'; 
data = CreateAllData(folderPath, []);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 150, 1);
choice = [data.trInfo.choice];
ramp = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
               
%%
[timestamps, binData, binLoc, trial] = BinData(data, 50, 1);
binLoc = MapToRect(binLoc, trial, data);
% plot(binLoc(1, :), binLoc(2, :), '.');
% axis([-2 2 -2 3])
%%
gridWith = [0.05 0.05];
[code, codeMap, gridDim, edges] = GridLocations(binLoc, gridWith);

%%

posTrial = data.trials(choice(data.trials) == 1);
negTrial = data.trials(choice(data.trials) == 0);
minNum = min(numel(posTrial), numel(negTrial));
err = [];
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

train = binData(:, trainIndices) * 50 ;
loc_t = binLoc(:, trainIndices);
code_t = code(trainIndices);

indices = randperm(length(loc_t));
train = train(:, indices);
loc_t = loc_t(:, indices);
code_t = code_t(indices);

valid = binData(:, testIndices) * 50 ;
loc_v = binLoc(:, testIndices);
code_v = code(testIndices);

trial_t = trial(trainIndices);
trial_v = trial(testIndices);

%%

prior = GetPrior(code_t, gridDim, 10);
meanFR = GetMeanFiringRateByCell(train, code_t, size(codeMap, 2));

[predCode, ~] = BayesianPrediction(valid, meanFR, prior);
res = codeMap(:, predCode);

% [predCode, ~] = BayesianPrediction(train, meanFR, prior);
% res2 = codeMap(:, predCode);

% plot(loc_v_d(1, :), loc_v_d(2, :), '.') 

% A(it).pred_v = res;
% A(it).real_v = loc_v;
% A(it).code_v = code_v;
% 
% A(it).pred_t = res2;
% A(it).real_t = loc_t;
% A(it).code_t = code_t;

% Animate(loc_v, res, 0.001, [-3 3 -3 3], 0, trial_v, data.trInfo, [] );
% sum(sum((loc_t - res2) .^ 2)) / numel(loc_t)

load('Ratio.mat')

error = (loc_v - res);
error(1, :) = xRatio(5) * error(1, :);
error(2, :) = yRatio(5) * error(2, :);
error = error .^ 2;

err(it) = sqrt(sum(error(:)) / numel(error));


%sum(sum((loc_v - res) .^ 2)) / numel(loc_v);


fprintf('The error for it %d is %f \n', it, err(it));

end

mean(err)
% save('errB25P', 'A');
