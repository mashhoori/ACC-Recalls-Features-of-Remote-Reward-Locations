clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));
%%
folderPath = 'E:\New folder\P1353_15p\'; 
data = CreateAllData(folderPath, []);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 150, 1);
choice = [data.trInfo.choice];
ramp = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
%%
[timestamps, binData, binLoc, trial] = BinData(data, 50, 0);
binLoc = MapToRect(binLoc, trial, data);
plot(binLoc(1, :), binLoc(2, :), '.');
axis([-2 2 -2 3])
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
trainTrials = AllSelected(r <= 0.75);
testTrials  = AllSelected(r >  0.75);

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

%%

save('data', 'train', 'loc_t', 'valid', 'loc_v');
system('python C:\Users\a.mashhoori\Desktop\Proj\Scripts\main.py');
a = load('data_out');
res = a.res';
res2 = a.res2';

A(it).pred_v = res;
A(it).real_v = loc_v;
A(it).code_v = code_v;

A(it).pred_t = res2;
A(it).real_t = loc_t;
A(it).code_t = code_t;

% Animate(loc_v, res, 0.001, [-3 3 -3 3], 0, trial_v, data.trInfo, [] );
% sum(sum((loc_t - res2) .^ 2)) / numel(loc_t)
err(it) = sum(sum((loc_v - res) .^ 2)) / numel(loc_v);
fprintf('The error for it %d is %f \n', it, err(it));

end


% save('err18', 'A');
% mean(err)

%%

fileNames = {'err24', 'err25', 'err27', 'err15', 'err16', 'err17', 'err18'};

for jkl = 1:numel(fileNames)
    
load(fileNames{jkl});
gridWith = [42, 52];

numIt = 10;
count = zeros(1, prod(gridDim));
mse = zeros(1, prod(gridDim));
for it = 1:numIt    
    realCode = A(it).code_v;
    realLoc  = A(it).real_v;
    predLoc  = A(it).pred_v;
    
    for i = 1:prod(gridDim)
       count(i) = count(i) + sum(realCode == i);
    end
    
    se = sum((predLoc - realLoc) .^ 2);
    
    for i = 1:prod(gridDim)
        mse(i) = mse(i) + sum(se(realCode == i));
    end
end

val = prctile(count(count > 0), 30);

% mse = mse ./ count;
badLoc = find(count < val);

mse(badLoc) = 0;
mse(isnan(mse)) = 0;

avg1 = reshape(mse, gridDim(2), []);        
avg1 = conv2(avg1, ones(2, 2)/4, 'same');        
avg1 = rot90(avg1, 2);
avg1 = avg1(:, end:-1:1);

avg2 = reshape(count, gridDim(2), []);        
avg2 = conv2(avg2, ones(2, 2)/4, 'same');        
avg2 = rot90(avg2, 2);
avg2 = avg2(:, end:-1:1);

% avg1([2:5], [2, 3, 5, 6]) = 0;
% avg1(7) = mean([avg1(6) avg1(14)]);
% avg1(1) = mean([avg1(2) avg1(8)]);

% figure
% imagesc(avg1)
% colormap jet
% axis equal
% axis tight

MM{jkl} = avg1;
NN{jkl} = avg2;
end

avg = MM{1};
cnt = NN{1};
for i = 2:numel(fileNames)
    avg = avg + MM{i};
    cnt = cnt + NN{i};
end

avg = avg ./ cnt;

val = prctile(cnt(cnt > 0), 20);
badLoc = find(cnt < val);

avg(badLoc) = 0;
avg(isnan(avg)) = 0;

avgc = conv2(avg, ones(2, 2)/4, 'same');        

avg(avg > 1) = 0.5;

figure
imagesc(sqrt(avgc/7))
colormap jet
axis equal
axis tight

