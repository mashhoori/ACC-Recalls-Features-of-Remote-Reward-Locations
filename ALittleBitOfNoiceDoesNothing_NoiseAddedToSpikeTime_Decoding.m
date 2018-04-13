
clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));

%%

load('Ratio.mat')

folderNames = {'P1353_15p', 'P1353_16p', 'P1353_17p', 'P1353_18p', 'P1958_24p', 'P1958_25p', 'P1958_27p'};

for rat = 2:numel(folderNames)

fprintf('rat %d \n ', rat);
folderPath = ['E:\New folder\' folderNames{rat} '\']; 

%%

[data, FTS] = CreateAllData(folderPath, [], 'vtm1.pvd');
choice = [data.trInfo.choice];
ramp = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sfc = [data.trInfo.SideOff];

%%

timestamps = data.data(data.timeIndex, :);
dataShuffled = data;
selector = true(1, length(timestamps));

dataShuffled.data(data.dataIndex, :) = AddNoiseToSpikes(dataShuffled.data(dataShuffled.dataIndex, :), selector, 0.25);
dataShuffled.data(data.dataIndex, :) = smoother(dataShuffled.data(data.dataIndex, :), 150, 1);
[~, binDataShuffled, ~, ~] = BinData(dataShuffled, 50, 0);

%%

data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 150, 1);
[timestamps, binData, binLoc, trial] = BinData(data, 50, 0);
binLoc = MapToRect(binLoc, trial, data);

%%
posTrial = data.trials(choice(data.trials) == 1);
negTrial = data.trials(choice(data.trials) == 0);
minNum = min([numel(posTrial), numel(negTrial)]);

err = [];
err_s = [];
A = [];

for it = 1:5

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
trial_t = trial(trainIndices);


indices = randperm(length(loc_t));
train = train(:, indices);
loc_t = loc_t(:, indices);
trial_t = trial_t(indices);


valid = binData(:, testIndices);
loc_v = binLoc(:, testIndices);
trial_v = trial(testIndices);


%%
save('data', 'train', 'loc_t', 'valid', 'loc_v');
system('python E:\Proj\Scripts\main.py True ./modelWeights');
a = load('data_out');
res = a.resValid{end}' ;
res2 = a.resTrain{end}';

error = (loc_v - res);
error(1, :) = error(1, :) * xRatio(rat);
error(2, :) = error(2, :) * yRatio(rat);

err(it) = sqrt(sum(sum(error .^ 2)) / numel(loc_v));
%%
% 
validN = binDataShuffled(:, testIndices);
save('data', 'validN');
system('python E:\Proj\Scripts\main.py False ./modelWeights');
a = load('data_out');
resNew = a.resValid{end}';

error = (loc_v - resNew);
error(1, :) = error(1, :) * xRatio(rat);
error(2, :) = error(2, :) * yRatio(rat);

diff = (res - resNew);
diff(1, :) = diff(1, :) * xRatio(rat);
diff(2, :) = diff(2, :) * yRatio(rat);

diff = sqrt(sum(diff  .^ 2)) * 100;
plot(diff)

err_s(it) = sqrt(sum(sum(error .^ 2)) / numel(loc_v));
% 
% plot(res(1, :), res(2, :), '.')
% hold on
% plot(resNew(1, :), resNew(2, :), '.')

%%
% 
A(it).pred_v = res;
A(it).real_v = loc_v;
A(it).trial_v = trial_v;

A(it).pred_t = res2;
A(it).real_t = loc_t;
A(it).trial_v = trial_t;

A(it).pred_n = resNew;

%%

fprintf('The error for it %d is %f \n', it, err(it));
% fprintf('The error for shuffled it %d is %f \n', it, err_s(it));
fprintf('========================\n');

end

name = ['shuffleError_NN', num2str(rat)];
save(name, 'err', 'err_s', 'A')

end
%12.57
return
