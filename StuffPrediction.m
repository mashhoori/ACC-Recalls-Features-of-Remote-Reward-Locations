
clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));

%%
folderPath = 'E:\New folder\P1958_25p\'; 
data = CreateAllData(folderPath, []);
d = data.data(data.dataIndex, :);
%data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 150, 1);

choice = [data.trInfo.choice];
durTrial = [data.trInfo.durTrial];
rampTrial = [data.trInfo.rampTrial];

timepoints = data.data(data.timeIndex, :);

feederTime = round(max(reshape([data.trInfo.feeder_off_ts], 3, []))/ 1000);
% feederIndex = feederTime - min(timepoints) + 1;


mt = [];
trials = [];
for i = 1:numel(feederTime)    
    ind = timepoints >= feederTime(i) & timepoints < feederTime(i) + 300;
    if(sum(ind) == 300)
    %   a = d(:, feederIndex(i) :feederIndex(i) + 300);    
        a = d(:, ind);
        b = sum(a, 2);
        mt = [mt b];
        trials = [trials i]; 
    end    
end
clear a d timepoints



rampTrial = rampTrial(trials);
choice = choice(trials);
durTrial = durTrial(trials);
%%

% [COEFF,SCORE] = pca(mt(selectedCells, :)') ;
% 
% plot3(SCORE(durTrial == 1, 2), SCORE(durTrial == 1, 1 ),SCORE(durTrial == 1, 3 ), '.')
% hold on
% plot3(SCORE(durTrial == 0, 2), SCORE(durTrial == 0, 1 ), SCORE(durTrial == 0, 3 ),'.')
% figure
% plot3(SCORE(choice == 1, 2), SCORE(choice == 1, 1 ),SCORE(choice == 1, 3), '.')
% hold on
% plot3(SCORE(choice == 0, 2), SCORE(choice == 0, 1 ), SCORE(choice == 0, 3), '.')
% 
% 
% plot(SCORE(choice == 1, 2), 1, '.')
% hold on
% plot(SCORE(choice == 0, 2), 0,'.')


yChoice = FindSignificantCells(mt, choice);
yRamp   = FindSignificantCells(mt, rampTrial);
yReward = FindSignificantCells(mt, durTrial);

cellsChoice = find(yChoice);
cellsRamp   = find(yRamp);
cellsReward = find(yReward);

%%

mt = sqrt(mt);
%mt = zscore(mt);
% [n f] = size(mt);
% indices = randperm(f);
% durTrial2 = rampTrial(indices);
% mt2 = [mt2; choice];


target = choice;
selectedCells = cellsChoice;
% intersect(intersect(cellsChoice, cellsRamp), cellsReward);
% , cellsReward);
% setdiff(

num = 100;
train = mt(selectedCells, 1:num);
choiceTrain = target(1:num);
test = mt(selectedCells, num+1:end);
choiceTest = target(num+1:end);

SVMStruct = fitcsvm(train', choiceTrain);
pred = predict(SVMStruct, test');
accuracy = sum(pred(:) == choiceTest(:)) / numel(choiceTest);
trainProb = sum(choiceTrain(:)) / numel(choiceTrain);
chanceAcc = sum(choiceTest(:)) / numel(choiceTest);
fprintf('Accuracy: %.3f -- Chance: %.3f -- Train Prop: %.3f \n', accuracy, max(chanceAcc, 1 -  chanceAcc), trainProb);

