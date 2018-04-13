% 15: 47
% 16: 40
% 17: 42
% 18: 37
% 24: 65
% 25: 59
% 26: 18
% 27: 72
% 28: 7
% 37: 13
% 38: 22
% 39: 19
% 41: 13
% 43: 22
% 44: 24

a = [47 40 42 37 65 59 18 72 7 13 22 19 13 22 24];

numList = [15:18 24:28 37:39 41 43 44];

netError = zeros(1, numel(numList));
netStd = zeros(1, numel(numList));

for i = 1:numel(numList)
    
    fname = ['AllNetError\err', num2str(numList(i))];
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
end

numCell = a;

rat1 = [1:4];
rat2 = [5 6 8];
rat3 = [7 9 10 13];
rat4 = [11 12 14 15];

figure
hold on
plot(a(rat1), netError(rat1), '^')
plot(a(rat2), netError(rat2), 'o')
plot(a(rat3), netError(rat3), 's')
plot(a(rat4), netError(rat4), 'd')

