
clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));
%%
folderPath = 'E:\New folder\P1958_25p\'; 
data = CreateAllDataSleep(folderPath, []);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 150, 1);

choice = [data.trInfo.choice];
ramp   = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sfc = [data.trInfo.SideOff];
%%
[timestamps, binData, binLoc, trial] = BinData(data, 20, 0);
binLoc = MapToRect(binLoc, trial, data);
[code, codeMap] = CoarseGrid(binLoc, 6);

[coeff,score,latent,tsquared] = pca([binData]');


%%

NewCode = [];

for T = data.trials

    if(~any(trial == T))
        continue;
    end
    
trialCode = code(trial == T);

trialCode2 = zeros(size(trialCode));

trialCode2(trialCode == 32)  = 2;
trialCode2(trialCode == 39)  = 3;
trialCode2(trialCode == 46)  = 4;
trialCode2(trialCode == 45)  = 5; trialCode2(trialCode == 47)  = 5;
trialCode2(trialCode == 44)  = 6; trialCode2(trialCode == 48)  = 6;
trialCode2(trialCode == 43)  = 7; trialCode2(trialCode == 49)  = 7;
trialCode2(trialCode == 36)  = 8; trialCode2(trialCode == 42)  = 8;
trialCode2(trialCode == 29)  = 9; trialCode2(trialCode == 35)  = 9;
trialCode2(trialCode == 22)  = 10; trialCode2(trialCode == 28)  = 10;
trialCode2(trialCode == 15)  = 11; trialCode2(trialCode == 21)  = 11;
trialCode2(trialCode == 8)  = 12; trialCode2(trialCode == 14)  = 12;
trialCode2(trialCode == 1)  = 13; trialCode2(trialCode == 7)  = 13;
trialCode2(trialCode == 2)  = 14; trialCode2(trialCode == 6)  = 14;
trialCode2(trialCode == 3)  = 15; trialCode2(trialCode == 5)  = 15;
trialCode2(trialCode == 4)  = 16;
trialCode2(trialCode == 11)  = 17;

trialCode2(1: find(trialCode2 == 2, 1)) = 1;
trialCode2(find(trialCode2 == 17, 1, 'last'):end) = 18;

finalArr = [];
for i = 1:18    
    tmp = linspace(0, 1, sum(trialCode2 == i)) + i;
    finalArr = [finalArr tmp];
end

finalArr = zeros(size(trialCode2));
for i = 1:18    
    tmp = linspace(0, 1, sum(trialCode2 == i)) + i;
    finalArr(trialCode2 == i) = tmp;
end

NewCode = [NewCode finalArr];

end




%%
score(NewCode == 0, :) = [];
trial(NewCode == 0) = [];
NewCode(NewCode == 0) = [];

for T = data.trials

x = score(trial == T, 1)';
y = score(trial == T, 2)';
z = zeros(size(x));
col = NewCode(trial == T);  % This is the color, vary with x in this case.

surface([x;x],[y;y],[col;col], 'edgecol','interp')
caxis([-3 18])
hold on

end

