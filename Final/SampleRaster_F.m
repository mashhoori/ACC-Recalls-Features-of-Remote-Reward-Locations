

clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));

%%
folderPath = 'E:\New folder\P1958_25p\';
data = CreateAllData(folderPath, []);

trialOrg = data.data(data.trialIndex, :);
locOrg   = data.data(data.locIndex, :);
d     = data.data(data.dataIndex, :);


%%
[timestamps, binData, binLoc, trial] = BinData(data, 10, 0);
binLoc = MapToRect(binLoc, trial, data);
[code, codeMap] = CoarseGrid(binLoc, 6);

map = ones(7, 7) * -3;
map(4, 4) = 1; 
map(3, 4) = 2;
map(2, 4) = 3;
map(1, 4) = 4;
map(1, 3) = 5;       map(1, 5) = 5;  
map(1, 2) = 6;       map(1, 6) = 6;
map(1, 1) = 7;       map(1, 7) = 7;
map(2:7, 1) = 8:13;  map(2:7, 7) = 8:13; 
map(7, 2:4) = 14:16; map(7, 6:-1:5) = 14:15;
map(6:-1:5, 4) = 17:18;


kk = 5;
largeMap = ones(kk * 7, kk * 7) * -3;

kernel_TB = repmat([0:(kk-1)]', 1, kk) / kk;
kernel_BT = repmat([(kk-1):-1:0]', 1, kk) / kk;
kernel_RL = repmat([0:(kk-1)], kk, 1) / kk;
kernel_LR = repmat([(kk-1):-1:0], kk, 1) / kk;

for i= 1:7
    for j = 1:7        
        if(map(i, j) == -3)
            continue;
        end        
        if(j == 4)
            largeMap( (i - 1)*kk+1:i*kk, (j-1)*kk+1:j*kk  ) = kernel_BT + map(i, j);
        end        
        if(j == 1 || j == 7)
            largeMap( (i - 1)*kk+1:i*kk, (j-1)*kk+1:j*kk  ) = kernel_TB + map(i, j);
        end        
        if( (i == 1 && ismember(j, [5, 6])) ||  (i == 7 && ismember(j, [2, 3])) )
            largeMap( (i - 1)*kk+1:i*kk, (j-1)*kk+1:j*kk  ) = kernel_RL + map(i, j);
        end        
        if( (i == 1 && ismember(j, [2, 3])) ||  (i == 7 && ismember(j, [5, 6])) )
            largeMap( (i - 1)*kk+1:i*kk, (j-1)*kk+1:j*kk  ) = kernel_LR + map(i, j);
        end        
    end
end




figure
imagesc(largeMap)
set(gca, 'xtick', [])
set(gca, 'ytick', [])

%%

T = 75;
figure
subplot(5,1,1)
vel = sqrt(sum(diff(locOrg, 1, 2) .^ 2));
vel = [0 vel];
SelVel = vel(trialOrg == T);
plot(SelVel)
set(gca, 'xtick', [])

subplot(5,1,2:4)
mt = d(:, trialOrg == T);
plotSpikeRaster(mt == 1, 'PlotType', 'vertline');
set(gca, 'xtick', [])

subplot(5,1,5)
trialCode = code(trial == T);

trialCode2 = zeros(size(trialCode));

trialCode2(trialCode == 32)  = 2;
trialCode2(trialCode == 39)  = 3;
trialCode2(trialCode == 46)  = 4;
trialCode2(trialCode == 45)  = 5;
trialCode2(trialCode == 44)  = 6;
trialCode2(trialCode == 43)  = 7;
trialCode2(trialCode == 36)  = 8;
trialCode2(trialCode == 29)  = 9;
trialCode2(trialCode == 22)  = 10;
trialCode2(trialCode == 15)  = 11;
trialCode2(trialCode == 8)  = 12;
trialCode2(trialCode == 1)  = 13;
trialCode2(trialCode == 2)  = 14;
trialCode2(trialCode == 3)  = 15;
trialCode2(trialCode == 4)  = 16;
trialCode2(trialCode == 11)  = 17;

trialCode2(1: find(trialCode2 == 2, 1)) = 1;
trialCode2(find(trialCode2 == 17, 1, 'last'):end) = 18;

finalArr = [];
for i = 1:18    
    tmp = linspace(0, 1, sum(trialCode2 == i)* 10) + i;
    finalArr = [finalArr tmp];
end


imagesc(finalArr)
caxis([-3 18])
set(gca, 'ytick', [])
%%
