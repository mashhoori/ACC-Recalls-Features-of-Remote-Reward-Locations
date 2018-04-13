
clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));
%%
folderPath = 'E:\New folder\P1958_25p\'; 
data = CreateAllDataSleep(folderPath, []);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 150, 1);
% data.spikesMatSleep = double(rand(size(data.spikesMatSleep)) > 0.9);
data.spikesMatSleep = smoother(data.spikesMatSleep, 150, 1);

choice = [data.trInfo.choice];
ramp   = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sfc = [data.trInfo.SideOff];
%%

[timestamps, binData, binLoc, trial] = BinData(data, 20, 0);
binLoc = MapToRect(binLoc, trial, data);
plot(binLoc(1, :), binLoc(2, :), '.');

[timestampsSleep, binDataSleep] = BinDataSleep(data, 20, 0);


[coeff,score,latent,tsquared] = pca([binData]');

plot(score(choice(trial) == 0, 1), score(choice(trial) == 0, 2),'.')
hold on
plot(score(choice(trial) == 1, 1), score(choice(trial) == 1, 2), '.')

plot(score(trial == 10, 1), score(trial == 10, 2), '-')

plot(score(trial == 11, 1), score(trial == 11, 2), '-')
plot(score(trial == 13, 1), score(trial == 13, 2), '-')


plot(score(1:length(binData), 1), score(1:length(binData), 2), '.')
hold on
plot(score(length(binData)+1:end, 1), score(length(binData)+1:end, 2), '.')

gridWith = [0.2 0.2];
[code, codeMap, gridDim, edges] = GridLocations(binLoc, gridWith);

c = histc(code, 0:length(codeMap)-1);
ind = [];

imagesc(reshape(c, gridDim(2), []))

for i = 0:length(codeMap)
    indices = find(code == i);
    sel = randsample(indices, min(numel(indices), 100));
    ind = [ind sel];
end

binData = binData(:, ind);
binLoc  = binLoc (:, ind);

%%
train = binData;
loc_t = binLoc;

valid = binDataSleep;
loc_v = zeros(2, length(valid));

%%

save('data', 'train', 'loc_t', 'valid', 'loc_v');
system('python C:\Users\a.mashhoori\Desktop\Proj\Scripts\main.py');
a = load('data_out');
res = a.res';
res2 = a.res2';

figure
codeSleep = GetCodeForLocation(res, edges);
bincounts = histc(codeSleep, 0:length(codeMap)-1);
img = reshape(bincounts, gridDim(2), []);
img = rot90(img, 2);
% img = conv2(img, ones(2, 2)/ 4);
img = flip(img, 2);
imagesc(log(img))
colormap jet

figure
% Animate(loc_v, res, 0.001, [-3 3 -3 3], 0, trial, data.trInfo, [] );
plot(res(1, :), res(2, :), '.')
return
