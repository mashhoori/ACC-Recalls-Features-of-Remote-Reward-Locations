
% clear
folderNames = {'P1353_15p', 'P1353_16p', 'P1353_17p', 'P1353_18p', 'P1958_24p', 'P1958_25p', 'P1958_27p'};
outputNames = {'thN15p75_50', 'thN16p75_50', 'thN17p75_50', 'thN18p75_50', 'thN24p75_50', 'thN25p75_50', 'thN27p75_50'};

imp = load('impStructureNew');
impStructure = imp.impStructure;

for rat = 1:numel(folderNames)
    
fprintf('rat %d \n ', rat);
folderPath = ['E:\New folder\' folderNames{rat} '\']; 


data = CreateAllData(folderPath, []);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 5, 1);
[timestamps, binData, binLoc, trial] = BinData(data, 5, 0);

choice = [data.trInfo.choice];
ramp   = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sideOff    = [data.trInfo.SideOff];
centerOff  = [data.trInfo.centralOff];

selector = false(1, length(timestamps));
for tt = 1:numel(sideOff)
    ind = timestamps > sideOff(tt) & timestamps <= (sideOff(tt) + 20*75);
    selector(ind) = true;
end

timestamps = timestamps(selector);
binData    = binData(:, selector);
trial      = trial(selector);
choiceSel     = choice(trial);

load(outputNames{rat});

cntTel = 1;
telData = {};

cntNotTel = 1;
notTelData = {};

for i = 1:10 
    sel = ismember(trial, RD.tr_c{i});
    validData = binData(:, sel);    
    validTrial = trial(sel);
    validChoice = choiceSel(sel);
    locVal = RD.loc_val{i};
    locPre = RD.pred_val{i};

    for j = 1:numel(RD.tr{i})
        ind = find(RD.tr_c{i} == RD.tr{i}(j));
        real = locVal(:, (ind-1)*75+1:75*ind);
        pred = locPre(:, (ind-1)*75+1:75*ind);
        
        midLoc = mod(RD.middleMarker{i}(j), 75);
        err = abs((real(1, :) - pred(1, :)));
        
        startIndex = find(err(1:midLoc) < 0.1, 1, 'last' );
        
        indices = max(startIndex-5, 1): min(length(validData), startIndex+5 );   
              
        if(length(indices) ~= 11)
            continue;
        end
        
        telData{cntTel} = validData(:, ((ind-1)*75*4 + indices(1)*4):((ind-1)*75*4 + indices(end)*4));%xcorr(validData(:, ((ind-1)*75*4 + indices(1)*4):((ind-1)*75*4 + indices(end)*4))', 'coeff');   
        cntTel = cntTel + 1;
    end    
end

cnt = 1;
numCell = size(validData, 1);
createCombinations = zeros(2, length(numCell) ^ 2);
for i = 1:numCell
    for j = 1:numCell
        createCombinations(:, cnt) = [i j]';
        cnt = cnt + 1;
    end
end


telAllData = cat(3, telData{:});    
telAllData = mean(telAllData, 3);
figure
imagesc(telAllData);
colormap hot



% [maxval, maxarg] = max(abs(telAllData));
% 
% selectedIndices =  maxval > 0.1 & maxarg ~= 41;
% telAllDataTmp = telAllData(:, selectedIndices);
% selectedCombination = createCombinations(:, selectedIndices);
% 
% 
% [maxval, maxarg] = max(abs(telAllDataTmp));
% [~, indices] = sort(maxarg);
% selectedCombination = selectedCombination(:, indices);
% 
% 
% figure
% 
% subplot(1, 6, [1:4])
% imagesc((abs(telAllDataTmp(:, indices(:)))'))
% colormap hot 
% 
%     
% chc = impStructure{rat, 1};
% importancechc = chc(selectedCombination(1, :));
% 
% importancechc(importancechc > 40) = 50;
% importancechc(importancechc <= 40) = 0;
% subplot(1, 6, 5)
% imagesc(importancechc')
% colormap hot
% rwr = impStructure{rat, 2};
% importancerwr = rwr(selectedCombination(1, :));
% 
% 
% importancerwr(importancerwr > 40) = 50;
% importancerwr(importancerwr <= 40) = 0;
% subplot(1, 6, 6)
% imagesc(importancerwr')
% colormap hot

end



