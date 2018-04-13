
clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));

%%
folderPath = 'E:\New folder\P1958_24p\'; 
data = CreateAllData(folderPath, []);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 150, 1);

clear folderPath
%%
[timestamps, binData, binLoc, trial] = BinData(data, 50, 0);

%[timestamps, binData, binLoc, trial] = BinData(data, 50);
% binLoc2 = MapToRect(binLoc, trial, data);
%plot(binLoc2(1, :), binLoc2(2, :), '.');

choice = [data.trInfo.choice];
ramp = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sideOff = [data.trInfo.SideOff];
%%
gridWith = [0.1 0.15];
[code, codeMap, gridDim] = GridLocations(binLoc, gridWith);

% [code, codeMap] = CoarseGrid(binLoc);
% gridDim = [6 7];

%%
AllTrial =  data.trials;% 2:numel(data.trInfo);
AllTrial2 = AllTrial( ~ismember(AllTrial, find(freeChoice)) );
trainTrial = AllTrial( ismember(mod(AllTrial2, 4),  [3 2] ) );
testTrial = setdiff(AllTrial, trainTrial);

ComputeStatistics(trainTrial, choice, reward, ramp, freeChoice);
ComputeStatistics(testTrial, choice, reward, ramp, freeChoice);

trainIndices = ismember(trial, trainTrial);
testIndices  = ismember(trial, testTrial);

train = binData(:, trainIndices);
loc_t = binLoc(:, trainIndices);
code_t = code(trainIndices);
% loc_t = codeMap(:, code_t);

indices = randperm(length(loc_t));
train = train(:, indices);
loc_t = loc_t(:, indices);

valid = binData(:, testIndices);
loc_v = binLoc(:, testIndices);
code_v = code(testIndices);

trial_t = trial(trainIndices);
trial_v = trial(testIndices);

save('data', 'train', 'loc_t', 'valid', 'loc_v');
system('python C:\Users\a.mashhoori\Desktop\Proj\Scripts\main.py');

%%
a = load('data_out');
res = a.res';
res2 = a.res2';

%%
% realLoc = loc_t;
% predLoc = res2;

%%
realLoc = loc_v;
predLoc = res;

%%

count = zeros(1, prod(gridDim));
for i = 1:prod(gridDim)
   count(i) = sum(code_v == i);
end
badLoc = find(count < 20);

realLoc = realLoc(:, ~ismember(code_v, badLoc));
predLoc = predLoc(:, ~ismember(code_v, badLoc));
code_v = code_v(~ismember(code_v, badLoc));

se = sum((predLoc - realLoc) .^ 2);
mse = zeros(1, prod(gridDim));
for i= 1:prod(gridDim)
    mse(i) = sqrt(mean(se(code_v == i)));
end
mse(isnan(mse)) = 0;

avg1 = reshape(mse, gridDim(2), []);        
avg1 = conv2(avg1, ones(3, 3)/9, 'same');        
avg1 = rot90(avg1, 2);
avg1 = avg1(:, end:-1:1);
% avg1([2:5], [2, 3, 5, 6]) = 0;
% avg1(7) = mean([avg1(6) avg1(14)]);
% avg1(1) = mean([avg1(2) avg1(8)]);

figure
imagesc(avg1)
colormap jet
axis equal
axis tight




sum(sum((loc_v - res) .^ 2)) / numel(loc_v)
% 
% save avg1 avg1
% gg = load('avg1');

% [code, codeMap] = CoarseGrid(binLoc);