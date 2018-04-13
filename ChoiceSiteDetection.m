clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));

%%
folderPath = 'E:\New folder\P1353_18p\'; 
data = CreateAllData(folderPath, []);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 150, 1);

%%
[timestamps, binData, binLoc, trial] = BinData(data, 20);
choice = [data.trInfo.choice];
ramp = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];

%%
% rewardSiteBox = [-1.6 -1.0 0.6 1.2; 1.1 1.5 0.6 1.2; -0.15 0.15 -1.1 -0.85]; %24
% rewardSiteBox = [-1.6 -0.8 0.5 1.2; 1.4 1.8 0.5 1.2; 0.1 0.4 -1.1 -0.85];    %25
% rewardSiteBox = [-1.6 -0.8 0.5 1.2; 1.3 1.9 0.5 1.3; 0.0 0.4 -1.2 -0.5];     %27
% rewardSiteBox = [-1.6 -0.9 0.5 1.2; 1.2 1.9 0.5 1.3; 0.0 0.3 -1.1 -0.7];     %15
% rewardSiteBox = [-2 -1.3 0.6 1.3; 0.8 1.6 0.6 1.3; -0.4 0.1 -1.2 -0.8];      %16
% rewardSiteBox = [-1.5 -0.8 0.5 1.3; 1.2 1.9 0.5 1.3; 0 0.5 -1.2 -0.8];       %17
rewardSiteBox = [-2 -1.2 0.6 1.3; 0.9 1.7 0.6 1.3; -0.3 0.2 -1.1 -0.7];      %18

inRS1 = IfInBox(binLoc, rewardSiteBox(1, :));
inRS2 = IfInBox(binLoc, rewardSiteBox(2, :));
inRS3 = IfInBox(binLoc, rewardSiteBox(3, :));

inRS = inRS1 | inRS2;


freeChoiceTrials = find(freeChoice);
freeChoiceIndices = ismember(trial, freeChoiceTrials);

allData = binData(:, inRS | inRS3);
target = choice(trial(inRS | inRS3));
targetTrial = trial(inRS | inRS3);

%%

AllTrial = find(freeChoice == 0);

trainTrial = AllTrial( ismember(mod(AllTrial, 4), [2, 3]));
ComputeStatistics(trainTrial, choice, reward, ramp, freeChoice);
testTrial = union(setdiff(AllTrial, trainTrial), find(freeChoice == 1));
ComputeStatistics(testTrial, choice, reward, ramp, freeChoice);

trainIndices = ismember(targetTrial, trainTrial);
testIndices  = ismember(targetTrial, testTrial);

train = allData(:, trainIndices);
target_t = target(:, trainIndices);

indices = randperm(length(target_t));
train = train(:, indices);
target_t = target_t(:, indices);

valid = allData(:, testIndices);
target_v = target(:, testIndices);
trial_t = targetTrial(trainIndices);
trial_v = targetTrial(testIndices);

%%

[B, FitInfo] = lassoglm(train', target_t', 'binomial', 'CV', 4, 'DFmax', 40, 'Options', statset('UseParallel', true));%'NumLambda' , 25);
nNonZeroF = sum(B ~= 0);
ind = FitInfo.Index1SE; %find(nNonZeroF >= 10 & nNonZeroF <= 20, 1,'first');    

preds = glmval([FitInfo.Intercept(ind); B(:, ind)], train', 'logit') > 0.5;
acc = sum(preds(:) == target_t(:))/ numel(target_t(:)); 

res = preds(:) ~= target_t(:);

tbl = table(trial_t(:), res(:), 'VariableNames', {'tr', 'res'});
tbl2 = table([1:numel(data.trInfo)]', choice(:), ramp(:), reward(:), freeChoice(:), 'VariableNames', {'tr', 'choice', 'ramp', 'reward', 'free'} );

grpTbl = grpstats(tbl, 'tr', 'sum');
tbl3 = join(grpTbl, tbl2);

corr(tbl3.max_res, tbl3.choice)
corr(tbl3.max_res, tbl3.reward)
corr(tbl3.max_res, tbl3.ramp)
corr(tbl3.max_res, tbl3.free)

tbl4 = grpstats(tbl3, 'max_res', 'mean')

