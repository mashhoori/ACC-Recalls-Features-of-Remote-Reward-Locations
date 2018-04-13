

folderNames = {'P1353_15p', 'P1353_16p', 'P1353_17p', 'P1353_18p', 'P1958_24p', 'P1958_25p', 'P1958_27p'};
outputNames = {'thN15p75_50', 'thN16p75_50', 'thN17p75_50', 'thN18p75_50', 'thN24p75_50', 'thN25p75_50', 'thN27p75_50'};
aa = zeros(7, 3);

cnt = 1;
for rat = 1:numel(folderNames)

fprintf('rat %d \n ', rat);
folderPath = ['E:\New folder\' folderNames{rat} '\']; 

data = CreateAllData(folderPath, []);
%%
choice = [data.trInfo.choice];
ramp   = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sideOff    = [data.trInfo.SideOff];
centerOff  = [data.trInfo.centralOff];

load(outputNames{rat});

BB = zeros(10, 3);
CC = zeros(10, 3);
for i = 1:10
    bb = histcounts(ceil( RD.tr{i}(freeChoice(RD.tr{i})) / ( data.trials(end) /3)), 3);
    cc = histcounts(ceil( RD.tr{i}(~freeChoice(RD.tr{i})) / ( data.trials(end) /3)),3);
    dd = (cc+1) ./ (bb + 1);
    %bb / (sum(~freeChoice(RD.tr{i})) );
    BB(i, :)  = bb;      
    CC(i, :)  = cc;
end


% QQ(isnan(QQ)) = 0;
aa(rat, :) =  mean(BB); %./ (mean(CC) + mean(BB) + 0.001);

end

for i = 1:7
   aa(i, :) = aa(i, :) / sum(aa(i, :));
end





aa(isnan(aa)) = 0;
meanRatio = mean(aa);
stdRatio = std(aa);

[p, h] = ttest(aa(1:7, 1) ,  aa(1:7, 3))




aa = aa * 100 / 70;
bar(meanRatio)
hold on 
errorbar(1:3, meanRatio, stdRatio)
set(gca, 'XTickLabel', {'0%-33.3%','33.3%-66.6%','66.6%-100%'})









