
clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));

%%
folderPath = 'E:\New folder\P1353_15p\'; 
data = CreateAllData(folderPath, []);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 10, 1);

trials = data.data(data.trialIndex, :);
uTrials = unique(trials);

gate = reshape([data.trInfo.gates], 2, []);
freeChoice = (sum(gate) ~= 1);
freeChoiceTrials = find(freeChoice);

choice = [data.trInfo.choice];

dur = reshape([data.trInfo.feeder_dur], 3, []);
durTrial = zeros(size(choice));
durTrial(choice == 0)  = dur(1, choice == 0);
durTrial(choice == 1)  = dur(2, choice == 1);

ramp = reshape([data.trInfo.heights], 2, []);
rampTrial = zeros(size(choice));
rampTrial(choice == 0)  = ramp(1, choice == 0);
rampTrial(choice == 1)  = ramp(2, choice == 1);

%%
binWidth = 40;

d = data.data(data.dataIndex, :);
d = reshape(d, size(d, 1), binWidth, []);
binData = squeeze(sum(d, 2));
binData = sqrt(binData);
binData = zscore(binData, 0, 2);

% 
loc = data.data(data.locIndex, :);
loc = reshape(loc, size(loc, 1), binWidth, []);
binLoc = squeeze(mean(loc, 2));
% % 
% % 
% vel =  sqrt(sum(diff(binLoc, 1, 2) .^ 2));
% vel = [vel 0];

trial = trials(1:binWidth:end);
% % 
% plot(vel)
% hold on
% plot([0 diff(trial)])

plot(binLoc(1, :), binLoc(2, :), '.')

dataAll = [];
choiceAll = [];
durTrialAll = [];
ttt = [];
effTrialAll = [];
for i=2:numel(uTrials)
   
    trialNum = uTrials(i);
    
%     if(ismember(trialNum, freeChoiceTrials))
%         continue;
%     end
    
    indices = find(trial == trialNum, 60, 'first');
    
    rn = 1:10;
    cols = binData(:, indices(rn));
    hold on
    plot(binLoc(1, indices(rn)), binLoc(2, indices(rn)), '.')
    
    
    dataAll = [dataAll, cols(:)];
    choiceAll = [choiceAll choice(trialNum - 1)];    
    durTrialAll  = [durTrialAll durTrial(trialNum - 1)];
    effTrialAll = [effTrialAll rampTrial(trialNum)];
        
%     if(ismember(trialNum - 1, freeChoiceTrials))
%         ttt = [ttt 0];
%     else
%         ttt = [ttt 1];
%     end

end

% % 
% train = dataAll(:, ttt == 1);
% choice_t = choiceAll(:, ttt == 1);
% valid = dataAll(:, ttt == 0);
% choice_v = choiceAll(:, ttt == 0);


% yy =  uTrials(2:end);
% ind_tmp = find(ttt == 0);
% [[0:numel(ind_tmp)-1]'  [data.trInfo(yy(ind_tmp - 1)).choice]']
% 
% a = load('data_out');
% res = a.res';
% 

% % 
% shuffIndices = randperm(numel(choiceAll));
% dataAll = dataAll(:, shuffIndices);
% choiceAll = choiceAll(shuffIndices);
% 

choiceAll = effTrialAll;


% choiceAll = choiceAll(ttt == 0);
% dataAll = dataAll(:, ttt == 0);
% % 
% 
% num = floor(length(choiceAll ) * 3 / 4);
% train = dataAll(:, 1:num);
% choice_t = choiceAll(:, 1:num);
% valid = dataAll(:, num + 1:end);
% choice_v = choiceAll(:, num + 1:end);
% 
% save('data', 'train', 'choice_t', 'valid', 'choice_v');


dataAllPPP = [dataAll; choiceAll];
%dataAllPPP = [dataAll; ttt];


