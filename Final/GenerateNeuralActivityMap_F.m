
clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));

%%
folderPath = 'E:\New folder\P1353_16p\'; 
data = CreateAllData(folderPath, []);
% data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 1, 1);

BC25 = load('bestCellsForError_16.mat');
impCells = BC25.bestCells(1:9);

clear folderPath

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
meanFR = meanFR([impCells], :);
% PlotNeuralActivity(meanFR, gridDim)


figure
for jj= 1:9
    subplot(3, 3, jj)
    avg = meanFR(jj, :);
    avg1 = reshape(avg, gridDim(2), []);        
    avg1 = conv2(avg1, ones(3, 3)/9);        
    avg1 = rot90(avg1, 2);
    avg1 = avg1(:, end:-1:1);
    imagesc(avg1)
    set(gca, 'xtick', []);    
    set(gca, 'ytick', []);
    colormap jet
end

