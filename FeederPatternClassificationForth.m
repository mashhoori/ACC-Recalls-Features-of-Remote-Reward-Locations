

clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));
%%

folderPath = 'E:\New folder\P1958_27p\';

%%

load('Ratio.mat')
[data, FTS] = CreateAllData(folderPath, [], 'vtm1.pvd');
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 120, 1);
choice = [data.trInfo.choice];
ramp = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sideOff = [data.trInfo.SideOff];
centerOff = [data.trInfo.centralOff];

mean(choice(freeChoice == 1))


%%

[timestamps, binData, binLoc, trial] = BinData(data, 20, 0);

%%

selector = false(1, length(timestamps));
for tt = 1:numel(sideOff)
    ind = timestamps > sideOff(tt) & timestamps <= (sideOff(tt) + 20*75);
    selector(ind) = true;
end

%%

selectedCells = setdiff(1:size(binData, 1), [-2]);


%%

binDataSelected = binData(selectedCells, selector);
binLocSelected = binLoc(:, selector);
trialSelected = trial(selector);
choiceSelected = choice(trialSelected);

plot(binLocSelected(1, :), binLocSelected(2, :), '.')

%%

uniqueTrials = unique(trialSelected);

uniqueTrials = uniqueTrials(randperm(numel(uniqueTrials)));
batchSize = floor(numel(uniqueTrials) / 20);

goodTrialAll = [];
badTrialAll = [];
errorAll = [];
dataAll = [];
trialAll = [];

for i = 1:20
    
    testRange = (i-1)*batchSize+1 : i*batchSize;
    if(i == 20)
        testRange = [testRange testRange(end)+1:numel(uniqueTrials)];
    end
    
    trainRange = setdiff(1:numel(uniqueTrials), testRange);
    
    trainTrials = uniqueTrials(trainRange);
    testTrials = uniqueTrials(testRange);

    %%

    trainSelector = ismember(trialSelected, trainTrials);
    testSelector = ismember(trialSelected, testTrials);

    %%

    binDataTrain = binDataSelected(:, trainSelector);
    binLocTrain = binLocSelected(:, trainSelector);
    trialTrain = trialSelected(trainSelector);
    choiceTrain = choiceSelected(trainSelector);

    %%

    binDataTest = binDataSelected(:, testSelector);
    binLocTest = binLocSelected(:, testSelector);
    trialTest = trialSelected(testSelector);
    choiceTest = choiceSelected(testSelector);

%%

    SVMStruct = fitcsvm(binDataTrain', choiceTrain', 'KernelFunction', 'polynomial', 'PolynomialOrder', 1);
    [preds, scores] = predict(SVMStruct, binDataTest');

    % acc = mean(choiceTest(:) == preds(:));
    % [~,~,~,auc] = perfcurve( choiceTest(:), scores(:, 2), 1);
    % badTrials = unique(trialTest(choiceTest(:) ~= preds(:)));

    T = table(choiceTest(:) ~= preds(:), trialTest(:), 'VariableNames', {'error', 'trial'} );
    T = grpstats(T, 'trial', 'sum');

    error = choiceTest(:) ~= preds(:);

    errorAll = [errorAll error(:)'];
      
%    & choice(T.trial) == 1   & choice(T.trial) == 1& choice(T.trial) == 0& choice(T.trial) == 0& choice(T.trial) == 0
    badTrials = T.trial(T.sum_error' > 10);
    goodTrials = T.trial(T.sum_error' == 0);

    badTrialAll = [badTrialAll badTrials(:)'];
    goodTrialAll = [goodTrialAll goodTrials(:)'];

    dataAll = [dataAll binDataTest];
    trialAll = [trialAll trialTest];
  
end

mean(choice(badTrialAll))



% 0.9729 0.9911 0.9119 0.9907 0.8873 0.8575 0.9479 
% 0.6000 0.4682 0.2127 0.5332 0.4274 0.5845 0.4699
% 0.5429 0.5806 0.3636 0.5000 0.5500 0.5833
% 0.6000 0.2000 0.6316 0.2526 0.5278 0.8554

selectedTrials = [badTrialAll goodTrialAll];


cnt = 1;
selArr = {};
meanActivity = [];
for i = selectedTrials    
    if(ismember(i, badTrialAll))
%         selArr{end+1} = find(trialAll == i & errorAll);
%         selArr{end} = mod(selArr{end}, 75);
%         selArr{end}(selArr{end} == 0) = 75;               
        meanActivity = [meanActivity mean(dataAll(:, trialAll == i & errorAll), 2)];        
    else            
          ind = find(trialAll == i);
          %ind = ind(selArr{cnt});          
          meanActivity = [meanActivity mean(dataAll(:, ind), 2)];           
%           cnt = mod((cnt+1), numel(selArr) );          
%           if(cnt == 0)
%               cnt = numel(selArr);
%           end          
    end
end


trialLabel = [ones(1, length(badTrialAll)), zeros(1, length(goodTrialAll))];
Tatalitutu = [meanActivity; trialLabel];

Tatalitutu = Tatalitutu(:, randperm(size(Tatalitutu, 2)));


[trainedClassifier, validationAccuracy, validationScores] = trainClassifierSVM(Tatalitutu);
[~,~,~,AUC] = perfcurve( Tatalitutu(end, :) , validationScores(:, 2) , 1);
AUC

