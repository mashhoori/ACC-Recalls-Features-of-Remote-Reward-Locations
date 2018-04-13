
clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));
%%
folderPath = 'E:\New folder\P1353_16p\'; 
[data, FTS] = CreateAllData(folderPath, []);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 150, 1);
choice = [data.trInfo.choice];
ramp = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sfc = [data.trInfo.SideOff];
%%
[timestamps, binData, binLoc, trial] = BinData(data, 50, 0);
binLoc = MapToRect(binLoc, trial, data);
plot(binLoc(1, :), binLoc(2, :), '.');

%%
gridWith = [0.1 0.1];
[code, codeMap, gridDim] = GridLocations(binLoc, gridWith);

%%
posTrial = data.trials(choice(data.trials) == 1);
negTrial = data.trials(choice(data.trials) == 0);
minNum = min(numel(posTrial), numel(negTrial));

for it = 1:1

selectedPos = randsample(posTrial, minNum);
selectedNeg = randsample(negTrial, minNum);

AllSelected = [selectedPos selectedNeg];

r = rand(1, numel(AllSelected));
trainTrials = AllSelected(r <= 0.85);
testTrials  = AllSelected(r >  0.85);

ComputeStatistics(trainTrials, choice, reward, ramp, freeChoice);
ComputeStatistics(testTrials, choice, reward, ramp, freeChoice);

trainIndices = ismember(trial, trainTrials);
testIndices  = ismember(trial, testTrials);

train = binData(:, trainIndices);
loc_t = binLoc(:, trainIndices);
code_t = code(trainIndices);

indices = randperm(length(loc_t));
train = train(:, indices);
loc_t = loc_t(:, indices);
code_t = code_t(indices);

valid = binData(:, testIndices);
loc_v = binLoc(:, testIndices);
code_v = code(testIndices);

trial_t = trial(trainIndices);
trial_v = trial(testIndices);

timestamps_t = timestamps(trainIndices);
timestamps_v = timestamps(testIndices);

%%

save('data', 'train', 'loc_t', 'valid', 'loc_v');
system('python C:\Users\a.mashhoori\Desktop\Proj\Scripts\main.py');
a = load('data_out');
w = load('weights.mat');

res = a.res';
res2 = a.res2';
% 
errD = sum((loc_v - res) .^ 2);
out = SimulateNetwork(train, w);

err(it) = sum(sum((loc_v - res) .^ 2)) / numel(loc_v);
fprintf('The error for it %d is %f \n', it, err(it));

end

mean(err)

return

%%


figure
for cell = 1:25

activity = out{end-1}(cell, :);   
%activity = (activity - mean(activity)) / range(activity);
activity = zscore(activity);

meanActivity = zeros(1, prod(gridDim));
count = zeros(1, prod(gridDim));
realCode = code_t;    


for i = 1:prod(gridDim)
    meanActivity(i) = mean(activity(realCode == i));
    count = sum(realCode == i);    
end      

meanActivity(isnan(meanActivity)) = 0;
meanActivity(count < 20) = 0;

avg1 = reshape(meanActivity, gridDim(2), []);        
avg1 = conv2(avg1, ones(2, 2)/4, 'same');        
avg1 = rot90(avg1, 2);
avg1 = avg1(:, end:-1:1);

subplot(5, 5, cell)
% imagesc(-avg1)

imagesc(mean(avg1, 2))


%colormap gray
caxis([-1 1])
% axis equal
% axis tight

end


