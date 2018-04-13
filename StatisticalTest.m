clear

numbers = {'15', '16', '17', '18', '24', '25', '27'};
folderNames = {'P1353_15p', 'P1353_16p', 'P1353_17p', 'P1353_18p', 'P1958_24p', 'P1958_25p', 'P1958_27p'};

h = [];
p = [];

netErrorAll = [];
bayesErrorAll = [];

for rat = 1:7
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));
%%
folderPath = ['E:\New folder\', folderNames{rat}, '\']; 
data = CreateAllData(folderPath, []);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 150, 1);

%%
[timestamps, binData, binLoc, trial] = BinData(data, 50, 0);
binLoc = MapToRect(binLoc, trial, data);
plot(binLoc(1, :), binLoc(2, :), '.');

%%

[v, y] = hist(binLoc(2, :), 20);
[~, yBotInd] = max(  v( y < -0.5)  );
ybot = y(yBotInd);
[~, yTopInd] = sort(  v(y > 0.5), 'descend');
yTopInd = yTopInd(1:2) + find(y > 0.5, 1, 'first') - 1 ;
yTop = mean(y(yTopInd));


[v, x] = hist(binLoc(1, :), 20);
[~, xminind] = max(v(x < -0.5));
xleft = x(xminind);
[~, xminind] = max(v(x > 0.5));
xright = x(xminind + find(x > 0.5, 1, 'first') - 1);

xLen = 1;
yLen = 0.85;

xRatio(rat) = xLen / (xright - xleft);
yRatio(rat) = yLen / (yTop - ybot);

% xRatio(rat)  = 1;
% yRatio(rat)  = 1;

%%

load(['Errors\err', numbers{rat}])
for i = 1:10
    error = A(i).real_v - A(i).pred_v;
    error(1, :) = error(1, :) * xRatio(rat);
    error(2, :) = error(2, :) * yRatio(rat);
    
    mse(i) = sum(sum(error .^ 2)) / numel(error);
end
    
netError = sqrt(mse);

%%

load(['Errors\errB', num2str(numbers{rat}), 'NP'])
for i = 1:10
    error = A(i).real_v - A(i).pred_v;
    error(1, :) = error(1, :) * xRatio(rat);
    error(2, :) = error(2, :) * yRatio(rat);
    
    mse(i) = sum(sum(error .^ 2)) / numel(error);
end
    
bayesErrorNP = sqrt(mse);

%%

load(['Errors\errB', num2str(numbers{rat}), 'P'])
for i = 1:10
    error = A(i).real_v - A(i).pred_v;
    error(1, :) = error(1, :) * xRatio(rat);
    error(2, :) = error(2, :) * yRatio(rat);
    
    mse(i) = sum(sum(error .^ 2)) / numel(error);
end
    
bayesError = sqrt(mse);

% [h(rat),p(rat)] = ttest(netError, bayesErrorNP);
netErrorAll = [netErrorAll mean(netError)];
bayesErrorAll = [bayesErrorAll mean(bayesErrorNP)];

end

[h, p,~, stats] = ttest(netErrorAll, bayesErrorAll);
pwrout = sampsizepwr('t', [0, stats.sd], -0.0353 , [], 7);
pwrout = sampsizepwr('t', [0, 1], stats.tstat , [], 7);


% save('StatsForComparison_1', 'h', 'p');

% save('ErrorSummary_CM2', 'netError', 'bayesErrorNP', 'bayesError', 'netStd', 'bayesStdNP', 'bayesStd')
% save('Ratio', 'xRatio', 'yRatio')
