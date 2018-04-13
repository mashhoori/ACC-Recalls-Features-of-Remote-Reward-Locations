

folderNames = {'P1353_15p', 'P1353_16p', 'P1353_17p', 'P1353_18p', 'P1958_24p', 'P1958_25p', 'P1958_27p'};
outputNames = {'thN15p75_50', 'thN16p75_50', 'thN17p75_50', 'thN18p75_50', 'thN24p75_50', 'thN25p75_50', 'thN27p75_50'};

ratioForced = [];
ratioFree = [];
ratioAll = [];

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

freeTrialThingy = zeros(1, 10);
forcedTrialThingy = zeros(1, 10);
totalForced = zeros(1, 10);
totalFree = zeros(1, 10);
for i = 1:10    
    freeTrialThingy(i) =  sum(freeChoice(RD.tr{i}));
    forcedTrialThingy(i) =  sum(~freeChoice(RD.tr{i}));
    totalForced(i) = sum(~freeChoice(RD.tr_c{i}));    
    totalFree(i) = sum(freeChoice(RD.tr_c{i}));    
end

ratioForced(rat) = mean(forcedTrialThingy ./ totalForced);
ratioFree(rat)   = mean(freeTrialThingy ./ totalFree);
ratioAll(rat) = mean((forcedTrialThingy + freeTrialThingy) ./ (totalForced + totalFree));


end





