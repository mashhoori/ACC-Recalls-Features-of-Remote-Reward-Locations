clear

numbers = {'15', '16', '17', '18', '24', '25', '27'};
folderNames = {'P1353_15p', 'P1353_16p', 'P1353_17p', 'P1353_18p', 'P1958_24p', 'P1958_25p', 'P1958_27p'};

load('Ratio.mat')

for rat = 1:7
% addpath(genpath('E:\MClust-4.3\'));
% addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));
% %%
% folderPath = ['E:\New folder\', folderNames{rat}, '\']; 
% data = CreateAllData(folderPath, []);
% data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 150, 1);
% 
% %%
% [timestamps, binData, binLoc, trial] = BinData(data, 50, 0);
% binLoc = MapToRect(binLoc, trial, data);
% plot(binLoc(1, :), binLoc(2, :), '.');

%%

% [v, y] = hist(binLoc(2, :), 20);
% [~, yBotInd] = max(  v( y < -0.5)  );
% ybot = y(yBotInd);
% [~, yTopInd] = sort(  v(y > 0.5), 'descend');
% yTopInd = yTopInd(1:2) + find(y > 0.5, 1, 'first') - 1 ;
% yTop = mean(y(yTopInd));
% 
% 
% [v, x] = hist(binLoc(1, :), 20);
% [~, xminind] = max(v(x < -0.5));
% xleft = x(xminind);
% [~, xminind] = max(v(x > 0.5));
% xright = x(xminind + find(x > 0.5, 1, 'first') - 1);
% 
% xLen = 1;
% yLen = 0.85;
% 
% xRatio(rat) = xLen / (xright - xleft);
% yRatio(rat) = yLen / (yTop - ybot);

% xRatio(rat)  = 1;
% yRatio(rat)  = 1;



%%

load(['Errors\err', numbers{rat}, 'New'])
for i = 1:10
    error = A(i).real_v - A(i).pred_v;
    error(1, :) = error(1, :) * xRatio(rat);
    error(2, :) = error(2, :) * yRatio(rat);
    
    %mse(i) = sum(sum(error .^ 2)) / numel(error);
    mse(i) = mean(sqrt(sum(error .^ 2)));
end
    
%netError(rat) = sqrt(mean(mse));
netError(rat) = mean(mse);
netStd(rat) = std( sqrt( mse) );

%%

load(['Errors\errB', num2str(numbers{rat}), 'NP'])
for i = 1:10
    error = A(i).real_v - A(i).pred_v;
    error(1, :) = error(1, :) * xRatio(rat);
    error(2, :) = error(2, :) * yRatio(rat);
    
    %mse(i) = sum(sum(error .^ 2)) / numel(error);
    mse(i) = mean(sqrt(sum(error .^ 2)));

end
    
%bayesErrorNP(rat) = sqrt(mean(mse));
bayesErrorNP(rat) = mean(mse);
bayesStdNP(rat) = std(sqrt(mse));

%%

load(['Errors\errB', num2str(numbers{rat}), 'P'])
for i = 1:10
    error = A(i).real_v - A(i).pred_v;
    error(1, :) = error(1, :) * xRatio(rat);
    error(2, :) = error(2, :) * yRatio(rat);
    
    mse(i) = sum(sum(error .^ 2)) / numel(error);
end
    
bayesError(rat) = sqrt(mean(mse));
bayesStd(rat) = std(sqrt(mse));


end


save('ErrorSummary_CM2', 'netError', 'bayesErrorNP', 'bayesError', 'netStd', 'bayesStdNP', 'bayesStd')
save('Ratio', 'xRatio', 'yRatio')


%%

kernelWidth = [50, 75, 100, 150, 200, 300, 500, 700, 1000, 1500];
matrix = zeros(7, numel(kernelWidth));

for rat = 1:7
for kw = 1:numel(kernelWidth)
    A = load(['Kernel_', numbers{rat}, '\kernel_', num2str(kernelWidth(kw))]);
    A = A.A;
    
    for i = 1:10
        error = A(i).real_v - A(i).pred_v;
        error(1, :) = error(1, :) * xRatio(rat);
        error(2, :) = error(2, :) * yRatio(rat);
        
        mse(i) = sum(sum(error .^ 2)) / numel(error);
    end
    
    matrix(rat, kw) = mean(mse);    
end
end

%%

% clear

load('Ratio.mat')
folderPath = 'E:\New folder\P1353_16p\'; 

data = CreateAllData(folderPath, []);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 150, 1);
choice = [data.trInfo.choice];

%%
[timestamps, binDataAll, binLoc, trial] = BinData(data, 50, 0);
binLoc = MapToRect(binLoc, trial, data);

%%
posTrial = data.trials(choice(data.trials) == 1);
negTrial = data.trials(choice(data.trials) == 0);
minNum = min(numel(posTrial), numel(negTrial));

bestErrorForNumCell = [0.8614    0.6986    0.5496    0.4474    0.3493    0.2964    0.2338    0.2029];
bestCells = [22    18    26     4    29    23     6     1    31    17    24    21    16    30    27    33     2    14    20    36];

for numCell = 1:20 
    numCell
        candidateSet = bestCells(1:numCell);       
        binData = binDataAll(candidateSet, :);

        err = [];
        for it = 1:5
            selectedPos = randsample(posTrial, minNum);
            selectedNeg = randsample(negTrial, minNum);

            AllSelected = [selectedPos selectedNeg];

            r = rand(1, numel(AllSelected));
            trainTrials = AllSelected(r <= 0.75);
            testTrials  = AllSelected(r >  0.75);           

            trainIndices = ismember(trial, trainTrials);
            testIndices  = ismember(trial, testTrials);

            train = binData(:, trainIndices);
            loc_t = binLoc(:, trainIndices);

            indices = randperm(length(loc_t));
            train = train(:, indices);
            loc_t = loc_t(:, indices);

            valid = binData(:, testIndices);
            loc_v = binLoc(:, testIndices);

            trial_t = trial(trainIndices);
            trial_v = trial(testIndices);

            timestamps_t = timestamps(trainIndices);
            timestamps_v = timestamps(testIndices);

            save('data', 'train', 'loc_t', 'valid', 'loc_v');
            system('python C:\Users\a.mashhoori\Desktop\Proj\Scripts\main.py');
            a = load('data_out');
            res = a.res';         
            
            e = loc_v - res;
            
            e(1, :) = e(1, :) * xRatio(2);
            e(2, :) = e(2, :) * yRatio(2);
            
            err(it) = sum(sum(e .^ 2)) / numel(loc_v);
            fprintf('The error for it %d is %f \n', it, err(it));
        end
        
        error(numCell) = mean(err);           
end
return 

ggg = error;

%  26     4    14    24     1    30    23    33    18    38    36    31     6    39     2     5    32    20    29    19
% 1.0375    0.8386    0.5976    0.4954    0.4008    0.3343    0.2761    0.2032    0.1522    0.1292    0.1573    0.1372    0.1125    0.1068    0.1049    0.1074 0.1045    0.1052    0.1057    0.0851

% 22    18    26     4    29    23     6     1    31    17    24    21    16    30    27    33     2    14    20    36

%%

kernelWidth = [4:4:40];
matrix = zeros(5, numel(kernelWidth));

for rat = 1:5
for kw = 1:numel(kernelWidth)
    A = load(['NumCell_16\kernel_', num2str(kernelWidth(kw)), '_', num2str(rat)]);
    A = A.A;
    
    for i = 1:5
        error = A(i).real_v - A(i).pred_v;
        error(1, :) = error(1, :) * xRatio(2);
        error(2, :) = error(2, :) * yRatio(2);
        
        mse(i) = sum(sum(error .^ 2)) / numel(error);
    end
    
    matrix(rat, kw) = mean(mse);    
end
end

%%

numbers = [15:18 24:28 37:39 41 43 44];
matrix = zeros(1, numel(numbers));

for kw = 1:numel(numbers)
    A = load(['AllNetError\err', num2str(numbers(kw))]);
    A = A.A;    
    for i = 1:10
        error = A(i).real_v - A(i).pred_v;
        error(1, :) = error(1, :) * mean(xRatio);
        error(2, :) = error(2, :) * mean(yRatio);
        
        mse(i) = sum(sum(error .^ 2)) / numel(error);
    end
    
    matrix(1, kw) = mean(mse);    
end


