
clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));
%%
folderPath = 'E:\New folder\P1353_16p\'; 

kernelWidth = [4:4:40];

data = CreateAllData(folderPath, []);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 150, 1);
choice = [data.trInfo.choice];
ramp = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sfc = [data.trInfo.SideOff];
%%
[timestamps, binDataAll, binLoc, trial] = BinData(data, 50, 0);
binLoc = MapToRect(binLoc, trial, data);
plot(binLoc(1, :), binLoc(2, :), '.');

%%
posTrial = data.trials(choice(data.trials) == 1);
negTrial = data.trials(choice(data.trials) == 0);
minNum = min(numel(posTrial), numel(negTrial));

meanError = zeros(numel(kernelWidth), 5, 5);

for kw = 1:numel(kernelWidth)

for rr = 1:5
    
selectedCells = randsample(1:size(binDataAll), kernelWidth(kw));   
binData = binDataAll(selectedCells, :);

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
% code_t = code(trainIndices);

indices = randperm(length(loc_t));
train = train(:, indices);
loc_t = loc_t(:, indices);
% code_t = code_t(indices);

valid = binData(:, testIndices);
loc_v = binLoc(:, testIndices);
% code_v = code(testIndices);

trial_t = trial(trainIndices);
trial_v = trial(testIndices);

timestamps_t = timestamps(trainIndices);
timestamps_v = timestamps(testIndices);

%%

save('data', 'train', 'loc_t', 'valid', 'loc_v');
system('python C:\Users\a.mashhoori\Desktop\Proj\Scripts\main.py');
a = load('data_out');
res = a.res';
res2 = a.res2';
% 
errD = sum((loc_v - res) .^ 2);

A(it).pred_v = res;
A(it).real_v = loc_v;
% A(it).code_v = code_v;
A(it).trial_v = trial_v;

A(it).pred_t = res2;
A(it).real_t = loc_t;
% A(it).code_t = code_t;
A(it).trial_t = trial_t;

err(it) = sum(sum((loc_v - res) .^ 2)) / numel(loc_v);
fprintf('The error for it %d is %f \n', it, err(it));

meanError(kw, rr, it) = err(it);

end

fname = ['.\NumCell_16\kernel_' num2str(kernelWidth(kw)) '_'  num2str(rr)];
save(fname, 'A');
    
end

end

return 


b = mean(meanError, 3);
plot([4:4:40], b, 'ko');

% a1 = [0.1465,   0.1141    0.0916    0.0739    0.0685    0.0549    0.0449    0.0519    0.0611    0.0917];   % 17
% a2 = [0.2159    0.1661    0.1280    0.1116    0.1010    0.0847    0.0743    0.0942    0.1040    0.1316];   %  18
% a3 = [0.2012    0.1450    0.1174    0.0928    0.0750    0.0690    0.0711    0.0730    0.0816    0.1182]; % 16
% a4 = [0.1975    0.1586    0.1434    0.1177    0.1041    0.0893    0.0819    0.0886    0.1013    0.1482]; %15
% a5 = [0.2367    0.1753    0.1489    0.1166    0.1003    0.0716    0.0582    0.0605    0.0629    0.0925]% 24
% a6 = [0.2248    0.1547    0.1482    0.1170    0.0926    0.0865    0.0637    0.0654    0.0742    0.0967]% 25
% a7 = [0.2581    0.2085    0.1853    0.1477    0.1294    0.1301    0.1289    0.1253    0.1291    0.1515] %26
 

% plot(kernelWidth, [a1; a2; a3; a4; a5; a6; a7], '-d');

