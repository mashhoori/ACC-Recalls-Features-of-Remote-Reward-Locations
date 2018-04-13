
numList = [15:18 24 25 27];

netError = zeros(1, numel(numList));
bayesError = zeros(1, numel(numList));
bayesErrorNP = zeros(1, numel(numList));

netStd = zeros(1, numel(numList));
bayesStd = zeros(1, numel(numList));
bayesStdNP = zeros(1, numel(numList));

for i = 1:numel(numList)
    
    fname = ['err', num2str(numList(i))];
    A = load(fname);     
    tmp = zeros(1, 10);
    for j = 1:10    
        pred =  A.A(j).pred_v;
        targ = A.A(j).real_v;    
        error = sum(sum((pred - targ).^ 2)) / numel(pred);
        tmp(j) = error;
    end
    netError(i) = mean(tmp);
    netStd(i) = std(tmp);
    %    
    fname = ['errB', num2str(numList(i)), 'P'];
    A = load(fname);    
    tmp = zeros(1, 10);
    for j = 1:10    
        pred =  A.A(j).pred_v;
        targ = A.A(j).real_v;    
        error = sum(sum((pred - targ).^ 2)) / numel(pred);
        tmp(j) = error;
    end
    bayesError(i) = mean(tmp);
    bayesStd(i) = std(tmp);
    %    
    fname = ['errB', num2str(numList(i)), 'NP'];
    A = load(fname);    
    tmp = zeros(1, 10);
    for j = 1:10    
        pred =  A.A(j).pred_v;
        targ = A.A(j).real_v;    
        error = sum(sum((pred - targ).^ 2)) / numel(pred);
        tmp(j) = error;
    end
    bayesErrorNP(i) = mean(error);
    bayesStdNP(i) = std(tmp);
    
end

save('ErrorSummary', 'bayesError', 'bayesErrorNP', 'netError', 'bayesStd', 'bayesStdNP', 'netStd')

load('ErrorSummary.mat')
b = bar([bayesError; bayesErrorNP; netError]');
hold on
errorbar([1:7] - 0.225, bayesError, bayesStd, 'k.')
errorbar(1:7, bayesErrorNP, bayesStdNP, 'k.')
errorbar([1:7] + 0.225, netError, netStd, 'k.')
legend('Bayesian decoder with regularized prior', 'Bayesian decoder with uniform prior', 'Neural network decoder')
xlabel('Session')
ylabel('Mean squared error')
