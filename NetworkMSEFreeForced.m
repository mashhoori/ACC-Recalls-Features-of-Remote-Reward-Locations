
clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));
%%

folderNames = {'P1353_15p', 'P1353_16p', 'P1353_17p', 'P1353_18p', 'P1958_24p', 'P1958_25p', 'P1958_27p'};

for rat = 4:numel(folderNames)
    
    
folderPath = ['E:\New folder\' folderNames{rat} '\'];


%%
[data, FTS] = CreateAllData(folderPath, [], 'vtm1.pvd');
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 150, 1);
choice = [data.trInfo.choice];
ramp = [data.trInfo.rampTrial];
ramp(ramp > 0) = 1;
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sfc = [data.trInfo.SideOff];

%%
[timestamps, binData, binLoc, trial] = BinData(data, 50, 0);
binLoc = MapToRect(binLoc, trial, data);

xRatio = 114.3 / 3.35;
yRatio = 101.6 / 3.25;

% binLoc(1, :) = binLoc(1, :) * xRatio;% * 100;
% binLoc(2, :) = binLoc(2, :) * yRatio;% * 100;
% [binLoc, mu, sigma] = zscore(binLoc, 0, 2);
% plot(binLoc(1, :), binLoc(2, :), '.');

%%
[code, codeMap, edgeLoc] = CoarseGrid(binLoc, rat);

%%

posTrial = data.trials(choice(data.trials) == 1 & freeChoice(data.trials) == 0) ;
negTrial = data.trials(choice(data.trials) == 0 & freeChoice(data.trials) == 0) ;
minNum = min([numel(posTrial), numel(negTrial)]);


FreeImg = {};
ForcedImg = {};

FreeImgCount = {};
ForcedImgCount = {};

errNetFreeOverAll = [];
errNetForcedOverAll = [];


freeTrials = data.trials(freeChoice(data.trials) == 1);


for it = 1:5

selectedPos = randsample(posTrial, minNum);
selectedNeg = randsample(negTrial, minNum);

AllSelected = [selectedPos selectedNeg];

r = rand(1, numel(AllSelected));
trainTrials = [AllSelected(r  <= 0.85) ];
testTrials  = [ AllSelected(r >= 0.85) freeTrials];


% freeTrials(ismember(freeTrials, trainTrials+1) | ismember(freeTrials, trainTrials-1) )freeTrialsfreeTrials(1:4)

ComputeStatistics(trainTrials, choice, reward, ramp, freeChoice);
ComputeStatistics(testTrials, choice, reward, ramp, freeChoice);

trainIndices = ismember(trial, trainTrials);
testIndices  = ismember(trial, testTrials);


selectedCells =  1:size(binData, 1);%setdiff(1:size(binData, 1), [3 6 26 33 40]);
%  

% [3 13 22 39 43]
% [1 6 12 25]
% [3 7 15 36 39 41]
% [3 6 26 33 40]
% [2 13 23 49 60]
% [5 6 7 14 22 26 31 34 53 59]

train = binData(selectedCells, trainIndices);
loc_t = binLoc(:, trainIndices);
code_t = code(trainIndices);
trial_t = trial(trainIndices);
timestamps_t = timestamps(trainIndices);

indices = randperm(length(loc_t));

train = train(:, indices);
loc_t = loc_t(:, indices);
code_t = code_t(indices);
trial_t = trial_t(indices);
timestamps_t = timestamps_t(indices);


valid = binData(selectedCells, testIndices);
loc_v = binLoc(:, testIndices);
code_v = code(testIndices);
trial_v = trial(testIndices);
timestamps_v = timestamps(testIndices);

%%
save('data', 'train', 'loc_t', 'valid', 'loc_v');
system('python .\main.py True');
a = load('data_out');
res = a.resValid{end}';
res2 = a.resTrain{end}';

error = loc_v - res;
error(1, :) = error(1, :) * xRatio;
error(2, :) = error(2, :) * yRatio;


errorFree = error(:, freeChoice(trial_v) == 1);
codeFree = code_v(freeChoice(trial_v) == 1);
errNetFree = sqrt(sum(errorFree .^ 2));

errorForced = error(:, freeChoice(trial_v) == 0);
codeForced = code_v(freeChoice(trial_v) == 0);
errNetForced = sqrt(sum(errorForced .^ 2));


TFree = table(errNetFree(:), codeFree(:), 'VariableNames', {'error', 'code'});
TForced = table(errNetForced(:), codeForced(:), 'VariableNames', {'error', 'code'});

TFree = grpstats(TFree, 'code', 'median');
TForced = grpstats(TForced, 'code', 'median');


TFreeUlt = zeros(1, 49);
TFreeUlt(TFree.code) = TFree.median_error;
img = flip(rot90(reshape(TFreeUlt, 7, [])', 2), 2);
FreeImg{end + 1} = img;


TFreeCount = zeros(1, 49);
TFreeCount(TFree.code) = TFree.GroupCount;
img = flip(rot90(reshape(TFreeCount, 7, [])', 2), 2);
FreeImgCount{end + 1} = img;


TForcedUlt = zeros(1, 49);
TForcedUlt(TForced.code) = TForced.median_error;
img = flip(rot90(reshape(TForcedUlt, 7, [])', 2), 2);
ForcedImg{end + 1} = img;


TForcedCount = zeros(1, 49);
TForcedCount(TForced.code) = TForced.GroupCount;
img = flip(rot90(reshape(TForcedCount, 7, [])', 2), 2);
ForcedImgCount{end + 1} = img;


errNetFreeOverAll(it) = mean(sqrt(sum(errorFree .^ 2)));
errNetForcedOverAll(it) = mean(sqrt(sum(errorForced .^ 2)));


end


FreeImgAll = cat(3, FreeImg{:});
FreeImgCountAll = cat(3, FreeImgCount{:});
% FreeImgAll = sum(FreeImgAll .* FreeImgCountAll, 3) ./ sum(FreeImgCountAll, 3);

ForcedImgAll = cat(3, ForcedImg{:});
ForcedImgCountAll = cat(3, ForcedImgCount{:});
% ForcedImgAll = sum(ForcedImgAll .* ForcedImgCountAll, 3) ./ sum(ForcedImgCountAll, 3);

outputFile = ['errorPerRegionFF_Full_', num2str(rat)];
save(outputFile, 'FreeImgAll', 'FreeImgCountAll', 'ForcedImgAll', 'ForcedImgCountAll', 'errNetFreeOverAll', 'errNetForcedOverAll');


end








