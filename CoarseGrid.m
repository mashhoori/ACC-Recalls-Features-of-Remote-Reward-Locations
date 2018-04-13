
function [code, codeMap, edgeLoc] = CoarseGrid(binLoc, rat)

% clear
% addpath(genpath('E:\MClust-4.3\'));
% addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));
% 
% %%
% folderPath = 'E:\New folder\P1353_15p\'; 
% data = CreateAllData(folderPath, []);
% data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 70, 1);
% %%
% 
% [timestamps, binData, binLoc, trial] = BinData(data, 20);
% choice = [data.trInfo.choice];
% ramp = [data.trInfo.rampTrial];
% reward = [data.trInfo.durTrial];
% freeChoice = [data.trInfo.freeChoice];
% 
plot(binLoc(1, :), binLoc(2, :), '.');
hold on
%%
% [v, x] = hist(binLoc(1, :), 25);
% 
% [~, ind1] = max(v(x < -0.5));
% x1 = x(ind1+3);
% 
% [~, ind3] = max(v(x < 0.5 & x > -0.5));
% ind3 = ind3 + find(x > -0.5, 1) - 1;
% x2 = x(ind3-2);
% x3 = x(ind3+2);
% 
% [~, ind2] = max(v(x > 0.5));
% ind2 = ind2 + find(x> 0.5, 1) - 1;
% x4 = x(ind2-2);
% 
% X = [-10 x1 (x1+x2)/2 x2 x3 (x3+x4)/2 x4 10];

switch rat
    case 1
        X = [-10 -0.9 -0.5 -0.2 0.25 0.55 0.9 10]; 
    case {2, 3, 4}
        X = [-10 -1.0 -0.6 -0.3 0.25 0.55 0.9 10]; 
    case 5
        X = [-10 -0.9 -0.5 -0.2 0.35 0.7 1.0 10]; 
    case {6, 7}
        X = [-10 -0.9 -0.5 -0.2 0.35 0.7 1.1 10]; 
end

for i = 2:numel(X)-1
    hold on
    line([X(i) X(i)], [-3 3])
end
%%
% 
% [v, y] = hist(binLoc(2, :), 25);
% 
% [~, ind1] = max(v(y < 0));
% y1 = y(ind1+2);
% y2 = y(ind1-1);
% 
% [~, ind2] = max(v(y > 0));
% ind2 = ind2 + find(y> 0, 1) - 1;
% y3 = y(ind2-2);
% 
% [~, ind3] = max(v(y < -0.75));
% y4 = y(ind3+2);

% Y = [-10 y4  y2  y1 (y1+y3)/2  y3 10];
switch (rat)
    case {1, 2, 3, 4}    
        %Y = [-10 -0.9  -0.5  0  0.5  1  1.4 10];
        Y = [-10  -.85 -0.45  -0.12  0.25  0.8  1.4 10];
    case {5, 6, 7}    
        Y = [-10 -0.9  -0.5  0  0.5  1  1.5 10];
end

for i = 2:numel(Y)-1
    hold on
    line([-3 3], [Y(i) Y(i)])
end
%%

code = zeros(1, length(binLoc));
codeMap = zeros(2, (numel(Y)-1) * (numel(X)-1));
for i = 1:(numel(Y)-1)
    for j = 1:(numel(X)-1)      
        ind = binLoc(1, :) > X(j) & binLoc(1, :) <= X(j+1) & binLoc(2, :) > Y(i) & binLoc(2, :) <= Y(i+1);
        code(ind) = (i-1) * (numel(X) - 1) + j;      
        codeMap(:, (i-1) * (numel(X) - 1) + j) = [ (X(j) + X(j+1))/2;  (Y(i+1)+Y(i))/2 ];
        
%         plot(binLoc(1, ind), binLoc(2, ind), '.');
%         title(num2str((i-1) * (numel(X) - 1) + j))
%         pause(1)
%         hold on
    end
end


edgeLoc.x = X;
edgeLoc.y = Y;

end