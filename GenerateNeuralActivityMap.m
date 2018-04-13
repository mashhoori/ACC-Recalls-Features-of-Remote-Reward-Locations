
clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));

%%
folderPath = 'E:\New folder\P1353_17p\'; 
data = CreateAllData(folderPath, []);
% data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 1, 1);

clear folderPath
%

[timestamps, binData, binLoc, trial] = BinData(data, 20, 1);
%%

gridWith = [0.1 0.1];
[code, codeMap, gridDim] = GridLocations(binLoc, gridWith);


count = zeros(1, prod(gridDim));
for i = 1:prod(gridDim)
   count(i) = sum(code == i);
end
badLoc = find(count < 40);


binLoc2 = binLoc(:, ~ismember(code, badLoc));
binData2 = binData(:, ~ismember(code, badLoc));
code2 = code(~ismember(code, badLoc));

meanFR = GetMeanFiringRateByCell(binData2, code2, size(codeMap, 2));


save('meanFR', 'meanFR', 'gridDim')
load('meanFR')
PlotNeuralActivity(meanFR, gridDim)


