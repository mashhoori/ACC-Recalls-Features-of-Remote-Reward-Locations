
clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));

%%
folderPath = 'E:\New folder\P1958_25p\'; 
data = CreateAllData(folderPath, []);
% data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 150, 1);
d = data.data(data.dataIndex, :);
t = data.data(data.timeIndex, :);

reward = [data.trInfo.durTrial];
ramp =   [data.trInfo.rampTrial];
choice = [data.trInfo.choice];
free = [data.trInfo.freeChoice];

sfc = [data.trInfo.SideOff];


%%

posTrial = find(reward == 1);
negTrial = find(reward == 0);

% posTrial = UU.trial(1:30);
% negTrial = UU.trial(end-29:end);


tr_all = [posTrial(:); negTrial(:)];

for c = 1:size(d, 1)
figure
mt = zeros(numel(tr_all), 3000);
for i = 1:numel(tr_all)
   ind = t > (sfc(tr_all(i))) & t <= (sfc(tr_all(i)) + 3000);
   
   if(sum(ind) == 3000)
        mt(i, :) = d(c, ind);
   end    
end

plotSpikeRaster(mt == 1, 'PlotType', 'vertline')
title([num2str(c) ' ' num2str(numel(posTrial)) ' ' num2str(mean(sum(mt(1:numel(posTrial), :), 2))) ' '  num2str(mean(sum(mt(numel(posTrial)+1:end, :), 2))) ])

end