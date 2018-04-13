
function [data, TS] = CreateAllDataNew(folderPath, timeRange)

files = dir(folderPath);
fileNames = {files.name};
tmp = strncmp(fileNames, 'EffortVSReward', 14);
EffortVSRewardFile = fileNames{tmp};

tFileFolder  = [folderPath, 'tfiles\'];
locationFile = [folderPath, 'vtm1_01.pvd'];

files = dir(tFileFolder); 
files(1:2) = [];
fileNames = {files.name};
fullFileNames = strcat(tFileFolder, fileNames);
spikes = LoadSpikes(fullFileNames);

[spikesMat, timestamp] = CreateSpikeMatrix(spikes);

TS(1) = timestamp(1);
TS(2) = timestamp(end);

location =  dlmread(locationFile);
location(:, 1) = round(location(:, 1) /1000);
location(:, 4:5) = [];

ind = (timestamp <= location(end, 1) & timestamp >= location(1, 1));
timestamp = timestamp(ind);    
spikesMat = spikesMat(:, ind);

if(~isempty(timeRange))    
    ind = (timestamp <= timeRange(2) & timestamp >= timeRange(1));
    timestamp = timestamp(ind);    
    spikesMat = spikesMat(:, ind); 
    
    ind = (location(:, 1) <= timeRange(2) & location(:, 1) >= timeRange(1));
    location = location(ind ,:);
end

mnT = min(timestamp) - 1;
% timestamp = timestamp - mnT;
location(:, 1) =  location(:, 1) - mnT;

xx = [location(1:end-1, 2), location(2:end, 2)];
yy = [location(1:end-1, 3), location(2:end, 3)];
locationAll = zeros(2, size(spikesMat, 2));
for i=1:size(xx, 1)
    xxV = linspace(xx(i), xx(i+1), location(i+1,1) - location(i,1) + 1);
    yyV = linspace(yy(i), yy(i+1), location(i+1,1) - location(i,1) + 1);
     
    locationAll(1, location(i,1):location(i+1,1)) = xxV;
    locationAll(2, location(i,1):location(i+1,1)) = yyV;
end

%%
remNeur = find(((sum(spikesMat, 2) / length(spikesMat)) * 1000) <= 0.5);
spikesMat(remNeur, :) = [];

%%

% [~, trial_events ] = read_events_ramp([folderPath, 'Events.txt'], [folderPath, EffortVSRewardFile]);
% times = round(min(reshape([trial_events.feeder_off_ts], 3, []))/ 1000);
% 
% indMin = zeros(size(times));
% for i=1:numel(times)   
%     val = abs(timestamp - times(i));
%     [~, indMin(i)] = min(val);          
% end
% 
trialNum = zeros(1, length(timestamp));
% for i=1:numel(times)-1
%     trialNum(indMin(i):indMin(i+1)-1) = i;
% end  
% 
% df = diff(indMin);
% badTrials = find((df / median(df)) > 1.4 | (df / median(df)) < 0.3333);
% 
% choice = [trial_events.choice];
% 
% dur = reshape([trial_events.feeder_dur], 3, []);
% durTrial = zeros(size(choice));
% durTrial(choice == 0)  = dur(1, choice == 0);
% durTrial(choice == 1)  = dur(2, choice == 1);
% 
% durTrial(durTrial == 200) = 0;
% durTrial(durTrial == 600) = 1;
% 
% tmp = num2cell(durTrial);
% [trial_events(:).durTrial] = deal(tmp{:});
% 
% gate = reshape([trial_events.gates], 2, []);
% freeChoice = (sum(gate) ~= 1);
% 
% tmp = num2cell(freeChoice);
% [trial_events(:).freeChoice] = deal(tmp{:});
% 
% ramp = reshape([trial_events.heights], 2, []);
% rampTrial = zeros(size(choice));
% rampTrial(choice == 0)  = ramp(1, choice == 0);
% rampTrial(choice == 1)  = ramp(2, choice == 1);
% rampTrial(rampTrial > 0) = 1;
% 
% tmp = num2cell(rampTrial);
% [trial_events(:).rampTrial] = deal(tmp{:});
% 
% centralOn = round(min(reshape([trial_events.feeder_ts], 3, []))/ 1000);
% SideOn = round(max(reshape([trial_events.feeder_ts], 3, []))/ 1000);
% 
% centralOff = round(min(reshape([trial_events.feeder_off_ts], 3, []))/ 1000);
% SideOff = round(max(reshape([trial_events.feeder_off_ts], 3, []))/ 1000);
% 
% tmp = num2cell(centralOn);
% [trial_events(:).centralOn] = deal(tmp{:});
% 
% tmp = num2cell(SideOn);
% [trial_events(:).SideOn] = deal(tmp{:});
% 
% tmp = num2cell(centralOff);
% [trial_events(:).centralOff] = deal(tmp{:});
% 
% tmp = num2cell(SideOff);
% [trial_events(:).SideOff] = deal(tmp{:});

%%
AllData = [spikesMat; trialNum; locationAll; timestamp];

% AllData = AllData(:, 100001:2e6);


dataIndex = 1:size(spikesMat, 1);
trialIndex = dataIndex(end) + 1;
locIndex  = trialIndex + [1:2];
timeIndex = locIndex(end) + 1;
% 
% AllData = AllData(:, ~ismember( AllData(trialIndex, :), badTrials) );
% AllData = AllData(:, AllData(trialIndex, :) ~= 0);
AllData = AllData(:, 1:floor(length(AllData)/1000) * 1000);
% 
% AllData = AllData(:, AllData(locIndex(1), :) ~= 0);

data.data = AllData;
data.dataIndex = dataIndex;
data.trialIndex = trialIndex;
data.locIndex  = locIndex;
data.timeIndex = timeIndex;
%data.trInfo = trial_events;
%data.trials = setdiff(2:(numel(trial_events)-1), badTrials);

