
clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));
%%

folderPath = 'E:\New folder\P1958_25p\';

%%

load('Ratio.mat')
[data, FTS] = CreateAllData(folderPath, [], 'vtm1.pvd');

data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 150, 1);
data.badData(data.dataIndex, :) = smoother(data.badData(data.dataIndex, :), 150, 1);

choice = [data.trInfo.choice];
ramp = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sfc = [data.trInfo.SideOff];

%%
[timestamps, binData, binLoc, trial] = BinData(data, 50, 1);

data2 = data;
data2.data = data2.badData;
[timestampsBad, binDataBad, binLocBad, trialBad] = BinData(data2, 50, 1);

AllLoc = [binLoc binLocBad];
AllLoc = zscore(AllLoc, 0, 2);

binLoc = AllLoc(:, 1:length(binLoc));
binLocBad = AllLoc(:, length(binLoc)+1:end);


%%
posTrial = data.trials(choice(data.trials) == 1);
negTrial = data.trials(choice(data.trials) == 0);
minNum = min([numel(posTrial), numel(negTrial)]);

selectedPos = randsample(posTrial, minNum);
selectedNeg = randsample(negTrial, minNum);

AllSelected = [selectedPos selectedNeg];
trainIndices = ismember(trial, AllSelected);
train = binData(:, trainIndices);
loc_t = binLoc(:, trainIndices);
trial_t = trial(trainIndices);

indices = randperm(length(loc_t));
train = train(:, indices);
loc_t = loc_t(:, indices);
trial_t = trial_t(indices);

valid = binDataBad;
loc_v = binLocBad;
trial_v = trialBad;


%%
save('data', 'train', 'loc_t', 'valid', 'loc_v');
system('python .\main.py True');
a = load('data_out');
res = a.resValid{end}';
res2 = a.resTrain{end}';

error = loc_v - res;

% error(1, :) = error(1, :) * xRatio(6);
% error(2, :) = error(2, :) * yRatio(6);

err = sqrt(  sum(sum(error .^ 2)) / numel(error)  );
errNet = mean(sqrt(sum(error .^ 2)));
% errNet(it) = mean(sum(abs(error)));


%%

% % Animate(loc_v, res, 0.001, [-3 3 -3 3], 0, trial_v, data.trInfo, [] );
% % sum(sum((loc_t - res2) .^ 2)) / numel(loc_t)
% err(it) = sum(sum((loc_v - res) .^ 2)) / numel(loc_v);
% fprintf('The error for it %d is %f \n', it, err(it));

mean(err)

return

