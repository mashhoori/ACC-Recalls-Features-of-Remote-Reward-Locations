% %%

clear

trInfo = LoadData(150);
assignment = BinData2(trInfo, 50);
location = MapToRect([assignment.loc], [assignment.trNO_arr], [assignment.choice]);

xRatio = 114.3 / 3;
yRatio = 101.6 / 3.05;

location(1, :)  = location(1, :) * xRatio;
location(2, :)  = location(2, :) * yRatio;

[code, codeMap, gridDim, edgeLoc] = GridLocations(location, [3.7 2.6]);     
[codeCoarse, codeMapCoarse, edgeLocCoarse] = CoarseGrid(location, 1);     

assignment = PutBackValuesFromArray(assignment, location, 'loc');
assignment = PutBackValuesFromArray(assignment, code, 'code');
assignment = PutBackValuesFromArray(assignment, codeCoarse, 'codeCoarse');
 
% close all 

%%

errorNet = [];
errorBayes = [];

for iter = 1:10

    uniqueTrials = 1:numel(assignment);
    r = rand(1, numel(uniqueTrials));
    trainTrials = uniqueTrials(r < 0.8);
    testTrials = uniqueTrials(r >= 0.8);
    
    trainData = [assignment(trainTrials).spike] * 50; 
    testData  = [assignment(testTrials).spike] * 50;     
    trainLoc = [assignment(trainTrials).loc]; 
    testLoc  = [assignment(testTrials).loc];
    trainVel = [assignment(trainTrials).vel];
    testVel = [assignment(testTrials).vel];
    testTrial = [assignment(testTrials).trNO_arr];
    trainCode = [assignment(trainTrials).code];
    testCode = [assignment(testTrials).code];
    testCodeC = [assignment(testTrials).codeCoarse];
  
    trainData = trainData(:, trainVel >= 0.3);
    trainLoc = trainLoc(:, trainVel >= 0.3);
    trainCode = trainCode(trainVel >= 0.3);

    testData = testData(:, testVel >= 0.3);
    testLoc = testLoc(:, testVel >= 0.3);    
    testTrial =  testTrial(testVel >= 0.3);
    testCode = testCode(testVel >= 0.3);
    testCodeC = testCodeC(testVel >= 0.3);
    %%

    [trainSet, mu, sigma] = zscore(trainData, [], 2);
    testSet = bsxfun(@minus, testData, mu);
    testSet = bsxfun(@rdivide, testSet, sigma + 0.000001); 

    indices = randperm(length(trainSet));
    trainSet = trainSet(:, indices);
    trainTarget = trainLoc(:, indices);
    testTarget = testLoc;    

    save('.\data', 'trainSet', 'testSet', 'trainTarget', 'testTarget');
    system('python ".\mainLoc.py" True ./modelWeights');
    a = load('.\data_out');    
    predLocationNet = a.resV';
    error = testLoc - predLocationNet;

    errorNet(iter) = sqrt(sum(sum((error) .^ 2)) / numel(predLocationNet)); 
    
%    Animate(testLoc(:, testTrial >= 5), predLocationNet(:, testTrial >= 5), 0.01, [-120 120 -120 120], 0); 

    %%

%     [code, codeMap, gridDim, edgeLoc] = GridLocations(trainLoc, [4 3]);     

    meanFR = GetMeanFiringRateByCell(trainData, trainCode, gridDim);
    [predCode, probs] = BayesianPrediction(testData, meanFR, []);
    predLocationBayes = codeMap(:, predCode);
    
    error = testLoc - predLocationBayes;      
    errorBayes(iter) = sqrt(sum(sum((error) .^ 2)) / numel(predLocationBayes));     

    A(iter).pred_bayes = predLocationBayes;
    A(iter).pred_net = predLocationNet;
    A(iter).real_v = testLoc;                      
    A(iter).trial_v = testTrial;
    A(iter).code_v = testCode;
    A(iter).codeCoarse_v = testCodeC;

%   Animate(testLoc(:, testTrial == 5), predLocationBayes(:, testTrial == 5), 0.01, [-3 3 -3 3], 0); 

end

results.errorNet = errorNet;
results.errorBayes = errorBayes;
results.A = A;

return


%     error(1, :)  = error(1, :) * xRatio;
%     error(2, :)  = error(2, :) * yRatio;    
%     error(1, :)  = error(1, :) * xRatio;
%     error(2, :)  = error(2, :) * yRatio;    
    

% sum(sum((results.A(3).pred_net(:, results.A(3).trial_v(:)~= 111) - results.A(3).real_v(:, results.A(3).trial_v(:)~= 111)) .^ 2)) / numel(results.A(3).real_v(:, results.A(3).trial_v(:)~= 111))
% 
% errorB = (results.A(1).pred_bayes  - results.A(1).real_v);
% errorN = (results.A(1).pred_net  - results.A(1).real_v);
% 
%  plot( [1:length(errorB)] / 20 ,  sum(errorB .^ 2))
%  hold on
%  plot( [1:length(errorN)] / 20,  sum(errorN .^ 2))
% 
%  
% 
% 
% sqrt(sum(sum(error .^ 2)) / (numel(error)))
% mean(sqrt(sum(error .^ 2)))
% 
% errorBayes = sum((results.A(1).pred_bayes  - results.A(1).real_v) .^ 2);
% errorNet = sum((results.A(1).pred_net - results.A(1).real_v) .^ 2);
% tbl = table(results.A(1).trial_v(:), errorNet(:), errorBayes(:), 'VariableNames', {'tr', 'errNet', 'errBayes'});
% T = grpstats(tbl, 'tr', 'median');


% 104 123 31 75 9  26 151 291 221