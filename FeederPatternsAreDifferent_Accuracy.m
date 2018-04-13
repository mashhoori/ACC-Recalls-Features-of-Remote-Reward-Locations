
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));
%%
folderPath = 'E:\New folder\P1958_27p\'; 

[data, FTS] = CreateAllData(folderPath, [], 'vtm1.pvd');
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 120, 1);
choice = [data.trInfo.choice];
ramp = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sfc = [data.trInfo.SideOff];

[timestamps, binData, binLoc, trial] = BinData(data, 20, 0);
%%


trials = unique(trial);

posTrials  =  trials(ismember(trials, find(choice == 1)));
negTrials  =  trials(ismember(trials, find(choice == 0)));


numPos = numel(posTrials);
numNeg = numel(negTrials);

numSel = min(numPos, numNeg);

ratio = zeros(1, 10);
acc_iter = zeros(1, 10);
R_Final = zeros(1, 10);
for it = 1:10
    
    selectedPos = randsample(posTrials, numSel);
    selectedNeg = randsample(negTrials, numSel);
    selectedAll = [selectedPos selectedNeg];
        
    selector = false(1, length(timestamps));
    for tt = 1:numel(selectedAll)
        ind = timestamps > sfc(selectedAll(tt)) & timestamps <= (sfc(selectedAll(tt)) + 20*75);
        selector(ind) = true;
    end
    
    selectedData = binData(:, selector);
    selectedChoice = choice(trial(selector)) == 0;
    selectedTrial = trial(selector);
    
    r = rand(size(selectedAll));
    trainIndices = selectedAll(r > 0.25);
    testIndices  = selectedAll(r <= 0.25); 
    
    trainSelector = ismember(selectedTrial, trainIndices);
    testSelector  = ismember(selectedTrial, testIndices);    
    
    trainData = selectedData(:, trainSelector);
    trainTarget = selectedChoice(trainSelector);
    testData  = selectedData(:, testSelector);
    testTarget = selectedChoice(testSelector);
    testTrial = selectedTrial(testSelector);
    
    [B, FitInfo] = lassoglm(trainData', trainTarget', 'binomial', 'Alpha', 0.001, 'CV', 3, 'Options', statset('UseParallel', true));
    ind = FitInfo.IndexMinDeviance; 

    preds = glmval([FitInfo.Intercept(ind); B(:, ind)], testData', 'logit') > 0.5;
    acc_iter(it) = sum(preds(:) == testTarget(:))/ numel(testTarget(:)); 
       
    errorTrials  = unique(testTrial(preds(:) ~= testTarget(:)));
    ratio(it) = numel(errorTrials) / numel(testIndices);

    
%     R1 = sum(freeChoice(errorTrials) == 0 & choice(errorTrials) == 0) / sum(freeChoice(errorTrials) == 0);
%     R2 = sum(freeChoice == 1 & choice == 0) / sum(freeChoice == 1);
%     R_Final(it) = R1;    
    
end




