

clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));
%%

folderPath = 'E:\New folder\P1353_16p\';

%%

load('Ratio.mat')
[data, FTS] = CreateAllData(folderPath, [], 'vtm1.pvd');
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 100, 1);
choice = [data.trInfo.choice];
ramp = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sideOff = [data.trInfo.SideOff];
centerOff = [data.trInfo.centralOff];

%%

[timestamps, binData, binLoc, trial] = BinData(data, 20, 0);

%%

selector = false(1, length(timestamps));
for tt = 1:numel(sideOff)
    ind = timestamps > sideOff(tt) & timestamps <= (sideOff(tt) + 20*75);
    selector(ind) = true;
end

%%

selectorCenter = false(1, length(timestamps));
for tt = 1:numel(centerOff)
    ind = timestamps > centerOff(tt) & timestamps <= (centerOff(tt) + 10*75);
    selectorCenter(ind) = true;
end

%%

selectedCells = setdiff(1:size(binData, 1), [-2]);

%%

binDataAll = binData(selectedCells, selector);
binLocAll = binLoc(:, selector);
trialAll = trial(selector);
choiceAll = choice(trialAll);

plot(binLocAll(1, :), binLocAll(2, :), '.')

%%

binDataAllCenter = binData(selectedCells, selectorCenter);
trialAllCenter = trial(selectorCenter);


%%


uniqueTrials = unique(trialAll);

uniqueTrials = uniqueTrials(randperm(numel(uniqueTrials)));
batchSize = floor(numel(uniqueTrials) / 10);

badTrialAll = [];
errorAll = [];
dataGoodAll = [];
dataBadAll = [];
trialGoodAll = [];

goodTrialAll = [];

for i = 1:10
    
    testRange = (i-1)*batchSize+1 : i*batchSize;
    if(i == 10)
        testRange = [testRange testRange(end)+1:numel(uniqueTrials)];
    end
    
    trainRange = setdiff(1:numel(uniqueTrials), testRange);
    
    trainTrials = uniqueTrials(trainRange);
    testTrials = uniqueTrials(testRange);

    %%

    trainSelector = ismember(trialAll, trainTrials);
    testSelector = ismember(trialAll, testTrials);

    %%

    binDataTrain = binDataAll(:, trainSelector);
    binLocTrain = binLocAll(:, trainSelector);
    trialTrain = trialAll(trainSelector);
    choiceTrain = choiceAll(trainSelector);

    %%

    binDataTest = binDataAll(:, testSelector);
    binLocTest = binLocAll(:, testSelector);
    trialTest = trialAll(testSelector);
    choiceTest = choiceAll(testSelector);

%%

    SVMStruct = fitcsvm(binDataTrain', choiceTrain', 'KernelFunction', 'polynomial', 'PolynomialOrder', 2);
    [preds, scores] = predict(SVMStruct, binDataTest');

    % acc = mean(choiceTest(:) == preds(:));
    % [~,~,~,auc] = perfcurve( choiceTest(:), scores(:, 2), 1);
    % badTrials = unique(trialTest(choiceTest(:) ~= preds(:)));

    T = table(choiceTest(:) ~= preds(:), trialTest(:), 'VariableNames', {'error', 'trial'} );
    T = grpstats(T, 'trial', 'sum');

    error = choiceTest(:) ~= preds(:);

    errorAll = [errorAll error(:)'];
%   
    badTrials = T.trial(T.sum_error' > 10 & choice(T.trial) == 1);
    goodTrials = T.trial(T.sum_error' == 0 & choice(T.trial) == 1);
    
    badTrialAll = [badTrialAll badTrials(:)'];
    goodTrialAll = [goodTrialAll goodTrials(:)'];

    dataGoodAll = [dataGoodAll binDataTest];
    trialGoodAll = [trialGoodAll trialTest];    
  
end


selectedTrials = [badTrialAll goodTrialAll];


selArr = {};
cnt = 1;

meanActivity = [];
meanActivityCenter = [];
for i = selectedTrials
    
    if(ismember(i, badTrialAll )) 
        
        selArr{end+1} = find(trialGoodAll == i & errorAll);
        selArr{end} = mod(selArr{end}, 75);
        selArr{end}(selArr{end} == 0) = 75;               
        meanActivity = [meanActivity mean(dataGoodAll(:, trialGoodAll == i & errorAll), 2)];
        
    else        
          ind = find(trialGoodAll == i);
          ind = ind(selArr{cnt});          
          meanActivity = [meanActivity mean(dataGoodAll(:, ind), 2)];           
          cnt = mod((cnt+1), numel(selArr) );          
          if(cnt == 0)
              cnt = numel(selArr);
          end
    end
    
    ind = find(trialAllCenter == i);
    meanActivityCenter = [meanActivityCenter mean(binDataAllCenter(:, ind), 2)];    
end


trialLabel = [ones(1, length(badTrialAll)), zeros(1, length(goodTrialAll))];
Tatalitutu = [meanActivity; trialLabel];

Tatalitutu = Tatalitutu(:, 1:length(badTrialAll) + 3);

Tatalitutu = Tatalitutu(:, randperm(length(Tatalitutu)));


cnt = 1;
meanAvticityOtherFeeder = [];
selectedTrials = find(choice == 1);
for i = selectedTrials           
    
    ind = find(trialGoodAll == i);
    
    if(length(ind) == 75)   
        ind = ind(selArr{cnt});  
        meanAvticityOtherFeeder = [meanAvticityOtherFeeder mean(dataGoodAll(:, ind), 2)];  
        
        cnt = mod((cnt+1), numel(selArr) );          
          if(cnt == 0)
              cnt = numel(selArr);
          end
    end    
end


meanAvticityOtherFeeder = zscore(meanAvticityOtherFeeder, [], 2);

pred = predict(trainedClassifier.ClassificationSVM, meanAvticityOtherFeeder');
mean(pred)



meanActivityCenter = zscore(meanActivityCenter, [], 2);

pred = predict(trainedClassifier.ClassificationSVM, meanActivityCenter');
mean(pred)

