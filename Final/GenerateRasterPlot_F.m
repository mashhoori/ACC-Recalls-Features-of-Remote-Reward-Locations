

folderPath = 'E:\New folder\P1353_16p\'; 
data = CreateAllData(folderPath, []);
d = data.data(data.dataIndex, :);
t = data.data(data.timeIndex, :);


ramp =   [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
choice = [data.trInfo.choice];
free = [data.trInfo.freeChoice];
sfc  = [data.trInfo.SideOff];

load('th17');

%

total = zeros(1, numel(data.trInfo));
numThingi = zeros(1, numel(data.trInfo));
for i = 1:25
    numThingi(tr{i}) = numThingi(tr{i}) + 1;
    total(tr_c{i}) = total(tr_c{i}) + 1;
end

tr_T = find(numThingi ./ (total + eps) >= 0.7 & total >= 5 & choice == 1);
tr_NT = find(numThingi ./ (total + eps) < 0.15 & total >= 10 & choice == 1);

%

tr_all = [tr_T tr_NT];
for c = 1:size(d, 1)
    
figure
mt = zeros(numel(tr_all), 4000);
remove = [];
for i = 1:numel(tr_all)
   ind = t > sfc(tr_all(i)) - 2000 & t <= sfc(tr_all(i)) + 2000;
   
   if(sum(ind) == 4000)
        mt(i, :) = d(c, ind);
   else
       remove = [remove i];
   end
end

mt(remove, :) = [];

plotSpikeRaster(mt == 1, 'PlotType', 'vertline');
title([num2str(c) ' '  num2str(mean(sum(mt(1:numel(tr_T), :), 2))) ' '  num2str(mean(sum(mt(numel(tr_T)+1:end, :), 2))) ])

end