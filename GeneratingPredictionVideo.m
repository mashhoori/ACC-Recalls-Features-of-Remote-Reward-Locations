% P1353_15
% P1958_24

clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));

%%
folderPath = 'E:\New folder\P1958_25p\'; 
data = CreateAllData(folderPath, []);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 150, 1);

clear folderPath
%%
binWidth = 50;

d = data.data(data.dataIndex, :);
d = reshape(d, size(d, 1), binWidth, []);
binData = squeeze(sum(d, 2));

loc = data.data(data.locIndex, :);
loc = reshape(loc, size(loc, 1), binWidth, []);
binLoc = squeeze(mean(loc, 2));
figure
plot(binLoc(1, :), binLoc(2, :), '.');

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

%%

num = floor(length(binData) * 4 / 5);
train = binData(:, 1:num);
loc_t = binLoc(:, 1:num);
valid = binData(:, num + 1:end);
loc_v = binLoc(:, num + 1:end);
trial_v = trial(num + 1:end);

save('data', 'train', 'loc_t', 'valid', 'loc_v');

%%

a = load('data_out');
res = a.res';
res2 = a.res2';

loc_v2 = loc_v(:, trial_v <= 224);
res2   = res(:, trial_v <= 224);
trial_v2 = trial_v(trial_v <= 224);

Animate(loc_v, res, 0.005, [-3 3 -3 3], 1, trial_v, data.trInfo);





