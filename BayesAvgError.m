clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));

%%
folderPath = 'E:\New folder\P1958_27p\'; 
data = CreateAllData(folderPath, []);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 150, 1);
choice = [data.trInfo.choice];
ramp = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
%%
[timestamps, binData, binLoc, trial] = BinData(data, 50, 1);
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
trainTrials = AllSelected(r < 0.7);
testTrials = AllSelected(r >= 0.7);

ComputeStatistics(trainTrials, choice, reward, ramp, freeChoice);
ComputeStatistics(testTrials, choice, reward, ramp, freeChoice);

trainIndices = ismember(trial, trainTrials);
testIndices  = ismember(trial, testTrials);

train = binData(:, trainIndices);
loc_t = binLoc(:, trainIndices);

valid = binData(:, testIndices);
loc_v = binLoc(:, testIndices);

trial_t = trial(trainIndices);
trial_v = trial(testIndices);

code_t = code(trainIndices);
code_v = code(testIndices);

%%
                                     
prior = GetPrior(code_t, gridDim, 25);
meanFR = GetMeanFiringRateByCell(train, code_t, size(codeMap, 2));

[predCode, probs] = BayesianPrediction(valid, meanFR, prior);

res = codeMap(:, predCode);
loc_v_d = codeMap(:, code_v);
% plot(res(1, :), res(2, :), '.') 

err(it) = sum(sum((loc_v_d - res) .^ 2)) / numel(loc_v_d);

% Animate(loc_v_d , res, 0.001, [-3 3 -3 3], 0, trial_v, data.trInfo, [] );
fprintf('The error for it %d is %f \n', it, err(it));

end


mean(err)