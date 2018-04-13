clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));

%%

folderNames = {'P1353_15p', 'P1353_16p', 'P1353_17p', 'P1353_18p', 'P1958_24p', 'P1958_25p', 'P1958_27p'};
outputNames = {'Rapatu15_', 'Rapatu16_', 'Rapatu17_', 'Rapatu18_', 'Rapatu24_', 'Rapatu25_', 'Rapatu27_'};

for rat = 2:numel(folderNames)

fprintf('rat %d \n ', rat);
folderPath = ['E:\New folder\' folderNames{rat} '\']; 

data = CreateAllData(folderPath, []);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 120, 1);
%%
[timestamps, binData, binLoc, trial] = BinData(data, 20, 0);
choice = [data.trInfo.choice];
ramp   = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sideOn = [data.trInfo.SideOn];
sideOff    = [data.trInfo.SideOff];
centerOff  = [data.trInfo.centralOff];

binLoc = MapToRect(binLoc, trial, data);
plot(binLoc(1, :), binLoc(2, :), '.');

speed = [0 sqrt(sum(diff(binLoc, 1, 2) .^ 2))]  ;
speed = conv(speed, ones(1, 20) / 20, 'same');
% plot(speed)

choiceOne  = data.trials(choice(data.trials) == 1 & freeChoice(data.trials) == 0);
choiceZero = data.trials(choice(data.trials) == 0 & freeChoice(data.trials) == 0);
minNum     = min(numel(choiceOne), numel(choiceZero));

AllTrials = [choiceOne choiceZero];

ooo = [];
jjj = [];
kkk = [];
timeLocked = [];
timeLockedEnd = [];
gg = [];


A = [];
for hhh = 1:10

hhh
   
selectedOne  = randsample(choiceOne , floor(minNum * .50));
selectedZero = randsample(choiceZero, floor(minNum * .50));

selectedTrials = [selectedZero selectedOne];
selector = false(1, length(timestamps));

enteringZone = containers.Map('KeyType', 'double', 'ValueType', 'double');
startMovement = containers.Map('KeyType', 'double', 'ValueType', 'double');

for tt = 1:numel(selectedTrials)
    %ind = timestamps > sideOff(selectedTrials(tt)) - 20 * 75 & timestamps <= (sideOff(selectedTrials(tt)) + 20*100);
    %ind = timestamps > sideOn(selectedTrials(tt)) - 20 * 10 & timestamps <= (sideOn(selectedTrials(tt)) + 20*500);
    sss = find(timestamps > sideOn(selectedTrials(tt)) & speed < 0.01, 1) - 25 ;
    eee = find(timestamps > sideOff(selectedTrials(tt)) + 1000 & speed > 0.01, 1) + 25 ;

    enteringZone(selectedTrials(tt)) = sss + 25 ;
    startMovement(selectedTrials(tt)) = eee - 25;
    
    %ind = timestamps > sideOn(selectedTrials(tt)) - 20 * 10 & timestamps <= (sideOn(selectedTrials(tt)) + 20*500);
    ind = sss:eee;
    selector(ind) = true;
end
% plot(timestamps, speed)
% hold on
% plot([sideOff(216)' sideOff(216)'] , [0 .05], 'r-')
% plot(binLoc(1, selector), binLoc(2, selector), '.')

freeChoiceTrials   = find(freeChoice);
forcedChoiceTrials = find(freeChoice == 0);

trainIndices =  ~selector ;%& ismember(trial, selectedTrials )
testIndices  =  selector;

train = binData(:, trainIndices);
loc_t = binLoc (:, trainIndices);
trIndex_t = trial(trainIndices);

valid = binData(:, testIndices);
loc_v = binLoc(:, testIndices) ;
trIndex_v = trial(testIndices) ;
timestamp_v = timestamps(testIndices);

% Animate(loc_v(:, trIndex_v == 216), res(:, trIndex_v == 216), 0.05, [-3 3 -3 3], 0, trIndex_v, data.trInfo, []);
% save('data', 'train', 'loc_t', 'valid', 'loc_v');
% system('python C:\Users\a.mashhoori\Desktop\Proj\Scripts\main.py');
% a = load('data_out');

save('data', 'train', 'loc_t', 'valid', 'loc_v');
system('python E:\Proj\Scripts\main.py True ./modelWeights');
a = load('data_out');

%%
res = a.resValid{end}';
% res2 = a.res2';

A(hhh).res = res;
A(hhh).valid_loc = loc_v;
A(hhh).timestamp_v = timestamp_v;
A(hhh).trIndex_v = trIndex_v;

marker = MarkReplay3(loc_v, res, trIndex_v);

startIdx = find(marker == 1);
endIdx   = find(marker == 2);

startTime = timestamp_v(startIdx);
trials = unique(trIndex_v(startIdx)); 

% gg{hhh}  = (startTime - sideOn(trials)) ./ -(timestamps(cell2mat(values(enteringZone, num2cell(trials)))) - timestamps(cell2mat(values(startMovement, num2cell(trials)))));
% timeLocked{hhh} = startTime - sideOn(trials);
% timeLockedEnd{hhh} = startTime - timestamps(cell2mat(values(startMovement, num2cell(trials))));

EZ{hhh} = enteringZone;
SM{hhh} = startMovement;
ST{hhh} = startTime;
TR{hhh} = trials;
SI{hhh} = startIdx;
TS{hhh} = timestamps;



% hist([gg{:}])
% 
% hist([timeLocked{:}], 60)
% hist([timeLockedEnd{:}], 60);

% xlim([-200 5000])
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

% mean(ooo)
% mean(kkk)

save(outputNames{rat}, 'EZ', 'SM', 'ST', 'TR', 'SI', 'TS', 'A');

% save(outputNames{rat}, 'tr', 'tr_c', 'sig0', 'sig1', 'loc_val', 'pred_val', 'ooo', 'jjj', 'kkk');
% save(outputNames{rat}, 'tr', 'tr_c', 'sig0', 'sig1', 'loc_val', 'pred_val', 'ooo', 'jjj', 'kkk');
end

return;
