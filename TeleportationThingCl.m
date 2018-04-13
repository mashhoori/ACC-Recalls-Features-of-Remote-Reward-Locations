clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));

%%
folderPath = 'E:\New folder\P1958_27p\'; 
data = CreateAllData(folderPath, []);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 10, 1);

%%
[timestamps, binData, binLoc, trial] = BinData(data, 20);
choice = [data.trInfo.choice];
ramp = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];

% plot(binLoc(1, :), binLoc(2, :), '.');
%%

choiceOne = find(choice == 1);
choiceZero = find(choice == 0);
minNum = min(numel(choiceOne), numel(choiceZero));

featureSet = [];

for hhh = 1:25

hhh    
    
selectedOne = randsample(choiceOne, minNum);
selectedZero = randsample(choiceZero, minNum);

selectedTrials = [selectedZero selectedOne];
selectedTrials = sort(selectedTrials);

r = rand(size(selectedTrials));
includedTrials = selectedTrials(r < 0.7);
excludedTrials = selectedTrials(r >= 0.7);

selectedTrialIndex = ismember(trial, selectedTrials);
includedTrialIndex = ismember(trial, includedTrials);
excludedTrialIndex = ismember(trial, excludedTrials);

freeChoiceTrials = find(freeChoice);
forcedChoiceTrials = find(freeChoice == 0);
freeChoiceIndices = ismember(trial, freeChoiceTrials);

vel =  sqrt(sum(diff(binLoc, 1, 2) .^ 2));
vel = [0 vel];

% hist(vel(inRS), 100)

% rewardSiteBox = [-1.6 -1.0 0.6 1.2; 1.1 1.5 0.6 1.2; -0.15 0.15 -1.1 -0.85]; %24
% rewardSiteBox = [-1.6 -0.8 0.5 1.2; 1.4 1.8 0.5 1.2; 0.1 0.4 -1.1 -0.85];    %25
rewardSiteBox = [-1.6 -0.8 0.5 1.2; 1.3 1.9 0.5 1.3; 0.0 0.4 -1.2 -0.5];     %27
% rewardSiteBox = [-1.6 -0.9 0.5 1.2; 1.2 1.9 0.5 1.3; 0.0 0.3 -1.1 -0.7];     %15
% rewardSiteBox = [-2 -1.3 0.6 1.3; 0.8 1.6 0.6 1.3; -0.4 0.1 -1.2 -0.8];      %16
% rewardSiteBox = [-1.5 -0.8 0.5 1.3; 1.2 1.9 0.5 1.3; 0 0.5 -1.2 -0.8];       %17
% rewardSiteBox = [-2 -1.2 0.6 1.3; 0.9 1.7 0.6 1.3; -0.3 0.2 -1.1 -0.7];      %18

inRS1 = IfInBox(binLoc, rewardSiteBox(1, :));
inRS2 = IfInBox(binLoc, rewardSiteBox(2, :));
inRSM = IfInBox(binLoc, rewardSiteBox(3, :));

inRS = inRS1 | inRS2;
inRSA = inRS | inRSM;

value = prctile(vel(inRS), 80);

indHighVel = vel >  value;
indLowVel  = vel <= value;

% prctile(vel(inRS), 80)
% hist(vel(~inRSA), 100)

% plot(binLoc(1, indLowVel), binLoc(2,indLowVel), '.' )
% & ~freeChoiceIndices
% & ~freeChoiceIndices

% r = rand(size(selectedTrialIndex));
trainIndices = indLowVel & includedTrialIndex & inRS; % ) | freeChoiceIndices  ;%(freeChoiceIndices .* (rand(size(freeChoiceIndices)) < 0.4 ));%  ;
testIndices  = indLowVel & inRS & excludedTrialIndex ;% ;& selectedTrialIndex ~freeChoiceIndices( selectedTrialIndex .* (r >= 0.7)

train = binData(:, trainIndices);
loc_t = binLoc(:, trainIndices);

% loc_t(:, loc_t(1, :) < 0) = repmat(mean(loc_t(:, loc_t(1, :) < 0), 2), 1, sum(loc_t(1, :) < 0));
% loc_t(:, loc_t(1, :) > 0) = repmat(mean(loc_t(:, loc_t(1, :) > 0), 2), 1, sum(loc_t(1, :) > 0));


valid = binData(:, testIndices);
loc_v = binLoc(:, testIndices);
trIndex_t = trial(trainIndices);
trIndex_v = trial(testIndices);
timestamp_v = timestamps(testIndices);




% Animate(loc_v, res, 0.005, [-3 3 -3 3], 0, trIndex_v, data.trInfo, []);



% valid( [1 2 6 7], :) = 0;
% train( [1 2 6 7], :) = 0;

save('data', 'train', 'loc_t', 'valid', 'loc_v');
system('python C:\Users\a.mashhoori\Desktop\Proj\Scripts\main.py');
a = load('data_out');

% W = load('weights');

% G = table(sum(((res - loc_v) .^ 2), 1)', trIndex_v', 'VariableNames', {'err', 'trial'});
% HH = grpstats(G, 'trial', 'mean');
% 
% trailTable = table([1:numel(data.trInfo)]', choice', ramp', reward', 'VariableNames', {'trial', 'choice', 'ramp', 'reward'});
% 
% UU = join(HH, trailTable);

%%
res = a.res';
res2 = a.res2';

%%
marker = MarkReplay2(loc_v, res, trIndex_v, rewardSiteBox);
% 
 startIdx = find(marker == 1);
 endIdx   = find(marker == 2);
% 
 startTime = timestamp_v(startIdx);
 trials = unique(trIndex_v(startIdx));
% 
% sideOff = [data.trInfo.SideOff];

%%
ThingiForcedTrials = trials(ismember(trials, forcedChoiceTrials));
ThingiFreeTrials = trials(ismember(trials, freeChoiceTrials));
% 
% % ThingiForcedTrials = trS(ismember(trS, forcedChoiceTrials));
% % ThingiFreeTrials = trS(ismember(trS, freeChoiceTrials));

validTrials = unique(trIndex_v);

tr{hhh} =  trials;
tr_c{hhh} = validTrials; 

% %%
% listInd = [];
% for i = 1:numel(startIdx)
%      if(choice(trIndex_v(startIdx(i))) == 0)%  && ramp(trIndex_v(startIdx(i))) == 0 && reward(trIndex_v(startIdx(i))) == 0)
%         listInd = [listInd startIdx(i):endIdx(i)];
%      end
% end
% 
% indices_a = zeros(1, length(valid));
% indices_a(listInd) = 1;
% 
% err{hhh} = sum((res - loc_v) .^ 2);
% trIndex{hhh} = trIndex_v;
% a = valid(:, indices_a == 1 & err > 0.3);
% indices = ismember(trIndex_v, setdiff(validTrials(choice(validTrials) == 0), trials));% & ramp(validTrials) == 0 & reward(validTrials) == 0)
% indices = ismember(trIndex_v, setdiff(validTrials, trials));%
% indices2 = indices & (err < 0.05);
% b = valid(:, indices2);
% 
% y_a = ones(1, length(a));
% y_b = zeros(1, length(b));
% 
% indices = randsample(1:numel(y_b), numel(y_a));
% y_b = y_b(indices);
% b = b(:, indices);
% 
% train_all = [a, b];
% y_all = [y_a y_b];
% 
% randIndices = randperm(length(train_all));
% train_all = train_all(:, randIndices);
% y_all = y_all(randIndices);

% [B, FitInfo] = lassoglm(train_all' ,y_all', 'binomial', 'CV', 4, 'DFmax', 15, 'Options', statset('UseParallel', true));
% 
% % output_a = SimulateNetwork(a, W);
% % output_b = SimulateNetwork(b, W);
% 
% nNonZeroF = sum(B ~= 0);
% ind = find(nNonZeroF >= 10 & nNonZeroF <= 15, 1,'last' );
% featureSet{hhh} = find(B(:, ind));


kkk(hhh) = sum([data.trInfo(ThingiForcedTrials).choice]) / numel(ThingiForcedTrials);
uuu(hhh) = sum([data.trInfo(ThingiFreeTrials).choice]) / numel(ThingiFreeTrials);
ttt(hhh) = sum([data.trInfo(freeChoice).choice]) / sum(freeChoice);


end

total = zeros(1, numel(data.trInfo));
numThingi = zeros(1, numel(data.trInfo));
for i = 1:25
    numThingi(tr{i}) = numThingi(tr{i}) + 1;
    total(tr_c{i}) = total(tr_c{i}) + 1;
end



totalNum = zeros(1, numel(data.trInfo));
errTrial = zeros(1, numel(data.trInfo));
for i = 1:25
    
    for j = 1:numel(totalNum)
        
        totalNum(j) = totalNum(j) + sum(trIndex{hhh} == j);
        errTrial(j) = errTrial(j) + sum(err{hhh}(trIndex{hhh} == j));
        
    end
        
%     numThingi(tr{i}) = numThingi(tr{i}) + 1;
%     total(tr_c{i}) = total(tr_c{i}) + 1;
end

avgError = errTrial ./ (totalNum + eps);

mirg = [1:numel(totalNum); avgError; totalNum];
mirg(:, mirg(3, :) == 0) = [];

[~, bing] = sort(mirg(2, :));
mirg = mirg(:, bing);

return
%%

importance = zeros(1, size(d, 1));
for i = 1:20
    importance( featureSet{i} ) = importance( featureSet{i} ) + 1;
end



[importance, feature] = sort(importance, 'descend');
[importance', feature']'

save('featImp_25_1', 'importance', 'feature');

%%

return
%%
% 
% sum([data.trInfo(trials).choice]) / numel(trials)
% sum([data.trInfo(trials).durTrial]) / numel(trials)

%sum(~freeChoice)
% selTrial = [8 9  21 22 27 37 41 43 52 66 83 98 100];
% loc_v_s = loc_v(:, ismember(trIndex_v, selTrial));
% res_s = res(:, ismember(trIndex_v, selTrial));
% trIndex_v_s =  trIndex_v(ismember(trIndex_v, selTrial));
% % Animate(loc_v_s, res_s, 0.008, [-3 3 -3 3], 1) ; , trIndex_v_s, data.trInfo);

% a = [0.527778 0.855422 0.966667 0.600000 0.200000 0.631579 0.252632];
% b = [56 41 31 48 67 50 57];
% plot(a, 100 - b, '*')
% 
% 
% mt = [];
% validtrials = unique(trIndex_v);
% for i = 1:numel(validtrials)
%     l(i) = sum(trIndex_v == validtrials(i));
%     a = mean(valid(:, trIndex_v == validtrials(i)), 2);
%     mt = [mt a];    
% end
% 
% 
% plot( mean(mt(impCells.cellsReward, ismember(validtrials, trials)), 2) )
% hold on
% plot( mean(mt(impCells.cellsReward, ~ismember(validtrials, trials)), 2) )
% 
% plot(mean(valid(choiceCells, ismember(trIndex_v, trials))));
% hold on
% plot(mean(valid(choiceCells, ~ismember(trIndex_v, trials))));
% 
% 
% mat = [output_a{3} output_b{3}]';
% [coeff, score_all, latent] = pca(zscore(mat));
% % coeff2 = coeff;
% % coeff2(abs(coeff2) < 0.218) = 0;
% pp = zscore(mat);
% score_2 =  pp(:, [49,50]); %zscore(mat)* coeff2;
% 
% score_a = score_2(1:length(output_a{2}),:);
% score_b = score_2(length(output_a{2})+1:end,:);
% 
% for i=1:50
%     plot(score_a(:,i), score_a(:,i+1), '.r', 'MarkerSize', 6)
%     hold on
%     plot(score_b(:,i), score_b(:,i+1), '.b', 'MarkerSize', 4)
%     title(num2str(i))
%     pause(2)
%     close
% end
% 
% 
% plot(mean(output_a{3}, 2))
% hold on
% plot(mean(output_a{3}, 2) + std(output_a{3}, [], 2), 'b')
% plot(mean(output_a{3}, 2) - std(output_a{3}, [], 2), 'b')
% 
% 
% plot(mean(output_b{3}, 2))
% 
% [[1:50]' mean(output_a{3}, 2) mean(output_b{3}, 2) std(output_a{3}, [], 2) std(output_b{3}, [], 2) h']
% 
% 
% plot(output_a{5}(1,:), output_a{5}(2,:), '.')
% hold on
% plot(output_b{5}(1,:), output_b{5}(2,:), '.')
% 
% 
% 
% plot3(score_a(:,6), score_a(:,7), score_a(:,8), '.')
% hold on
% plot3(score_b(:,6), score_b(:,7), score_b(:,8), '.')
% 
% 
% 
% plot(err)
% hold on
% plot(startIdx, 1, '*')
% plot(endIdx, 2, 'o')
% 
% for hjk = 1:size(a, 1)
% %   [h(hjk) p(hjk)] = ttest2(b(hjk, indices(1:numel(indices) / 2))', b(hjk, indices((numel(indices) / 2)+1:end))', 'Alpha', 0.01); 
%     [h(hjk) p(hjk)] = ttest2(b(hjk, 1:1000), b(hjk, 1300:end)', 'Alpha', 0.01); 
%     
% %     plot(a(hjk, :))
% %     hold on
% %     plot(b(hjk, :))
% %     title(num2str(h(hjk)))
% %     pause(3);
% %     close
% end
% 
% tt = find(h);
% yy = find(h);
% 
% 
% % for hjk = 1:50
% %     [h(hjk) p(hjk)] = ttest2(output_a{3}(hjk, :), output_b{3}(hjk, :), 'Alpha', 0.01);    
% % end
% 
% 
% plot(mean(valid(:, listInd), 2), '.');
% hold on
% plot(mean(valid(:, setdiff(1:length(valid), listInd) ), 2), '*');


%  5    27    40    31     1     3    51
