

addpath(genpath('E:\Downloads\drtoolbox'))

folderNames = {'P1353_15p', 'P1353_16p', 'P1353_17p', 'P1353_18p', 'P1958_24p', 'P1958_25p', 'P1958_27p'};
outputNames = {'thN15p75_50', 'thN16p75_50', 'thN17p75_50', 'thN18p75_50', 'thN24p75_50', 'thN25p75_50', 'thN27p75_50'};

ratioForced = [];
ratioFree = [];
ratioAll = [];

nonFavSide = [0 1 0 1 0 0 0];

AUC = []; 
ValACC = [];

accuracy = [];
cnt = 1;
for rat = 1:numel(folderNames)

fprintf('rat %d \n ', rat);
folderPath = ['E:\New folder\' folderNames{rat} '\']; 

data = CreateAllData(folderPath, []);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 120, 1);
[timestamps, binData, binLoc, trial] = BinData(data, 20, 0);

%%
choice = [data.trInfo.choice];
ramp   = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sideOff    = [data.trInfo.SideOff];
centerOff  = [data.trInfo.centralOff];

load(outputNames{rat});

counterAll = zeros(1, numel(choice));
counter = zeros(1, numel(choice));
for i = 1:10
    counterAll(RD.tr_c{i}) = counterAll(RD.tr_c{i}) + 1;
    counter(RD.tr{i}) = counter(RD.tr{i}) + 1;    
end
ratio = counter ./ counterAll;
ratio (isnan(ratio)) = -1;

good = find(ratio == 0 & counterAll > 0  );
bad  = find(ratio > 0.0 & counterAll > 0);
selectedTrials = [good bad];

acc = [];
for iter = 1:10

r = rand(1, numel(good)) <= 0.75;
trainTrial = good(r); %bad(r);
testTrial = bad;%good(~r);%;;%bad;%;


sideInd = false(1, numel(timestamps));
for tt = 1:numel(selectedTrials)
    tr = selectedTrials(tt);
    sideInd = sideInd |  timestamps > sideOff(tr) & timestamps <= (sideOff(tr) + 20*75);    
end

trainSelector = ismember(trial, trainTrial) & sideInd;
testSelector = ismember(trial, testTrial) & sideInd;

trainData = binData(:, trainSelector );
testData  = binData(:, testSelector );

trainTarget = choice(trial(trainSelector ));
testTarget = choice(trial(testSelector ));

finalData = [trainData; trainTarget];

SVMStruct = fitcsvm(trainData', trainTarget', 'KernelFunction', 'polynomial', 'PolynomialOrder', 1);
[preds, scores ]= predict(SVMStruct, testData');

acc(iter) = sum(testTarget(:) == preds(:)) / numel(preds);
[~,~,~,auc(iter)] = perfcurve( testTarget(:),scores(:, 2), 1);


end


accuracy(rat) = mean(acc);
stdAccuracy(rat)  = std(acc);
aucAll(rat) = mean(auc);
stdAuc(rat)  = std(auc);

% accuracy
%[trainedClassifier, validationAccuracy, validationScores] = trainClassifierSVM(finalData);
% data = [];
% label = [];
% for i = 1:numel(selectedTrials)  
%     if(DATA(i).choice ~= nonFavSide(rat))
%         
%         if(DATA(i).condition == 0)
%             %minInd = round(min(DATA(i).middleMarker(DATA(i).middleMarker ~= -1)));
%             %maxInd = round(max(DATA(i).middleMarker(DATA(i).middleMarker ~= -1)));
%             ind = round(median(DATA(i).middleMarker(DATA(i).middleMarker ~= -1)));
%             ind = max(ind, 2);
%             ind = min(ind, 74);
%             data = [data mean(DATA(i).trialData(:, ind-1:ind+1), 2)];
%         else
%             data = [data mean(DATA(i).trialData(:, 35:45), 2)];
%         end
%         
%         label = [label DATA(i).condition];   
%     end
% end
% finalData = [ data; label];
% finalData = finalData(:, randperm(size(finalData, 2)));
% %finalData(1, :) = finalData(1, randperm(size(finalData, 2)));
% label = finalData(end, :);

% [trainedClassifier, validationAccuracy, validationScores] = trainClassifierBaggedTree(finalData);
% [~, ~, ~, auc] = perfcurve(finalData(end, :), validationScores(:, 1) , 0);
% AUC(rat) = auc; 
% ValACC(rat) = validationAccuracy;

% figure
% [score, mapping] = compute_mapping(finalData', 'LDA', 2);
% % [coeff,score,latent] = ppca(data', 2);
% plot(score(label == 0, 1), 'o')%, score(label == 0, 2), 'o')
% hold on
% plot(score(label == 1, 1), '*')%, score(label == 1, 2), 'o')
% 


end


save('badTrials', 'accuracy', 'stdAccuracy', 'aucAll', 'stdAuc')




