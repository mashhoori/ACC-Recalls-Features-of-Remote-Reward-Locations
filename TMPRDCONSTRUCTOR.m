
clear

folderNames = {'P1353_15p', 'P1353_16p', 'P1353_17p', 'P1353_18p', 'P1958_24p', 'P1958_25p', 'P1958_27p'};
outputNames = {'thN15p75_50', 'thN16p75_50', 'thN17p75_50', 'thN18p75_50', 'thN24p75_50', 'thN25p75_50', 'thN27p75_50'};

for rat = 1:1%numel(outputNames)

    folderPath = ['E:\New folder\' folderNames{rat} '\']; 
    data = CreateAllData(folderPath, []);
    [timestamps, binData, binLoc, trial] = BinData(data, 20, 0);
    sideOff = [data.trInfo.SideOff];
    RD = load(outputNames{rat});
%     RD =  RD.RD;

for j = 1:10
    
    trAll = RD.tr_c{j};    
    trAll = repmat(trAll, 75, 1);
    trAll = trAll(:)';
    
    predLoc = reshape(RD.pred_val{j}, 2, 75, numel(RD.tr_c{j}));    
    marker = MarkReplay3(RD.loc_val{j}, RD.pred_val{j}, trAll);        
    
    startIdx = find(marker == 1);
    middleIdx = startIdx + 2;
    
    time_valid = zeros(size(trAll));
    
    for tr = 1:numel(RD.tr_c{j})
        ind = timestamps > sideOff(RD.tr_c{j}(tr)) & timestamps <= (sideOff(RD.tr_c{j}(tr)) + 20*75);
        time_valid((tr - 1)*75+1:tr*75) = timestamps(ind);
    end    
    
    RD.time_valid{j} = time_valid;
    RD.middleMarker{j} = middleIdx;
        
end

yy = cell(1, 300);
for j = 1:10        
    for k = 1:numel(RD.tr{j})
        yy{RD.tr{j}(k)} = [yy{RD.tr{j}(k)} mod(RD.middleMarker{j}(k), 75)];
    end        
end

meanLocation = zeros(1, numel(sideOff));
for j = 1:numel(sideOff)
    meanLocation(j) = sideOff(j) + round(mean(yy{j})) * 20;
end

RD.meanLocation = meanLocation;

save(outputNames{rat}, 'RD');

end
%%





