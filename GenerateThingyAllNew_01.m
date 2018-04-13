clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));

%%
% folderPath = 'E:\New folder\P1958_25p\';

folderNames = {'P1353_15p', 'P1353_16p', 'P1353_17p', 'P1353_18p', 'P1958_24p', 'P1958_25p', 'P1958_27p'};
% outputNames = {'thN15p100', 'thN16p100', 'thN17p100', 'thN18p100', 'thN24p100', 'thN25p100', 'thN27p100'};
% outputNames = {'thN15p75', 'thN16p75', 'thN17p75', 'thN18p75', 'thN24p75', 'thN25p75', 'thN27p75'};
outputNames = {'thN15p75_50', 'thN16p75_50', 'thN17p75_50', 'thN18p75_50', 'thN24p75_50', 'thN25p75_50', 'thN27p75_50'};

for rat = 7:numel(folderNames)

fprintf('rat %d \n ', rat);
folderPath = ['E:\New folder\' folderNames{rat} '\']; 

data = CreateAllData(folderPath, []);
% dorg = data.data(data.dataIndex, :);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 120, 1);
%%
[timestamps, binData, binLoc, trial] = BinData(data, 20, 0);
choice = [data.trInfo.choice];
ramp   = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sideOff    = [data.trInfo.SideOff];
centerOff  = [data.trInfo.centralOff];

binLoc = MapToRect(binLoc, trial, data);

plot(binLoc(1, :), binLoc(2, :), '.');

choiceOneLow  = data.trials(choice(data.trials) == 1 & reward(data.trials) == 0 & freeChoice(data.trials) == 0);
choiceZeroLow = data.trials(choice(data.trials) == 0 & reward(data.trials) == 0 & freeChoice(data.trials) == 0);

choiceOneHigh  = data.trials(choice(data.trials) == 1 & reward(data.trials) == 1 & freeChoice(data.trials) == 0);
choiceZeroHigh = data.trials(choice(data.trials) == 0 & reward(data.trials) == 1 & freeChoice(data.trials) == 0);

minNumLow     = min(numel(choiceOneLow), numel(choiceZeroLow));
minNumHigh    = min(numel(choiceOneHigh), numel(choiceZeroHigh));

minNum = min(minNumLow, minNumHigh);

ooo = [];
jjj = [];
kkk = [];

for hhh = 1:5

hhh
   
selectedOneLow  = randsample(choiceOneLow , minNum);
selectedZeroLow = randsample(choiceZeroLow, minNum);
selectedOneHigh  = randsample(choiceOneHigh , minNum);
selectedZeroHigh = randsample(choiceZeroHigh, minNum);

selectedTrials = [selectedZeroLow selectedOneLow selectedZeroHigh selectedOneHigh];


rewardArray = zeros(1, length(timestamps));
selector = false(1, length(timestamps));
for tt = 1:numel(sideOff)
    ind = timestamps > sideOff(tt) & timestamps <= (sideOff(tt) + 20*75);
    selector(ind) = true;
    rewardArray(ind) = reward(tt) + 1;
end





selectedIndices = ismember(trial, selectedTrials);

freeChoiceTrials   = find(freeChoice);
forcedChoiceTrials = find(freeChoice == 0);

trainIndices =   selector & ismember(trial, selectedTrials);
testIndices  = (selector & ~ismember(trial, selectedTrials));



train = binData(:, trainIndices);
loc_t = binLoc (:, trainIndices);
reward_t = rewardArray(trainIndices);

dataShit = [train; reward_t];

% trIndex_t = trial(trainIndices);

indices = randperm(length(loc_t));
train = train(:, indices);
loc_t = loc_t(:, indices);


valid = binData(:, testIndices);
 loc_v = binLoc(:, testIndices) ;
trIndex_v = trial(testIndices) ;
timestamp_v = timestamps(testIndices);

% Animate(loc_v, res, 0.005, [-3 3 -3 3], 0, trIndex_v, data.trInfo, []);


save('data', 'train', 'loc_t', 'valid', 'loc_v');
system('python E:\Proj\Scripts\main.py True ./modelWeights');
a = load('data_out');
res = a.resValid{end}' ;
res2 = a.resTrain{end}';
% 
% w = load('weights');
% valid2 = valid;
% 
% output = SimulateNetwork(valid, w); 
% neuronGrad = BackPropagateGradient(w, output, [1 0]');
%%
% res = a.res'  ;
% res2 = a.res2';

% err = sum((res2 - loc_t) .^ 2);
% tbl = table(trIndex_t(:), err(:), 'VariableNames', {'tr', 'err'});
% tbl2 = grpstats(tbl, 'tr', 'mean');
% errorRatio_t(hhh) = mean(tbl2.mean_err(choice(tbl2.tr) == 1)) / mean(tbl2.mean_err(choice(tbl2.tr) == 0));

% err = sum((res - loc_v) .^ 2);
% tbl = table(trIndex_v(:), err(:), 'VariableNames', {'tr', 'err'});
% tbl2 = grpstats(tbl, 'tr', 'mean');
% errorRatio_v(hhh) = mean(tbl2.mean_err(choice(tbl2.tr) == 1)) / mean(tbl2.mean_err(choice(tbl2.tr) == 0));

marker = MarkReplay3(loc_v, res, trIndex_v);
% 
startIdx = find(marker == 1);
endIdx   = find(marker == 2);
% 
startTime = timestamp_v(startIdx);
trials = unique(trIndex_v(startIdx)); 
% 
validTrials = unique(trIndex_v);

ind = zeros(size(marker));
for i = 1:numel(startIdx)
    ind(startIdx(i):endIdx(i)) = 1;
end

ThingiForcedTrials = trials(ismember(trials, forcedChoiceTrials));
ThingiFreeTrials = trials(ismember(trials, freeChoiceTrials));

tr{hhh} =  trials;
tr_c{hhh} = validTrials; 

loc_val{hhh}  = loc_v;
pred_val{hhh} = res;


ooo(hhh) = (sum([data.trInfo(trials).choice]) / numel(trials))     /   (   sum([data.trInfo(validTrials ).choice]) / numel(validTrials )   );
jjj(hhh) = (numel(ThingiForcedTrials) / numel(trials)) /   (   sum(~[data.trInfo(validTrials).freeChoice] ) / numel(validTrials )   )     ;
kkk(hhh) = (numel(ThingiFreeTrials) / numel(trials)) /   (   sum([data.trInfo(validTrials ).freeChoice]) / numel(validTrials )   )     ;

lll(hhh) = sum([data.trInfo(trials).durTrial]) / sum([data.trInfo(validTrials).durTrial]); %    /   (   sum([data.trInfo( validTrials ).choice]) / numel(validTrials )   );
mmm(hhh) = sum(~[data.trInfo(trials).durTrial]) / sum(~[data.trInfo(validTrials).durTrial]);

ttt(hhh) = sum([data.trInfo(trials).choice]) / sum([data.trInfo(validTrials).choice]); %    /   (   sum([data.trInfo( validTrials ).choice]) / numel(validTrials )   );
nnn(hhh) = sum(~[data.trInfo(trials).choice]) / sum(~[data.trInfo(validTrials).choice]);

qqq(hhh) = sum([data.trInfo(trials).rampTrial] > 0) / sum([data.trInfo(validTrials).rampTrial] > 0); %    /   (   sum([data.trInfo( validTrials ).choice]) / numel(validTrials )   );
rrr(hhh) = sum([data.trInfo(trials).rampTrial] == 0) / sum([data.trInfo(validTrials).rampTrial] == 0);

%kkk(hhh) = (numel(ThingiFreeTrials) / numel(trials)) /   (   sum([data.trInfo(validTrials ).freeChoice]) / numel(validTrials )   )     ;


%ttt(hhh) = (sum([data.trInfo(freeChoiceTrials).choice]) / numel(freeChoiceTrials))  /    (   sum([data.trInfo(freeChoiceTrials).choice]) / numel(freeChoiceTrials)   ) ;
% kkk(hhh) = sum([data.trInfo(ThingiForcedTrials).choice]) / numel(ThingiForcedTrials) /  (   sum([data.trInfo(ThingiForcedTrials).choice]) / numel(ThingiForcedTrials)   ) ;



% uuu(hhh) = sum([data.trInfo(ThingiFreeTrials).choice]) / numel(ThingiFreeTrials);


 end
% mean(errorRatio_t)
% mean(errorRatio_v)
mean(ooo)
mean(jjj)
mean(kkk)
mean(lll)
mean(mmm)

% save(outputNames{rat}, 'tr', 'tr_c', 'sig0', 'sig1', 'loc_val', 'pred_val', 'ooo', 'jjj', 'kkk');
end

return;

% 1.1891, 1.0221, 0.9759
% 1.1182, 1.0461, 0.9461
% 1.2200, 1.0090, 0.9901
% 0.5684, 0.8618, 1.1716
% % ====================
% 0.6309, 0.9891, 1.0100
% 0.8560, 0.8323, 1.1676
% 0.5954, 1.3044, 0.6590
 

% 0.5511 0.2698;  0.7971 0.3051;  
% 0.3512 0.5629;  0.2929 0.7771;  3.2727 5.6178
% 0.1860 0.2538;  0.7872 0.2957;  5.6596 2.8174
% 0.2825 0.5106;  0.3077 0.7895;
% 0.1824 0.5694;  0.4388 0.7789;
% 0.3949 0.4097;  0.7746 0.3902;
% 0.0965 0.4533;  0.2110 0.8113;


% importance = zeros(1, size(dorg, 1));
% for i = 1:25
%     importance( sig0{i} ) = importance( sig0{i} ) + 1;
%     importance( sig1{i} ) = importance( sig1{i} ) + 1;
% end
% 
% [importance, feature] = sort(importance, 'descend');
% [importance', feature']'
% 
% figure;plot(neuronGrad{1}(:, trIndex_v == hht)')
% 
% hht = 201;
% figure
% subplot(2, 1, 1)
% plot(output{5}(:, trIndex_v == hht)')
% hold on
% plot(marker(trIndex_v == hht)' * 2)
% 
% subplot(2, 1, 2)
% plot((output{1}(jjj, trIndex_v == hht))')
% hold on
% plot(marker(trIndex_v == hht)' * 0.1)
% grid on
% figure
% b = dorg(data.dataIndex, data.data(data.timeIndex,  :) > sideOff(hht) & data.data(data.timeIndex,  :) < sideOff(hht) + 2000 );
% plotSpikeRaster(b == 1, 'PlotType', 'vertline');
% 
% data.data( data.trialIndex, data.data(data.timeIndex,  :) > sideOff(hht))
% 
% 
% figure;
% p1 = subplot(2,1,1)
% plot(output{3}( 33, :)')
% p2 = subplot(2,1,2)
% plot(output{5}(1 , :)')
% linkaxes([p1, p2], 'x')
% 
% % target = ismember(validTrials, trials);
% % 
% % 
% % mt0 = []; mt1 = []; tr1 = []; tr0 = []; ccc = 1; jj = 1; kk = 1;
% % for nnn = 1:numel(validTrials)
% %   if(choice(validTrials(nnn)) == 0) 
% %       if(target(nnn) == 0)
% %            mt0(:, jj) = mean(valid(:, trIndex_v == validTrials(nnn)), 2);
% %            tr0(jj) = 0;
% %       else
% %            mt0(:, jj) = mean(valid(:, startIdx(ccc):endIdx(ccc)), 2);
% %            tr0(jj) = 1;
% %            ccc = ccc + 1;
% %       end      
% %       jj = jj + 1;
% %   else
% %       if(target(nnn) == 0)
% %            mt1(:, kk) = mean(valid(:, trIndex_v == validTrials(nnn)), 2);
% %            tr1(kk) = 0;
% %       else
% %            mt1(:, kk) = mean(valid(:, startIdx(ccc):endIdx(ccc)), 2);
% %            tr1(kk) = 1;
% %            ccc = ccc + 1;
% %       end      
% %       kk = kk + 1;      
% %   end    
% % end
% % 
% % weights = ones(1, numel(tr0));
% % weights(tr0 == 0) = (sum(tr0)/sum(~tr0)); %(sum(~tr0)/numel(tr0))
% % weights = weights / sum(weights);
% % 
% % [B, FitInfo] = lassoglm(mt0' ,tr0', 'binomial', 'CV', 4 , 'Weights', weights, 'DFmax', 20, 'Options', statset('UseParallel', true));%'NumLambda' , 25);
% % ind = FitInfo.IndexMinDeviance;
% % featureSet0{hhh} = find(B(:, ind));
% % 
% % preds = glmval([FitInfo.Intercept(ind); B(:, ind)], mt0', 'logit') >= 0.5;
% % sum(preds(:) == tr0(:))/ numel(tr0(:))
% % 
% % weights = ones(1, numel(tr1));
% % weights(tr1 == 0) = (sum(tr1)/sum(~tr1)); %(sum(~tr1)/numel(tr1))
% % weights = weights / sum(weights);
% % 
% % [B, FitInfo] = lassoglm(mt1' ,tr1', 'binomial', 'CV', 4 , 'Weights', weights, 'DFmax', 30, 'Options', statset('UseParallel', true));%'NumLambda' , 25);
% % ind = FitInfo.IndexMinDeviance;
% % featureSet1{hhh} = find(B(:, ind));
% % 
% % preds = glmval([FitInfo.Intercept(ind); B(:, ind)], mt1', 'logit') >= 0.5;
% % sum(preds(:) == tr1(:))/ numel(tr1(:))
% % 
% % tr_all = [trials setdiff(validTrials, trials) ];
% % for c = 46:55
% %     
% % figure
% % mt = zeros(numel(tr_all), 100);
% % 
% % for gfd = 1:numel(tr_all)
% %    
% %     if(gfd  <= numel(trials))
% %         ind = data.data(data.timeIndex,  :) >= startTime(gfd) & data.data(data.timeIndex,  :) < startTime(gfd) + 100;   
% %         mt(gfd, :) = dorg(c, ind);
% %     else
% %          ind = data.data(data.timeIndex,  :) >= sideOff(tr_all(gfd)) & data.data(data.timeIndex,  :) < sideOff(tr_all(gfd)) + 100;   
% %          mt(gfd, :) = dorg(c, ind);
% %     end   
% %    
% % end
% % 
% % plotSpikeRaster(mt == 1, 'PlotType', 'vertline');
% % % title([num2str(c) ' '  num2str(mean(sum(mt(1:numel(tr_T_01), :), 2))) ' '  num2str(mean(sum(mt(numel(tr_T_01)+1:end, :), 2))) ])
% % 
% % end