
clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));

%%
folderPath = 'E:\New folder\P1958_25p\'; 
data = CreateAllData(folderPath, []);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 150, 1);

clear folderPath
%%
binWidth = 20;

d = data.data(data.dataIndex, :);
d = reshape(d, size(d, 1), binWidth, []);
binData = squeeze(sum(d, 2));

loc = data.data(data.locIndex, :);
loc = reshape(loc, size(loc, 1), binWidth, []);
binLoc = squeeze(mean(loc, 2));
figure

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

plot(binLoc(1, :), binLoc(2, :), '.');

%%

gate = reshape([data.trInfo.gates], 2, []);
freeChoice = (sum(gate) ~= 1);
freeChoiceTrials = find(freeChoice);
freeChoiceIndices = ismember(trial, freeChoiceTrials);

choice = [data.trInfo.choice];
RS1Choice = choice == 1;
RS2Choice = choice == 0;

RS1ChoiceFree = freeChoice & RS1Choice;
RS2ChoiceFree = freeChoice & RS2Choice;


RS1ChoiceFreeTrials = find(RS1ChoiceFree);
RS2ChoiceFreeTrials = find(RS2ChoiceFree);

minTrials = min(numel(RS1ChoiceFreeTrials), numel(RS2ChoiceFreeTrials));

RS1ChoiceFreeTrialsSel = randsample(RS1ChoiceFreeTrials, minTrials, false);
RS2ChoiceFreeTrialsSel = randsample(RS2ChoiceFreeTrials, minTrials, false);

selectedTrials = [RS1ChoiceFreeTrialsSel RS2ChoiceFreeTrialsSel];

freeChoiceIndicesSelected = ismember(trial, selectedTrials);



vel =  sqrt(sum(diff(binLoc, 1, 2) .^ 2));
vel = [0 vel];

% hist(vel(inRS), 100)

% rewardSiteBox = [-2 -1.3 0.5 1.5; 0.9 2 0.5 1.5; -0.4 0 -0.95 -0.85];  %16
%  rewardSiteBox = [-2 -0.9 0.5 1.5; 1.2 2 0.5 1.5; -0.4 0 -0.95 -0.85];  %17
 rewardSiteBox = [-2 -0.8 0.5 1.5; 1.4 2 0.5 1.5; -0.4 0 -0.95 -0.85];  %25
%  rewardSiteBox = [-2 -0.8 0.5 1.5; 1.4 2 0.5 1.5; -0.4 0 -0.95 -0.85];  %27

inRS1 = IfInBox(binLoc, rewardSiteBox(1, :));
inRS2 = IfInBox(binLoc, rewardSiteBox(2, :));
inRSM = IfInBox(binLoc, rewardSiteBox(3, :));

inRS = inRS1 | inRS2;
inRSA = inRS | inRSM;
% 

value = prctile(vel(inRS), 80);

indHighVel = vel >  value;
indLowVel  = vel <= value;

% 
% hist(vel(~inRSA), 100)
% plot(binLoc(1, indLowVel), binLoc(2,indLowVel), '.' )

train = binData(:, (indHighVel & ~freeChoiceIndices)  );%| freeChoiceIndicesSelected 
loc_t = binLoc(:, (indHighVel & ~freeChoiceIndices)  ); %| freeChoiceIndicesSelected
valid = binData(:, indLowVel & inRS & ~freeChoiceIndices);
loc_v = binLoc(:, indLowVel & inRS & ~freeChoiceIndices);
trIndex_t = trial((indHighVel & ~freeChoiceIndices)  ); %| freeChoiceIndicesSelected
trIndex_v = trial(indLowVel & inRS & ~freeChoiceIndices);


% Animate(loc_v, res, 0.005, [-3 3 -3 3], 0, trIndex_v, data.trInfo);

save('data', 'train', 'loc_t', 'valid', 'loc_v');

%%

a = load('data_out');
res = a.res';
error = sum((res - loc_v) .^ 2);



dt = table(trIndex_v', error', 'VariableNames', {'tr', 'err'});
h = grpstats(dt, 'tr', {'mean'}, 'DataVars',{'err'});
h = [h   table([data.trInfo(h.tr).choice]', 'VariableNames', {'choice'})];


p = grpstats(h, 'choice', {'mean'}, 'DataVars',{'mean_err'});

p



inRS1t = IfInBox(loc_v, rewardSiteBox(1, :));
inRS2t = IfInBox(loc_v, rewardSiteBox(2, :));

RS1error = mean(error(inRS1t))/2;
RS2error = mean(error(inRS2t))/2;


pr = sum([data.trInfo(freeChoice).choice]) / sum(freeChoice);


fprintf('Prob of RS1 = %f, Err = %f \n',  pr, RS1error );
fprintf('Prob of RS2 = %f, Err = %f \n\n ',  1-pr, RS2error );



% 1 --> RS1
% 0 --> RS2
% P1353_16p
% Prob of RS1 = 0.200000, Err = 0.316713 
% Prob of RS2 = 0.800000, Err = 0.182061

% P1353_17p
% Prob of RS1 = 0.631579, Err = 0.109231 
% Prob of RS2 = 0.368421, Err = 0.229397 
% Prob of RS1 = 0.631579, Err = 0.059357 
% Prob of RS2 = 0.368421, Err = 0.158877 

Prob of RS1 = 0.631579, Err = 0.080405 
Prob of RS2 = 0.368421, Err = 0.112446


% P1958_25p
% Prob of RS1 = 0.855422, Err = 0.167147 
% Prob of RS2 = 0.144578, Err = 0.578065 
% Prob of RS1 = 0.855422, Err = 0.053775 
% Prob of RS2 = 0.144578, Err = 0.679450 



% P1958_27p
% Prob of RS1 = 0.966667, Err = 0.114630 
% Prob of RS2 = 0.033333, Err = 1.696246
% Prob of RS1 = 0.966667, Err = 0.129900 
% Prob of RS2 = 0.033333, Err = 0.648750 




 0    0         73            0.59503      
 1    1         74            0.15211
 
 
 
