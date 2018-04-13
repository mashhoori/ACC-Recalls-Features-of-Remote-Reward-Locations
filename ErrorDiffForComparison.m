



for i = 1:7
   
    fileName = ['errOverTime_' num2str(i)];
    a = load(fileName);
    
    arr_1(i) = mean(a.errOverAll(1, :));
    arr_2(i) = mean(a.errOverAll(2, :));
    
    [h, p] = ttest2(a.errOverAll(1, :), a.errOverAll(2, :));
%     fprintf('%.2f %.4f %f2.2  \n', h, p, abs(mean(a.errOverAll(2, :))  - mean(a.errOverAll(1, :)))    );
    
end


[h, p, ci,stats] = ttest(arr_1, arr_2);
pwrout = sampsizepwr('t', [0 .75], 0.6, [], 7)