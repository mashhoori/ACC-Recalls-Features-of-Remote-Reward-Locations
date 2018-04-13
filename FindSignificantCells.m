
function y = FindSignificantCells(mt, condition, condition2)

if(nargin < 3)
     condition2 = ones(size(condition));
end


for i = 1:size(mt, 1)
    x1 = mt(i,  condition == 1 & condition2 == 1);
    x2 = mt(i,  condition == 0 & condition2 == 1);    
    
    x1 = sort(x1);
    x1 = x1(5:end-4);
    
    x2 = sort(x2);
    x2 = x2(5:end-4);    
    
    x1 = sqrt(x1);
    x2 = sqrt(x2);
    [y(i), p(i)] = ttest2(x1, x2, 'Alpha', 0.01);    
end
y(isnan(y)) = 0;
sum(y)

end