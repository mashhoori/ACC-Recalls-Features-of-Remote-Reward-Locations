
clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));

%%
folderPath = 'E:\New folder\P1958_27p\'; 
data = CreateAllData(folderPath, []);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 150, 1);

clear folderPath
%%
binWidth = 50;

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

%%
gridWith = 0.2;
[code, codeMap, gridDim] = GridLocations(binLoc, gridWith);

code(end + 1) = prod(gridDim);
OHC = dummyvar(code);
code(end) = [];
OHCReshape = reshape(OHC, size(OHC, 1), gridDim(2), []);
OHCConve = convn(OHCReshape, shiftdim([ 1 1 1; 1 3 1; 1 1 1] / 11, -1), 'same');
OHCReshape = reshape(OHCConve, size(OHCReshape, 1), []);
OHCReshape(end, :) = [];
OHCReshape = OHCReshape';
%%
% 
% num = floor(length(binData) * 4 / 5);
% 
% train = binData(:, 1:num);
% loc_t = binLoc(:, 1:num);
% valid = binData(:, num + 1:end);
% loc_v = binLoc(:, num + 1:end);
% trial_v = trial(num + 1:end);
% code_t = code(1:num);
% code_v = code(num+1:end);

AllTrial = 2:numel(data.trInfo);
trainTrial = AllTrial( mod(AllTrial, 4) < 2);
testTrial = setdiff(AllTrial, trainTrial);

trainIndices = ismember(trial, trainTrial);
testIndices  = ismember(trial, testTrial);

train = binData(:, trainIndices);
loc_t = binLoc(:, trainIndices);

valid = binData(:, testIndices);
loc_v = binLoc(:, testIndices);

trial_t = trial(trainIndices);
trial_v = trial(testIndices);

% uc = unique(code);
uc = find(sum(OHCReshape, 2) ~= 0);
uMap(uc) = 1:numel(uc);
codeMapped = uMap(code);
codeHO = dummyvar(codeMapped)';

code_t = codeHO(:, trainIndices) ;
code_v = codeHO(:, testIndices)  ;


%%

save('data', 'train', 'code_t', 'valid', 'code_v');
system('python C:\Users\a.mashhoori\Desktop\Proj\Scripts\main_3.py');
a = load('data_out');

res = a.res';
res2 = a.res2';


[~, resCode] = max(res);
resCode = uc(resCode);

resLoc = codeMap(:, resCode);


tar = code(testIndices);
tarLoc = codeMap(:, tar);


% Animate(loc_v, resLoc, 0.003, [-3 3 -3 3], 0, trial_v, data.trInfo);
sum(sum((tarLoc - resLoc) .^ 2)) / numel(tarLoc)








