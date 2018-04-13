
clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));
%%

folderPath = 'E:\New folder\P1958_25p\';

%%

load('Ratio.mat')
[data, FTS] = CreateAllData(folderPath, [], 'vtm1.pvd');
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 150, 1);
choice = [data.trInfo.choice];
ramp = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sfc = [data.trInfo.SideOff];

%%
[timestamps, binData, binLoc, trial] = BinData(data, 50, 0);
binLoc = MapToRect(binLoc, trial, data);

binLoc(1, :) = binLoc(1, :) * xRatio;% * 100;
binLoc(2, :) = binLoc(2, :) * yRatio;% * 100;


[timestamps, binData_Org, binLoc, trial] = BinData(data, 50, 1);

xRatio = 114.3 / 3.35;
yRatio = 101.6 / 3.25;


% [binLoc, mu, sigma] = zscore(binLoc, 0, 2);
% plot(binLoc(1, :), binLoc(2, :), '.');

%%
gridWith = [2.7 2.6];
[code, codeMap, gridDim] = GridLocations(binLoc, gridWith);

%%
posTrial = data.trials(choice(data.trials) == 1);
negTrial = data.trials(choice(data.trials) == 0);
minNum = min([numel(posTrial), numel(negTrial)]);

for it = 1:10

selectedPos = randsample(posTrial, minNum);
selectedNeg = randsample(negTrial, minNum);

AllSelected = [selectedPos selectedNeg];

r = rand(1, numel(AllSelected));
trainTrials = AllSelected(r <= 0.8);
testTrials  = AllSelected(r  > 0.8);

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
system('python .\main.py True');
a = load('data_out');
res = a.resValid{end}';
res2 = a.resTrain{end}';

error = loc_v - res;

% error(1, :) = error(1, :) * xRatio(6);
% error(2, :) = error(2, :) * yRatio(6);

%err(it) = sqrt(  sum(sum(error .^ 2)) / numel(error)  );
errNet(it) = mean(sqrt(sum(error .^ 2)));
% errNet(it) = mean(sum(abs(error)));


%%

train = binData_Org(:, trainIndices);
loc_t = binLoc(:, trainIndices);
code_t = code(trainIndices);


valid = binData_Org(:, testIndices);
loc_v = binLoc(:, testIndices);
code_v = code(testIndices);


% prior = GetPrior(code_t, gridDim, 100);
meanFR = GetMeanFiringRateByCell(train, code_t, size(codeMap, 2));

[predCode, probs] = BayesianPrediction(valid, meanFR, []);

res = codeMap(:, predCode);


error = loc_v - res;

% error(1, :) = error(1, :) * xRatio(6);
% error(2, :) = error(2, :) * yRatio(6);

%err(it) = sqrt(  sum(sum(error .^ 2)) / numel(error)  );
errBayes(it) = mean(sqrt(sum(error .^ 2)));
%errBayes(it) = mean(sum(abs(error)));



% errD = sum((loc_v - res) .^ 2);
% 
% % plot3(round(loc_v(1, :) * 50) , round(loc_v(2, :) * 50), errD, '.')
%  
% A(it).pred_v = res;
% A(it).real_v = loc_v;
% A(it).code_v = code_v;
% A(it).trial_v = trial_v;
% 
% A(it).pred_t = res2;
% A(it).real_t = loc_t;
% A(it).code_t = code_t;
% A(it).trial_t = trial_t;
% 
% % Animate(loc_v, res, 0.001, [-3 3 -3 3], 0, trial_v, data.trInfo, [] );
% % sum(sum((loc_t - res2) .^ 2)) / numel(loc_t)
% err(it) = sum(sum((loc_v - res) .^ 2)) / numel(loc_v);
% fprintf('The error for it %d is %f \n', it, err(it));

end

mean(err)

return



% %%
% numIt = 1;
% count = zeros(1, prod(gridDim));
% mse = zeros(1, prod(gridDim));
% for it = 1:numIt    
%     realCode = A(it).code_v;
%     realLoc  = A(it).real_v;
%     predLoc  = A(it).pred_v;
%     
%     for i = 1:prod(gridDim)
%        count(i) = count(i) + sum(realCode == i);
%     end
%     
%     se = sum((predLoc - realLoc) .^ 2);
%     
%     for i = 1:prod(gridDim)
%         mse(i) = mse(i) + sum(se(realCode == i));
%     end      
% end
% 
% mse = mse ./ count;
% badLoc = find(count < 100);
% 
% mse(badLoc) = 0;
% mse(isnan(mse)) = 0;
% 
% mse2 = sqrt(mse);
% 
% avg1 = reshape(mse2, gridDim(2), []);        
% % avg1 = conv2(avg1, ones(4, 4)/16, 'same');        
% avg1 = rot90(avg1, 2);
% avg1 = avg1(:, end:-1:1);
% % avg1([2:5], [2, 3, 5, 6]) = 0;
% % avg1(7) = mean([avg1(6) avg1(14)]);
% % avg1(1) = mean([avg1(2) avg1(8)]);
% 
% figure
% imagesc(avg1)
% colormap jet
% axis equal
% axis tight
% 
%%
% num = floor(length(binData) * 4 / 5);
% train = binData(:, 1:num);
% loc_t = binLoc(:, 1:num);
% 
% indices = randperm(num);
% train = train(:, indices);
% loc_t = loc_t(:, indices);
% 
% valid = binData(:, num + 1:end);
% loc_v = binLoc(:, num + 1:end);
% trial_t = trial(1:num);
% trial_v = trial(num + 1:end);
% ripples_t = ripples(1:num);
% ripples_v = ripples(num + 1:end);
% timepoints_t = timepoints(1:num);
% timepoints_v = timepoints(num+1:end);
% code_t = code(1:num);
% code_v = code(num+1:end);
% loc_v = codeMap(:, code_v);
% loc_t = codeMap(:, code_t);

% AllTrial = 2:numel(data.trInfo);
% trainTrial = AllTrial( mod(AllTrial, 4) < 3);
% testTrial = setdiff(AllTrial, trainTrial);
% 
% trainIndices = ismember(trial, trainTrial);
% testIndices  = ismember(trial, testTrial);
% 
% train = binData(:, trainIndices);
% loc_t = binLoc(:, trainIndices);
% % code_t = code(trainIndices);
% % loc_t = codeMap(:, code_t);
% 
% indices = randperm(length(loc_t));
% train = train(:, indices);
% loc_t = loc_t(:, indices);
% 
% valid = binData(:, testIndices);
% loc_v = binLoc(:, testIndices);
% trial_t = trial(trainIndices);
% trial_v = trial(testIndices);
