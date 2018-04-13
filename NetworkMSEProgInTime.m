
clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));
%%

folderNames = {'P1353_15p', 'P1353_16p', 'P1353_17p', 'P1353_18p', 'P1958_24p', 'P1958_25p', 'P1958_27p'};


for rat = 3:numel(folderNames)
    
folderPath = ['E:\New folder\' folderNames{rat} '\'];
    
%%
[data, FTS] = CreateAllData(folderPath, [], 'vtm1.pvd');
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 150, 1);
choice = [data.trInfo.choice];
ramp = [data.trInfo.rampTrial];
ramp(ramp > 0) = 1;
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sfc = [data.trInfo.SideOff];

%%
[timestamps, binData, binLoc, trial] = BinData(data, 50, 0);
binLoc = MapToRect(binLoc, trial, data);

xRatio = 114.3 / 3.35;
yRatio = 101.6 / 3.25;
% 
% binLoc(1, :) = binLoc(1, :) * xRatio;% * 100;
% binLoc(2, :) = binLoc(2, :) * yRatio;% * 100;
% [binLoc, mu, sigma] = zscore(binLoc, 0, 2);
% plot(binLoc(1, :), binLoc(2, :), '.');

%%
[code, codeMap, edgeLoc] = CoarseGrid(binLoc, rat);

%%
selectedTrials00 = data.trials(choice(data.trials) == 0 & ramp(data.trials) == 0 & reward(data.trials) == 0) ;
selectedTrials10 = data.trials(choice(data.trials) == 1 & ramp(data.trials) == 0 & reward(data.trials) == 0) ;
selectedTrials11 = data.trials(choice(data.trials) == 0 & ramp(data.trials) == 0 & reward(data.trials) == 1) ;
selectedTrials01 = data.trials(choice(data.trials) == 1 & ramp(data.trials) == 0 & reward(data.trials) == 1) ;

[~, imax] = max([numel(selectedTrials00) numel(selectedTrials10) numel(selectedTrials11) numel(selectedTrials01)]);


switch imax
    case 1
        selectedTrials = selectedTrials00;
    case 2        
        selectedTrials = selectedTrials10;
    case 3
        selectedTrials = selectedTrials11; 
    case 4
        selectedTrials = selectedTrials01;
end


errOverAll = zeros(2, 10);
for cond = 1:2
    
    for it = 1:10

        AllSelected = selectedTrials;
        r = rand(1, numel(AllSelected));    

        if(cond == 1)
            trainTrials = AllSelected(1:2:end);
            testTrials  = AllSelected(2:2:end);    
        else        
            trainTrials = AllSelected(1:round(numel(selectedTrials)/2));
            testTrials  = AllSelected(round(numel(selectedTrials)/2)+1:end);
        end

        ComputeStatistics(trainTrials, choice, reward, ramp, freeChoice);
        ComputeStatistics(testTrials, choice, reward, ramp, freeChoice);

        trainIndices = ismember(trial, trainTrials);
        testIndices  = ismember(trial, testTrials);

        selectedCells =  1:size(binData, 1);
    % [3 13 22 39 43]
    % [1 6 12 25]
    % [3 7 15 36 39 41]
    % [3 6 26 33 40]
    % [2 13 23 49 60]
    % [5 6 7 14 22 26 31 34 53 59]

        train = binData(selectedCells, trainIndices);
        loc_t = binLoc(:, trainIndices);
        code_t = code(trainIndices);
        trial_t = trial(trainIndices);
        timestamps_t = timestamps(trainIndices);

        indices = randperm(length(loc_t));

        train = train(:, indices);
        loc_t = loc_t(:, indices);
        code_t = code_t(indices);
        trial_t = trial_t(indices);
        timestamps_t = timestamps_t(indices);


        valid = binData(selectedCells, testIndices);
        loc_v = binLoc(:, testIndices);
        code_v = code(testIndices);
        trial_v = trial(testIndices);
        timestamps_v = timestamps(testIndices);

        %%

        save('data', 'train', 'loc_t', 'valid', 'loc_v');
        system('python .\main.py True');
        a = load('data_out');
        res = a.resValid{end}';
        res2 = a.resTrain{end}';

        error = loc_v - res;
        error(1, :) = error(1, :) * xRatio;
        error(2, :) = error(2, :) * yRatio;

        errOverAll(cond, it) = mean(sqrt(sum(error .^ 2)));

    end
    
end

save(['errOverTime_' num2str(rat)], 'errOverAll')


end








