

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

selectedCells = setdiff(1:size(binData, 1), [-2]);

%%

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
 

    % ------------------------------------------------------------------------
    
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
badTrialAll = find(BadCount >= 10);



GoodCount = zeros(1, max(uniqueTrials));
for iter = 1:10
    GoodCount(GOOD{iter}) = GoodCount(GOOD{iter}) + 1;
end
goodTrialAll = find(GoodCount >= 10);




%%

% uniqueTrials = unique(trialAll);
% 
% uniqueTrials = uniqueTrials(randperm(numel(uniqueTrials)));
% batchSize = floor(numel(uniqueTrials) / 20);
% 
% badTrialAll = [];
% errorAll = [];
% dataGoodAll = [];
% dataBadAll = [];
% trialGoodAll = [];
% 
% goodTrialAll = [];
% 
% for i = 1:20
%     
%     testRange = (i-1)*batchSize+1 : i*batchSize;
%     if(i == 20)
%         testRange = [testRange testRange(end)+1:numel(uniqueTrials)];
%     end
%     
%     trainRange = setdiff(1:numel(uniqueTrials), testRange);
%     
%     trainTrials = uniqueTrials(trainRange);
%     testTrials = uniqueTrials(testRange);
% 
%     %%
% 
%     trainSelector = ismember(trialAll, trainTrials);
%     testSelector = ismember(trialAll, testTrials);
% 
%     %%
% 
%     binDataTrain = binDataAll(:, trainSelector);
%     binLocTrain = binLocAll(:, trainSelector);
%     trialTrain = trialAll(trainSelector);
%     choiceTrain = choiceAll(trainSelector);
% 
%     %%
% 
%     binDataTest = binDataAll(:, testSelector);
%     binLocTest = binLocAll(:, testSelector);
%     trialTest = trialAll(testSelector);
%     choiceTest = choiceAll(testSelector);
% 
% %%
% 
%     SVMStruct = fitcsvm(binDataTrain', choiceTrain', 'KernelFunction', 'polynomial', 'PolynomialOrder', 2);
%     [preds, scores] = predict(SVMStruct, binDataTest');
% 
%     % acc = mean(choiceTest(:) == preds(:));
%     % [~,~,~,auc] = perfcurve( choiceTest(:), scores(:, 2), 1);
%     % badTrials = unique(trialTest(choiceTest(:) ~= preds(:)));
% 
%     T = table(choiceTest(:) ~= preds(:), trialTest(:), 'VariableNames', {'error', 'trial'} );
%     T = grpstats(T, 'trial', 'sum');
% 
%     error = choiceTest(:) ~= preds(:);
% 
%     errorAll = [errorAll error(:)'];
% %   & choice(T.trial) == 1 & choice(T.trial) == 1
%     badTrials = T.trial(T.sum_error' > 10 );
%     goodTrials = T.trial(T.sum_error' == 0 );
%     
%     badTrialAll = [badTrialAll badTrials(:)'];
%     goodTrialAll = [goodTrialAll goodTrials(:)'];
% 
%     dataGoodAll = [dataGoodAll binDataTest];
%     trialGoodAll = [trialGoodAll trialTest];    
%   
% end

ChoiceOneTel = badTrialAll(choice(badTrialAll) == 1);
ChoiceZerTel = badTrialAll(choice(badTrialAll) == 0);

ChoiceOneGood = goodTrialAll(choice(goodTrialAll) == 1);
ChoiceZerGood = goodTrialAll(choice(goodTrialAll) == 0);


%%
%---------------

selectedTrials = [ChoiceOneGood ChoiceOneTel];

meanActivity = [];
trialSelectedEx = [];

for i = selectedTrials      
    
    ind = find(trialGoodAll == i);
    meanActivity = [meanActivity dataGoodAll(:, ind)];  
    trialSelectedEx = [trialSelectedEx ones(1, length(ind)) * i];    
    
    
end

r = rand(1, numel(selectedTrials));
trainTrials = selectedTrials(r <= 0.8);
testTrials = selectedTrials(r > 0.8);

trainSelector = ismember(trialSelectedEx, trainTrials);
testSelector = ismember(trialSelectedEx, testTrials);

%%

binDataTrain = meanActivity(:, trainSelector);
choiceTrain = ismember(trialSelectedEx(trainSelector), ChoiceOneGood);

%%

binDataTest = meanActivity(:, testSelector);
choiceTest = ismember(trialSelectedEx(testSelector), ChoiceOneGood);


%%

SVMStruct = fitcsvm(binDataTrain', choiceTrain', 'KernelFunction', 'polynomial', 'PolynomialOrder', 1);
[preds, score]= predict(SVMStruct, binDataTest');

fprintf('First %f:', mean(preds(:) == choiceTest(:)))

mean(choiceTest(:))

%% ------------------------------------------------------------------------





trialLabel = choice(trialSelectedEx);
Mdl = fitcnb(meanActivity', trialLabel, 'Prior', 'uniform');

% ------------------------------------------------------------------------

selectedTrials = [ChoiceZerTel ChoiceOneTel];
trialSelectedEx = [];
meanActivity = [];
for i = selectedTrials      
    ind = find(trialGoodAll == i & errorAll);
    ind = ind( 15:end-4  );
    length(ind)
    meanActivity = [meanActivity dataGoodAll(:, ind)];  
    trialSelectedEx = [trialSelectedEx ones(1, length(ind)) * i];    
end

trialLabel = 1 - choice(trialSelectedEx);
[pred, score] = predict(Mdl, meanActivity');
mean(pred(:) == trialLabel(:))

%---------------
%%































DARDUR  = [];
for iter =  1:20
     
    
selectedTrials = [ChoiceOneTel ChoiceZerTel];

trialSelectedEx = [];
meanActivity = [];
for i = selectedTrials      
    ind = find(trialGoodAll == i & errorAll);
    meanActivity = [meanActivity dataGoodAll(:, ind)]; 
    trialSelectedEx = [trialSelectedEx ones(1, length(ind)) * i];    
end
trialLabel = choice(trialSelectedEx);    
 

selectedTrials_2 = [ChoiceZerGood(1:5) ChoiceOneGood(1:5)];
trialSelectedEx_2 = [];
for i = selectedTrials_2      
    ind = find(trialGoodAll == i);  
    meanActivity = [meanActivity dataGoodAll(:, ind)]; 
    trialSelectedEx_2 = [trialSelectedEx_2 ones(1, length(ind)) * i];    
end
trialLabel2 = 1 - choice(trialSelectedEx_2); 

trialLabel = [trialLabel trialLabel2];

r = rand(1, numel(selectedTrials));
trainTrials = selectedTrials(r <= 0.8);
testTrials = selectedTrials(r > 0.8);

%%

trainSelector = ismember(trialSelectedEx, trainTrials);
testSelector = ismember(trialSelectedEx, testTrials);

%%

binDataTrain = meanActivity(:, trainSelector);
choiceTrain = trialLabel(trainSelector);

%%

binDataTest = meanActivity(:, testSelector);
choiceTest = trialLabel(testSelector);

%%

SVMStruct = fitcsvm(binDataTrain', choiceTrain', 'KernelFunction', 'polynomial', 'PolynomialOrder', 1);
% ScoreSVMModel = fitSVMPosterior(SVMStruct );'Standardize', true
[preds, score ]= predict(SVMStruct, binDataTest');

fprintf('First %f:', mean(preds(:) == choiceTest(:)))

%%

selectedTrials = [ChoiceOneGood ChoiceZerGood];

meanActivity = [];
trialSelectedEx = [];
for i = selectedTrials        
    ind = find(trialGoodAll == i);   
%     ind = ind(15:end-14);
    meanActivity = [meanActivity dataGoodAll(:, ind)];        
    trialSelectedEx = [trialSelectedEx ones(1, length(ind)) * i];        
end

trialLabel = 1 - choice(trialSelectedEx);
[pred, score] = predict(SVMStruct, meanActivity');

fprintf('..Second %f:', mean(pred(:) == trialLabel(:)))
fprintf('..Third %f\n', max(1 - mean( trialLabel(:)), mean( trialLabel(:))) )

dardar = mean(pred(:) == trialLabel(:));
DARDUR = [DARDUR dardar];

end
mean(DARDUR)



%%

% 
% selectedTrials = [ChoiceOneTel ChoiceOneGood];
% %& ~errorAll
%  
% meanActivity = [];
% for i = selectedTrials      
%     ind = find(trialGoodAll == i );
%     ind = ind(2:end-1);    
%     meanActivity = [meanActivity mean(dataGoodAll(:, ind), 2)];  
% end
% 
% trialLabel = [zeros(1, length(ChoiceOneTel)), ones(1, length(ChoiceOneGood))];
% Tatalitutu = [meanActivity; trialLabel];
% 
% 
% 
% 
% [coeff,score,latent] = pca(meanActivity');
% % plot(score(trialLabel == 0, 1), score(trialLabel == 0, 2), '.')
% % hold on
% % plot(score(trialLabel == 1, 1), score(trialLabel == 1, 2), '.')
% 
% 
% 
% selectedTrials = [ChoiceOneGood ChoiceZerGood];
% 
% meanActivity = [];
% for i = selectedTrials    
%     
%     ind = find(trialGoodAll == i);
%     ind = ind(10:end-14);
%     
%     meanActivity = [meanActivity mean(dataGoodAll(:, ind), 2)];    
%     
% end
% trialLabel = [zeros(1, length(ChoiceOneGood)), ones(1, length(ChoiceZerGood))];
% 
% pred = predict(trainedClassifier.ClassificationSVM, meanActivity');
% mean(pred(:) == trialLabel(:))
% mean( trialLabel(:))
% 
% 
% 
% 
% 
% meanActivity = [];
% for i = selectedTrials
%     
%     if(ismember(i, badTrialAll ))         
%         selArr{end+1} = find(trialGoodAll == i & errorAll);
%         selArr{end} = mod(selArr{end}, 75);
%         selArr{end}(selArr{end} == 0) = 75;               
%         meanActivity = [meanActivity mean(dataGoodAll(:, trialGoodAll == i & errorAll), 2)];                 
%     else        
%           ind = find(trialGoodAll == i);
%           ind = ind(selArr{cnt});          
%           meanActivity = [meanActivity mean(dataGoodAll(:, ind), 2)];           
%           cnt = mod((cnt+1), numel(selArr) );          
%           if(cnt == 0)
%               cnt = numel(selArr);
%           end
%     end
%     
%     ind = find(trialAllCenter == i);
%     meanActivityCenter = [meanActivityCenter mean(binDataAllCenter(:, ind), 2)];    
% end


% trialLabel = [ones(1, length(badTrialAll)), zeros(1, length(goodTrialAll))];
% Tatalitutu = [meanActivity; trialLabel];

% Tatalitutu = Tatalitutu(:, 1:length(badTrialAll) + 3);

% Tatalitutu = Tatalitutu(:, randperm(length(Tatalitutu)));
% 
% 
% cnt = 1;
% meanAvticityOtherFeeder = [];
% selectedTrials = find(choice == 1);
% for i = selectedTrials           
%     
%     ind = find(trialGoodAll == i);
%     
%     if(length(ind) == 75)   
%         ind = ind(selArr{cnt});  
%         meanAvticityOtherFeeder = [meanAvticityOtherFeeder mean(dataGoodAll(:, ind), 2)];  
%         
%         cnt = mod((cnt+1), numel(selArr) );          
%           if(cnt == 0)
%               cnt = numel(selArr);
%           end
%     end    
% end
% 
% 
% meanAvticityOtherFeeder = zscore(meanAvticityOtherFeeder, [], 2);
% 
% pred = predict(trainedClassifier.ClassificationSVM, meanAvticityOtherFeeder');
% mean(pred)
% 
% 
% 
% meanActivityCenter = zscore(meanActivityCenter, [], 2);
% 
% pred = predict(trainedClassifier.ClassificationSVM, meanActivityCenter');
% mean(pred)
% 
