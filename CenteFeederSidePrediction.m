clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));

%%
folderPath = 'E:\New folder\P1958_25p\'; 
data = CreateAllData(folderPath, []);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 120, 1);

%%
[timestamps, binData, binLoc, trial] = BinData(data, 20);
choice = [data.trInfo.choice];
ramp = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sideOff = [data.trInfo.SideOff];

%%
AllInd = [];
for i=1:numel(data.trials)    
   ind = find(timestamps > sideOff(data.trials(i))-0 & timestamps < (sideOff(data.trials(i)) + 2000));
    AllInd = [AllInd ind];
end
sData = binData(:, AllInd);
sTrials = trial(AllInd);
sChoices = choice(sTrials);

choiceOne = data.trials(choice(data.trials) == 1);
choiceZero = data.trials(choice(data.trials) == 0);
minNum = min(numel(choiceOne), numel(choiceZero));


for it = 1:100    
    it
    
    selectedOne = randsample(choiceOne, floor(minNum  * 1));
    selectedZero = randsample(choiceZero, floor(minNum * 1));

    selectedTrials = [selectedZero selectedOne];
    selectedTrials = sort(selectedTrials);

    r = rand(size(selectedTrials));
    trainTrials = selectedTrials(r < 0.7);
    testTrials = selectedTrials(r >= 0.7);
    
%     [choicePro_Tr(it) rewardPro_Tr(it) rampPro_Tr(it) freePro_Tr(it)] = ComputeStatistics(trainTrials, choice, reward, ramp, freeChoice);
%     [choicePro_Ts(it) rewardPro_Ts(it) rampPro_Ts(it) freePro_Ts(it)] = ComputeStatistics(testTrials,  choice, reward, ramp, freeChoice);
%     
    
    trainIndices = ismember(sTrials, trainTrials);
    testIndices = ismember(sTrials, testTrials);    
    
    train = sData(:, trainIndices);
    target_t = sChoices(trainIndices);

    valid = sData(:, testIndices);
    target_v = sChoices(testIndices);
    trial_t = sTrials(trainIndices);
    trial_v = sTrials(testIndices);
    
    
    [B, FitInfo] = lassoglm(train', target_t', 'binomial', 'CV', 4, 'DFmax', 10, 'Options', statset('UseParallel', true));%'NumLambda' , 25);
    ind = FitInfo.IndexMinDeviance; 

    preds = glmval([FitInfo.Intercept(ind); B(:, ind)], valid', 'logit');% > 0.5;
    predsTmp = preds;
    predsTmp(target_v(:) == 0) = 1 - predsTmp(target_v(:) == 0);
    
    tbl = table(trial_v(:), predsTmp(:), 'VariableNames', {'tr', 'prob'});
    tbl2 = grpstats(tbl, 'tr', {'min', 'std', 'mean'});
    tbl2.('diff') = tbl2.mean_prob - tbl2.min_prob;
    
    tbl2 = sortrows(tbl2 ,[6], 'descend');
    
    trSelected = tbl2.tr(1:10);
%     trSelected = tbl2.tr(tbl2.min_prob < 0.2) ;
    
    
    
%     crossOne(it) = mean(log(preds(target_v(:) == 1)));
%     crossZero(it) = mean(log( 1 - preds(target_v(:) == 0)));    
%     
%     acc(it) = sum((preds(:) >= 0.5) == target_v(:))/ numel(target_v(:)); 
% 
%     res = MarkConfusion(preds(:)~= target_v(:), trial_v);

%     tbl = table(res(1, :)', res(2, :)', 'VariableNames', {'tr', 'res'});
%     tbl2 = table([1:numel(data.trInfo)]', choice(:), ramp(:), reward(:), freeChoice(:), 'VariableNames', {'tr', 'choice', 'ramp', 'reward', 'free'} );
%     tbl3 = join(tbl, tbl2);

    %cP(it) = sum(tbl3.choice(tbl3.res > 0))/ sum(tbl3.res > 0);
    cP(it) = sum(choice(trSelected))/ numel(trSelected);
    
%     rdP(it) = sum(tbl3.reward(tbl3.res > 0))/ sum(tbl3.res > 0);
%     rpP(it) = sum(tbl3.ramp(tbl3.res > 0))/ sum(tbl3.res > 0);
%     fP(it) = sum(tbl3.free(tbl3.res > 0))/ sum(tbl3.res > 0);
%     
    cP(it)
%     
%     cnt{it} = tbl3.tr(tbl3.res > 0);
%     ttl{it} = tbl3.tr;
    
end

fprintf('Choice %f, Reward %f, Ramp %f, free %f \n', mean(cP), mean(rdP), mean(rpP), mean(fP));

count = zeros(1, numel(data.trInfo));
total = zeros(1, numel(data.trInfo));
for i= 1:100
   total(ttl{i}) = total(ttl{i}) + 1;
   count(cnt{i}) = count(cnt{i}) + 1;
end

TT = find(total >= 10 & (count ./ (total + 1)) >= 0.9 );

tbl = table(TT', 'VariableNames', {'tr'});
tbl2 = table([1:numel(data.trInfo)]', choice(:), ramp(:), reward(:), freeChoice(:), 'VariableNames', {'tr', 'choice', 'ramp', 'reward', 'free'} );
tbl3 = join(tbl, tbl2);

return
% 
% AllTrial = find(freeChoice == 0);%data.trials;
% trainTrial = AllTrial(ismember(mod(AllTrial, 4), [2, 3]));
% ComputeStatistics(trainTrial, choice, reward, ramp, freeChoice);
% testTrial = union(setdiff(AllTrial, trainTrial), find(freeChoice == 1));%,  
% ComputeStatistics(testTrial, choice, reward, ramp, freeChoice);
% 
% trainIndices = ismember(sTrials, trainTrial);
% testIndices  = ismember(sTrials, testTrial);
% 
% train = sData(:, trainIndices);
% target_t = sChoices(trainIndices);
% 
% valid = sData(:, testIndices);
% target_v = sChoices(testIndices);
% trial_t = sTrials(trainIndices);
% trial_v = sTrials(testIndices);
% 
% [B, FitInfo] = lassoglm(train', target_t', 'binomial', 'CV', 4, 'DFmax', 40, 'Options', statset('UseParallel', true));%'NumLambda' , 25);
% ind = FitInfo.IndexMinDeviance; 
% 
% preds = glmval([FitInfo.Intercept(ind); B(:, ind)], valid', 'logit') > 0.5;
% acc = sum(preds(:) == target_v(:))/ numel(target_v(:)); 
% 
% res = MarkConfusion(preds(:)~= target_v(:), trial_v);
% 
% tbl = table(res(1, :)', res(2, :)', 'VariableNames', {'tr', 'res'});
% tbl2 = table([1:numel(data.trInfo)]', choice(:), ramp(:), reward(:), freeChoice(:), 'VariableNames', {'tr', 'choice', 'ramp', 'reward', 'free'} );
% tbl3 = join(tbl, tbl2);
% 
% cP = sum(tbl3.choice(tbl3.res > 0))/ sum(tbl3.res > 0);
% rdP = sum(tbl3.reward(tbl3.res > 0))/ sum(tbl3.res > 0);
% rpP = sum(tbl3.ramp(tbl3.res > 0))/ sum(tbl3.res > 0);
% fP = sum(tbl3.free(tbl3.res > 0))/ sum(tbl3.res > 0);
% 
% fprintf('Choice %f, Reward %f, Ramp %f, free %f \n', cP, rdP, rpP, fP);
% 
% return

% tbl = table(trial_v(:), preds(:)~= target_v(:), 'VariableNames', {'tr', 'res'});
% tbl2 = table([1:numel(data.trInfo)]', choice(:), ramp(:), reward(:), freeChoice(:), 'VariableNames', {'tr', 'choice', 'ramp', 'reward', 'free'} );
% 
% grpTbl = grpstats(tbl, 'tr', 'mean');
% tbl3 = join(grpTbl, tbl2);
% 
% sum(tbl3.choice(tbl3.mean_res > 0))/ sum(tbl3.mean_res > 0)
% 

%%
return
% 
% rewardSiteBox = [-1.6 -1.0 0.6 1.2; 1.1 1.5 0.6 1.2; -0.15 0.15 -1.1 -0.85]; %24
% % rewardSiteBox = [-1.6 -0.8 0.5 1.2; 1.4 1.8 0.5 1.2; 0.1 0.4 -1.1 -0.85];    %25
% % rewardSiteBox = [-1.6 -0.8 0.5 1.2; 1.3 1.9 0.5 1.3; 0.0 0.4 -1.2 -0.5];     %27
% %  rewardSiteBox = [-1.6 -0.9 0.5 1.2; 1.2 1.9 0.5 1.3; 0.0 0.3 -1.1 -0.7];     %15
% % rewardSiteBox = [-2 -1.3 0.6 1.3; 0.8 1.6 0.6 1.3; -0.4 0.1 -1.2 -0.8];      %16
% % rewardSiteBox = [-1.5 -0.8 0.5 1.3; 1.2 1.9 0.5 1.3; 0 0.5 -1.2 -0.8];       %17
% % rewardSiteBox = [-2 -1.2 0.6 1.3; 0.9 1.7 0.6 1.3; -0.3 0.2 -1.1 -0.7];      %18
% 
% inRS1 = IfInBox(binLoc, rewardSiteBox(1, :));
% inRS2 = IfInBox(binLoc, rewardSiteBox(2, :));
% inRS3 = IfInBox(binLoc, rewardSiteBox(3, :));
% 
% inRS = inRS1 | inRS2;
% 
% freeChoiceTrials = find(freeChoice);
% freeChoiceIndices = ismember(trial, freeChoiceTrials);
% 
% % allData = binData(:, inRS | inRS3);
% target = choice(trial);
% % targetTrial = trial(inRS | inRS3);
% plot(binLoc(1, :), binLoc(2, :), '.')
% %%
% 
% AllTrial = find(freeChoice == 0);
% trainTrial = AllTrial(ismember(mod(AllTrial, 4), [2, 3]));
% ComputeStatistics(trainTrial, choice, reward, ramp, freeChoice);
% testTrial = union(setdiff(AllTrial, trainTrial), find(freeChoice == 1));
% ComputeStatistics(testTrial, choice, reward, ramp, freeChoice);
% 
% trainIndices = ismember(trial, trainTrial) & inRS;
% testIndices  = ismember(trial, testTrial) & inRS;
% 
% train = binData(:, trainIndices);
% target_t = target(trainIndices);
% 
% indices = randperm(length(target_t));
% train = train(:, indices);
% target_t = target_t(:, indices);
% 
% valid = binData(:, testIndices);
% target_v = target(testIndices);
% trial_t = trial(trainIndices);
% trial_v = trial(testIndices);
% 
% %%
% 
% code_t = target_t + 1;
% meanFR = GetMeanFiringRateByCell(train, code_t, 2);
% [preds, probs] = BayesianPrediction(valid, meanFR, []);
% 
% preds = preds - 1;
% res = preds(:) == target_v(:);
% sum(res) / numel(res)
% 
% tbl = table(trial_v(:), preds(:), 'VariableNames', {'tr', 'res'});
% tbl2 = table([1:numel(data.trInfo)]', choice(:), ramp(:), reward(:), freeChoice(:), 'VariableNames', {'tr', 'choice', 'ramp', 'reward', 'free'} );
% 
% grpTbl = grpstats(tbl, 'tr', 'mean');
% tbl3 = join(grpTbl, tbl2);
% 
% sum(tbl3.mean_res > 0.5) / numel(tbl3.mean_res)
% 
% %%
% [B, FitInfo] = lassoglm(train', target_t', 'binomial', 'CV', 4, 'DFmax', 40, 'Options', statset('UseParallel', true));%'NumLambda' , 25);
% nNonZeroF = sum(B ~= 0);
% ind = FitInfo.IndexMinDeviance; 
% 
% h = B(:, ind) ~= 0;
% 
% preds = glmval([FitInfo.Intercept(ind); B(:, ind)], valid', 'logit') > 0.5;
% acc = sum(preds(:) == target_v(:))/ numel(target_v(:)); 
% 
% res = preds(:) ~= target_v(:);
% 
% tbl = table(trial_v(:), preds(:), 'VariableNames', {'tr', 'res'});
% tbl2 = table([1:numel(data.trInfo)]', choice(:), ramp(:), reward(:), freeChoice(:), 'VariableNames', {'tr', 'choice', 'ramp', 'reward', 'free'} );
% 
% grpTbl = grpstats(tbl, 'tr', 'mean');
% tbl3 = join(grpTbl, tbl2);
% 
% sum(tbl3.mean_res > 0.5) / numel(tbl3.mean_res)
% 
% % corr(tbl3.max_res, tbl3.choice)
% % corr(tbl3.max_res, tbl3.reward)
% % corr(tbl3.max_res, tbl3.ramp)
% % corr(tbl3.max_res, tbl3.free)
% % 
% tbl4 = grpstats(tbl3, 'choice', 'mean')
