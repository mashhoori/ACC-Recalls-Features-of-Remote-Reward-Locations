


clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));
%%

folderPath = 'E:\New folder\P1958_25p\';

%%

load('Ratio.mat')
[data, FTS] = CreateAllData(folderPath, [], 'vtm1.pvd');
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 150, 1);
choice = [data.trInfo.choice];
ramp = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sfc = [data.trInfo.SideOff];

%%
[timestamps, binData, binLoc, trial] = BinData(data, 50, 0);
binLoc = MapToRect(binLoc, trial, data);

binLoc(1, :) = binLoc(1, :) * xRatio(6) * 100;
binLoc(2, :) = binLoc(2, :) * yRatio(6) * 100;

%%

uTrials = unique(trial);

DataALL = [];
for trInd = 1:numel(uTrials)
   
    DataALL(trInd).dataMatrix = binData(:, trial == uTrials(trInd));
    DataALL(trInd).location   =  binLoc(:, trial == uTrials(trInd));
    
    DataALL(trInd).trialIndex = trInd;
    DataALL(trInd).choice = choice(uTrials(trInd));
%     DataALL(trInd).reward = reward(uTrials(trInd));    
end

save('Session_6', 'DataALL')

%%


meanError = [];
stdError = [];

for s_id = 1:7
    
    fileName = ['Session_', num2str(s_id)];
    load(fileName)


    choice = [DataALL.choice];

    posTrial = find(choice == 1);
    negTrial = find(choice == 0);

    minNum = min([numel(posTrial), numel(negTrial)]);

    errList = [];
    for it = 1:10

        selectedPos = randsample(posTrial, minNum);
        selectedNeg = randsample(negTrial, minNum);

        AllSelected = [selectedPos selectedNeg];

        r = rand(1, numel(AllSelected));
        trainTrials = AllSelected(r <= 0.75);
        testTrials  = AllSelected(r  > 0.75);

        train = [DataALL(trainTrials).dataMatrix];
        train_loc = [DataALL(trainTrials).location];

        test = [DataALL(testTrials).dataMatrix];
        test_loc = [DataALL(testTrials).location];

        %%

        save('data', 'train', 'train_loc', 'test', 'test_loc');
        system('python .\LocNet.py');
        a = load('data_out');
        pred_loc = a.resValid{end}';

        error = test_loc - pred_loc;

        errList(it) = sqrt(  sum(sum(error .^ 2)) / numel(error)  );

    end

    meanError(s_id) = mean(errList);
    stdError(s_id)  = std(errList);
end



