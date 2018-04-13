% clear
% %%
% folderPath = 'E:\New folder\P1958_24p\'; 
% data = CreateAllData(folderPath, []);
% % 

function binLoc = MapToRect(binLoc, trial, data)


% [timestamps, binData, binLoc, trial] = BinData(data, 50);
choice = [data.trInfo.choice];
ramp = [data.trInfo.rampTrial];

posTrial = find(choice == 1  & ramp == 0);
negTrial = find(choice == 0 & ramp == 0);

r0Trial = find(ramp == 0);
r1Trial = find(ramp == 1);

posIndices = ismember(trial, posTrial);
negIndices = ismember(trial, negTrial);

r0Indices = ismember(trial, r0Trial);
r1Indices = ismember(trial, r1Trial);

% plot(binLoc(1, posIndices), binLoc(2, posIndices))

posLoc = binLoc(:, posIndices);
negLoc = binLoc(:, negIndices);

loc{1} = posLoc;
loc{2} = negLoc;

for i = 1:2

[v, y] = hist(loc{i}(2, :), 40);
[~, yMidInd] = max(  v(y < 0)  );
ymid(i) = y(yMidInd);
[~, yBotInd] = max(  v(1:(yMidInd - 2))  );
ybot(i) = y(yBotInd);
[~, yTopInd] = sort(  v(y > ymid(i)), 'descend');
yTopInd = yTopInd(1) + yMidInd ;
yTop(i) = mean(y(yTopInd));

% plot(loc{i}(1, :), loc{i}(2, :), '.')
% hold on
% line([-2 2], [yTop(i) yTop(i)]) 
% line([-2 2], [mean(ymid) mean(ymid)]) 
% line([-2 2], [ybot(i) ybot(i)]) 

end

[v, x] = hist(binLoc(1, :), 50);
[~, xminind] = max(v);
xmid = x(xminind);

[v, x] = hist(posLoc(1, :), 20);
[~, xminind] = max(v(1:5));
xleft = x(xminind);

[v, x] = hist(negLoc(1, :), 20);
[~, xminind] = max(v(end-4:end));
xright = x(xminind+15);


% line([xleft xleft], [-2.5 2.5]) 
% line([xmid xmid], [-2.5 2.5]) 
% line([xright xright], [-2.5 2.5]) 


% binLoc(2, :) = binLoc(2, :) - ymid(i);  
%     
% binLoc(2, binLoc(2, :) > 0) = binLoc(2, binLoc(2, :) > 0) * 1.8 / (yTop(i) - ymid(i));
% binLoc(2, binLoc(2, :) < 0) = binLoc(2, binLoc(2, :) < 0) * 1.2 / (ymid(i) - ybot(i));
% 
% binLoc(1, :) = binLoc(1, :) - xmid; 
% 



binLoc(2, :) = binLoc(2, :) - mean(ymid);  


posTrial = find(choice == 1);
negTrial = find(choice == 0);



selectedIndices = binLoc(2, :) > 0 & ismember(trial, posTrial);
binLoc(2, selectedIndices) = binLoc(2, selectedIndices) * 1.8 / (yTop(1) - ymid(1));
selectedIndices = binLoc(2, :) < 0 & ismember(trial, posTrial);
binLoc(2, selectedIndices) = binLoc(2, selectedIndices) * 1.2 / (ymid(1) - ybot(1));


selectedIndices = binLoc(2, :) > 0 & ismember(trial, negTrial);
binLoc(2, selectedIndices) = binLoc(2, selectedIndices) * 1.8 / (yTop(2) - ymid(2));
selectedIndices = binLoc(2, :) < 0 & ismember(trial, negTrial);
binLoc(2, selectedIndices) = binLoc(2, selectedIndices) * 1.2 / (ymid(2) - ybot(2));


binLoc(1, :) = binLoc(1, :) - xmid; 

selectedIndices = ismember(trial, posTrial);
binLoc(1, selectedIndices) = binLoc(1, selectedIndices) * 1.5 / abs(xleft - xmid);

selectedIndices = ismember(trial, negTrial);
binLoc(1, selectedIndices) = binLoc(1, selectedIndices) * 1.5 / abs(xright - xmid);












% % 
% binLoc(1, binLoc(1, :) > 0) = binLoc(1, binLoc(1, :) > 0) * 1.5 / (xright - xmid);
% binLoc(1, binLoc(1, :) < 0) = binLoc(1, binLoc(1, :) < 0) * 1.5 / (xmid - xleft);

% figure
% plot(binLoc(1, posIndices), binLoc(2, posIndices), '.')
% hold on
% plot(binLoc(1, negIndices), binLoc(2, negIndices), '.')
% 
% BL = binLoc;
% 
% BL(1, BL(1, :) < -0.75) = -0.75;
% BL(1, BL(1, :) > 0.75) = 0.75;
% BL(2, BL(2, :) > 1.75) = 1.75;
% BL(2, BL(2, :) < -0.9) = -0.9;
% BL(1, BL(1, :) > -0.1 & BL(1, :) < 0.1) = 0;
% BL(1, BL(2, :) < 1.75 & BL(1, :) > -0.4 & BL(1, :) < 0.4 & BL(2, :) > -0.9 ) = 0;
% 
% figure
% plot(BL(1, :), BL(2, :), '.')

% 
% 
% line([0.1 0.1], [-2 3])
% line([0.85 0.85], [-2 3])
% 
% 
% 
% line([-0.25 -0.25], [-2 3])
% line([-0.15 -0.15], [-2 3])
% line([-0.68 -0.68], [-2 3])
% line([-0.72 -0.72], [-2 3])
% line([-1.5 1.5], [1.6 1.6])
% line([-1.5 1.5], [-1 -1])
% 
% 
% line([0.20 0.20], [-2 3])
% line([0.15 0.15], [-2 3])
% line([0.8 0.8], [-2 3])
% line([-1.5 1.5], [1.6 1.6])
% line([-1.5 1.5], [-.9 -.9])
% 
% 
% line([-0.72 -0.72], [-2 3])
% 
% 
% 
% 
% 
% 
% 
% 
% 
% ind = (binLoc(2, :) < 1.5);
% plot(binLoc(1, ind), binLoc(2, ind), '.')
% 
% [v, x] = hist(binLoc(2, ind), 11);


% binLoc
% for i = 1:2    
%     loc{i}(2, :) = loc{i}(2, :) - ymid(i);  
%     
%     loc{i}(2, loc{i}(2, :) > 0) = loc{i}(2, loc{i}(2, :) > 0) * 1.8 / (yTop(i) - ymid(i));
%     loc{i}(2, loc{i}(2, :) < 0) = loc{i}(2, loc{i}(2, :) < 0) * 1.2 / (ymid(i) - ybot(i));
%     
%     loc{i}(1, :) = loc{i}(1, :) - xmid; 
% end
% 
% % figure
% for i = 1:2    
%     plot(loc{i}(1, :), loc{i}(2, :), '.')
%     hold on
% end
% 
% 1.8
% 1.2
% 
% for i=1:numel(y)
%    line([-1.6 1.5], [y(i) y(i)]) 
% end
%
% figure
% axis([-2 2 -3 1.5])
% hold on
% 
% 
% plot(loc(1, negIndices), loc(2, negIndices), '.')