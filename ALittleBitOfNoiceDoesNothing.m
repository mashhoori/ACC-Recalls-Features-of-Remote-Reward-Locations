clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));

%%

folderNames = {'P1353_15p', 'P1353_16p', 'P1353_17p', 'P1353_18p', 'P1958_24p', 'P1958_25p', 'P1958_27p'};
outputNames = {'thN15p75_50', 'thN16p75_50', 'thN17p75_50', 'thN18p75_50', 'thN24p75_50', 'thN25p75_50', 'thN27p75_50'};

for rat = 1:1%numel(folderNames)

fprintf('rat %d \n ', rat);
folderPath = ['E:\New folder\' folderNames{rat} '\']; 

data = CreateAllData(folderPath, []);

choice = [data.trInfo.choice];
ramp   = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sideOff    = [data.trInfo.SideOff];
centerOff  = [data.trInfo.centralOff];

%%

% timestamps = data.data(data.timeIndex, :);
% dataShuffled = data;
% selectedTrials = data.trials;
% selector = false(1, length(timestamps));
% for tt = 1:numel(selectedTrials)
%     ind = timestamps > sideOff(selectedTrials(tt)) & timestamps <= (sideOff(selectedTrials(tt)) + 20*75);
%     ind2 = timestamps > centerOff(selectedTrials(tt)) & timestamps <= (centerOff(selectedTrials(tt)) + 20*75);
% %     | ind2
%     selector(ind & choice(data.data(data.trialIndex, :)) == 1) = true ;
% end
% dataShuffled.data(data.dataIndex, :) = ShuffleSpikes(dataShuffled.data(dataShuffled.dataIndex, :), selector);

timestamps = data.data(data.timeIndex, :);
dataShuffled = data;
selectedTrials = data.trials;
selectorCenter = false(1, length(timestamps));
selectorSide_00 = false(1, length(timestamps));
selectorSide_01 = false(1, length(timestamps));
selectorSide_10 = false(1, length(timestamps));
selectorSide_11 = false(1, length(timestamps));

for tt = 1:numel(selectedTrials)
    ind = timestamps > sideOff(selectedTrials(tt)) & timestamps <= (sideOff(selectedTrials(tt)) + 20*75);
    selectorCenter = selectorCenter | timestamps > centerOff(selectedTrials(tt)) & timestamps <= (centerOff(selectedTrials(tt)) + 10*75);
    selectorSide_00 = selectorSide_00 | (ind & choice(selectedTrials(tt)) == 0 & reward(selectedTrials(tt)) == 0);
    selectorSide_01 = selectorSide_01 | (ind & choice(selectedTrials(tt)) == 0 & reward(selectedTrials(tt)) == 1);
    selectorSide_10 = selectorSide_10 | (ind & choice(selectedTrials(tt)) == 1 & reward(selectedTrials(tt)) == 0);        
    selectorSide_11 = selectorSide_11 | (ind & choice(selectedTrials(tt)) == 1 & reward(selectedTrials(tt)) == 1);        
end
%dataShuffled.data(data.dataIndex, :) = AddNoiseToSpikes(dataShuffled.data(dataShuffled.dataIndex, :), selectorCenter, 0.5);
dataShuffled.data(data.dataIndex, :) = AddNoiseToSpikes(dataShuffled.data(dataShuffled.dataIndex, :), selectorSide_00, 0.25);
dataShuffled.data(data.dataIndex, :) = AddNoiseToSpikes(dataShuffled.data(dataShuffled.dataIndex, :), selectorSide_10, 0.25);
dataShuffled.data(data.dataIndex, :) = AddNoiseToSpikes(dataShuffled.data(dataShuffled.dataIndex, :), selectorSide_01, 0.25);
dataShuffled.data(data.dataIndex, :) = AddNoiseToSpikes(dataShuffled.data(dataShuffled.dataIndex, :), selectorSide_11, 0.25);


%%
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 120, 1);
[timestamps, binData, binLoc, trial] = BinData(data, 20, 0);
binLoc = MapToRect(binLoc, trial, data);
plot(binLoc(1, :), binLoc(2, :), '.');

%%

dataShuffled.data(data.dataIndex, :) = smoother(dataShuffled.data(data.dataIndex, :), 120, 1);
[~, binDataShuffled, ~, ~] = BinData(dataShuffled, 20, 0);

%%

choiceOne  = data.trials(choice(data.trials) == 1);
choiceZero = data.trials(choice(data.trials) == 0);
minNum     = min(numel(choiceOne), numel(choiceZero));

AllTrials = [choiceOne choiceZero];

error_1 = [];
error_2 = [];
ooo = [];
jjj = [];
kkk = [];

trials_1 = {};
trials_2 = {};


for hhh = 1:10

hhh
   
selectedOne  = randsample(choiceOne , floor(minNum * .50));
selectedZero = randsample(choiceZero, floor(minNum * .50));

selectedTrials = [selectedZero selectedOne];
selector = false(1, length(timestamps));
for tt = 1:numel(selectedTrials)
    ind = timestamps > sideOff(selectedTrials(tt)) & timestamps <= (sideOff(selectedTrials(tt)) + 20*75);
    selector(ind) = true;
end

freeChoiceTrials   = find(freeChoice);
forcedChoiceTrials = find(freeChoice == 0);

trainIndices =  ~selector ;%& ismember(trial, selectedTrials )
testIndices  =  selector;

train = binData(:, trainIndices);
loc_t = binLoc (:, trainIndices);
trIndex_t = trial(trainIndices) ;


indices = randperm(length(loc_t));
train = train(:, indices);
loc_t = loc_t(:, indices);
trIndex_t = trIndex_t(indices);


valid = binData(:, testIndices);
loc_v = binLoc(:, testIndices);
trIndex_v = trial(testIndices)  ;
timestamp_v = timestamps(testIndices);

% Animate(loc_v(:, trIndex_v == 247), res(:, trIndex_v == 247), 0.005, [-3 3 -3 3], 0, trIndex_v, data.trInfo, []);

save('data', 'train', 'loc_t', 'valid', 'loc_v');
system('python E:\Proj\Scripts\main.py True ./modelWeights');
a = load('data_out');
res = a.resValid{end}' ;
res2 = a.resTrain{end}';

error_ = sqrt( sum((res - loc_v) .^ 2, 1) );

error_1(hhh) = sqrt( sum(  sum((res - loc_v) .^ 2, 1)  )  / numel(loc_v) );

marker = MarkReplay3(loc_v, res, trIndex_v);
startIdx = find(marker == 1);
trials_1{hhh} = unique(trIndex_v(startIdx)); 

numThingy_1(hhh) = numel(startIdx);

%%


validN = binDataShuffled(:, testIndices);

% validN(abs(validN - valid) > 0.25) = valid(abs(validN - valid) > 0.30);


% validN = valid + max(min(randn(size(valid)), 1), -1).* (0.5 * repmat(std(valid(:, choice(trIndex_v) == 0), [], 2), 1, size(valid,2)).* (rand(size(valid)) < 0.5));% ;
save('data', 'validN');
system('python E:\Proj\Scripts\main.py False ./modelWeights');
a = load('data_out');
resNew = a.resValid{end}';

load('Ratio.mat')

diff = (res - resNew);
diff(1, :) = diff(1, :) * xRatio(rat);
diff(2, :) = diff(2, :) * yRatio(rat);


plot(sqrt(sum((diff) .^ 2))* 100)




% error_2(hhh) = sqrt(   sum(  sum((resNew - loc_v) .^ 2, 1)  ) / numel(loc_v) );
% 
% marker = MarkReplay3(loc_v, resNew, trIndex_v);
% startIdx = find(marker == 1);
% trials_2{hhh} = unique(trIndex_v(startIdx)); 
% numThingy_2(hhh) = numel(startIdx);
% 
% 
% RATIO(hhh) = numel(intersect(trials_1{hhh}, trials_2{hhh})) / max(numel(trials_1{hhh}), numel(trials_2{hhh}));
%     


% Animate(loc_v, res, 0.005, [-3 3 -3 3], 0, trIndex_v, data.trInfo, []);
% 
% plot(resNew(1, error_ < 8.10 & choice(trIndex_v) == 0 ), resNew(2, error_ < 8.10 & choice(trIndex_v) == 0 ), '.')
% hold on
% plot(resNew(1, error_ < 8.10 &choice(trIndex_v) > 0 ), resNew(2, error_ < 8.10 & choice(trIndex_v) > 0 ), '.')
% axis([-3 3 -3 3])
% figure
% plot(res(1, error_ < 8.15 & choice(trIndex_v) >= 0 ), res(2, error_ < 8.15 &choice(trIndex_v) >= 0 ), '.')

%%

% marker = MarkReplay3(loc_v, res, trIndex_v);
% 
% startIdx = find(marker == 1);
% endIdx   = find(marker == 2);
% 
% startTime = timestamp_v(startIdx);
% trials = unique(trIndex_v(startIdx)); 
% 
% validTrials = unique(trIndex_v);
% 
% ind = zeros(size(marker));
% for i = 1:numel(startIdx)
%     ind(startIdx(i):endIdx(i)) = 1;
% end
% 
% ThingiForcedTrials = trials(ismember(trials, forcedChoiceTrials));
% ThingiFreeTrials = trials(ismember(trials, freeChoiceTrials));
% 
% tr{hhh} =  trials;
% tr_c{hhh} = validTrials; 
% 
% loc_val{hhh}  = loc_v;
% pred_val{hhh} = res;
% 
% ooo(hhh) = sum([data.trInfo(trials).choice]) / numel(trials);
% kkk(hhh) = sum([data.trInfo(ThingiForcedTrials).choice]) / numel(ThingiForcedTrials);

end

mean(ooo)
mean(kkk)

% save(outputNames{rat}, 'tr', 'tr_c', 'sig0', 'sig1', 'loc_val', 'pred_val', 'ooo', 'jjj', 'kkk');
end

return;
