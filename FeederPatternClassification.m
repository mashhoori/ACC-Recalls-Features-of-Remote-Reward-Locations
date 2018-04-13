

clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));
%%

folderPath = 'E:\New folder\P1353_15p\';

%%

load('Ratio.mat')
[data, FTS] = CreateAllData(folderPath, [], 'vtm1.pvd');
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 100, 1);
choice = [data.trInfo.choice];
ramp = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sideOff = [data.trInfo.SideOff];

%%

[timestamps, binData, binLoc, trial] = BinData(data, 20, 0);

%%

selector = false(1, length(timestamps));
for tt = 1:numel(sideOff)
    ind = timestamps > sideOff(tt) & timestamps <= (sideOff(tt) + 20*75);
    selector(ind) = true;
end

selectedCells = setdiff(1:size(binData, 1), [-2]);


binDataAll = binData(selectedCells, selector);
binLocAll = binLoc(:, selector);
trialAll = trial(selector);
choiceAll = choice(trialAll);

plot(binLocAll(1, :), binLocAll(2, :), '.')

%%

BAD = {};
GOOD = {};

for iter = 1:10

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
%  & choice(T.trial) == 0 & choice(T.trial) == 0
    badTrials = T.trial(T.sum_error' > 10 );
    goodTrials = T.trial(T.sum_error' == 0);
    
    badTrialAll = [badTrialAll badTrials(:)'];
    goodTrialAll = [goodTrialAll goodTrials(:)'];

    dataGoodAll = [dataGoodAll binDataTest];
    trialGoodAll = [trialGoodAll trialTest];
    
    % dataGood = binDataTest(:, choiceTest(:) == preds(:));
    % dataBad = binDataTest(:, choiceTest(:) ~= preds(:));
    % 
    % dataGoodAll = [dataGoodAll dataGood];
    % dataBadAll  = [dataBadAll dataBad];

end


BAD{iter} = badTrialAll;
GOOD{iter} = goodTrialAll;

end


BadCount = zeros(1, max(uniqueTrials));
for iter = 1:10
    BadCount(BAD{iter}) = BadCount(BAD{iter}) + 1;
end
badTrialAll = find(BadCount >= 8);



GoodCount = zeros(1, max(uniqueTrials));
for iter = 1:10
    GoodCount(GOOD{iter}) = GoodCount(GOOD{iter}) + 1;
end
goodTrialAll = find(GoodCount >= 10);



badTrialAllC = badTrialAll(choice(badTrialAll) ~= -1);
goodTrialAllC = goodTrialAll(choice(goodTrialAll) ~= -1);

 
selectedTrials = [badTrialAllC goodTrialAllC];


% meanAvticity = [];
% for i = selectedTrials    
%     if(ismember(i, badTrialAll ))        
%         meanAvticity = [meanAvticity mean(dataGoodAll(:, trialGoodAll == i), 2)];                 
%     else       
%         ind = find(trialGoodAll == i);          
%         meanAvticity = [meanAvticity mean(dataGoodAll(:, ind), 2)];                     
%     end
% end
% 
% trialLabel = [ones(1, length(badTrialAllC)), zeros(1, length(goodTrialAllC))];
% Tatalitutu = [meanAvticity; trialLabel];

return


selIndFirstArr = [];
selIndLastArr  = [];

selArr = {};

cnt = 1;

meanAvticity = [];
for i = selectedTrials
    
    if(ismember(i, badTrialAll )) 
        
        selArr{end+1} = find(trialGoodAll == i & errorAll);
        selArr{end} = mod(selArr{end}, 75);
        selArr{end}(selArr{end} == 0) = 75;       
        
        meanAvticity = [meanAvticity mean(dataGoodAll(:, trialGoodAll == i & errorAll), 2)]; 
                
    else
        
          ind = find(trialGoodAll == i);
          ind = ind(selArr{cnt});          
          meanAvticity = [meanAvticity mean(dataGoodAll(:, ind), 2)]; 
          
          cnt = mod((cnt+1), numel(selArr) );
          
          if(cnt == 0)
              cnt = numel(selArr);
          end
    end
end


trialLabel = [ones(1, length(badTrialAllC)), zeros(1, length(goodTrialAllC))];
Tatalitutu = [meanAvticity; trialLabel];

Tatalitutu = Tatalitutu(:, randperm(length(Tatalitutu)));






% [1 5 15 39 58]
% [49 54 17 45 ]




[coeff,score,latent] = pca(Tatalitutu(1:end-1, :)');

figure
plot(score(Tatalitutu(end, :) == 0, 1), score(Tatalitutu(end, :) == 0, 2), '.')
hold on
plot(score(Tatalitutu(end, :) == 1, 1), score(Tatalitutu(end, :) == 1, 2), '.')







batchSize = 1;%floor(numel(badTrialAll) / );

for i = 1:numel(badTrialAll)
    
    testRange = (i-1)*batchSize+1 : i*batchSize;
    if(i == numel(badTrialAll))
        testRange = [testRange testRange(end)+1:numel(badTrialAll)];
    end
    
    trainRange = setdiff(1:numel(badTrialAll), testRange);
    
    trainTrials = badTrialAll(trainRange);
    testTrials = badTrialAll(testRange);
    
    
    %%

    trainSelector = (ismember(trialGoodAll , trainTrials) & errorAll) | (ismember(trialGoodAll , goodTrialAll) & rand(1, length(errorAll)) > 0.85);
    testSelector = ismember(trialGoodAll , testTrials);

    %%

    binDataTrain = dataGoodAll(:, trainSelector);
    labelTrain = errorAll(:, trainSelector);
    trialTrain = trialGoodAll(trainSelector);
    %%

    binDataTest = dataGoodAll(:, testSelector);
    labelTest = errorAll(:, testSelector);

    %%
     
    SVMStruct = fitcsvm(binDataTrain', labelTrain', 'KernelFunction', 'polynomial', 'PolynomialOrder', 1);
    [preds, scores] = predict(SVMStruct, binDataTest');


    acc = mean(labelTest(:) == preds(:));
    [~,~,~,auc] = perfcurve( labelTest(:), scores(:, 2), 1);

    auc

end




h = [];
p = [];
for i = 1:64
    for j = 1:numel(trainTrials)
    [h(i, j), p(i, j)] = ttest2(binDataTrain(i, labelTrain == 0 & trialTrain == trainTrials(j)), binDataTrain(i, labelTrain == 1& trialTrain == trainTrials(j)) )
    end
end


[coeff,score,latent] = pca(binDataTrain(nansum(h') > 7, :)');

plot(score(labelTrain == 0, 1), score(labelTrain == 0, 2), '.')
hold on
plot(score(labelTrain == 1, 1), score(labelTrain == 1, 2), '.')



dataCombined = [dataGoodAll dataBadAll];
label = [ones(1, length(dataGoodAll)), zeros(1, length(dataBadAll))];

TTari = [dataCombined; label];





%%

% plot(choiceTest(:) - preds(:))
% hold on
% plot()







