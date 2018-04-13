dur = [];
cnt = 1;

outputNames = {'thN15p75_50', 'thN16p75_50', 'thN17p75_50', 'thN18p75_50', 'thN24p75_50', 'thN25p75_50', 'thN27p75_50'};

for rat = 1:numel(outputNames)

RD = load(outputNames{rat});
RD = RD.RD;
    
for i = 1:10
   
    ind = find(ismember(RD.tr_c{i}, RD.tr{i}));
    for tr = 1:numel(RD.tr{i})
        
        real = RD.loc_val{i}(:, (ind(tr)-1)*75+1:75*ind(tr));
        pred = RD.pred_val{i}(:, (ind(tr)-1)*75+1:75*ind(tr));
        
        err = sqrt((real(1, :) - pred(1, :)) .^ 2);
        midLoc = RD.middleMarker{i}(tr) - (ind(tr)-1)*75;
        
        if(ceil(RD.middleMarker{i}(tr) / 75) ~= ind(tr))
            continue;
        end
        
        startIndex = find(err(1:midLoc) < 0.1, 1, 'last' );
        endIndex =  find(err(midLoc+1:end) < 0.1, 1, 'first') + midLoc ;
        
        if(isempty(startIndex) || isempty(endIndex))
            continue;
        end
        
        dur(cnt) = endIndex - startIndex + 1;
        cnt = cnt + 1;
        %plot(err)
        %hold on
    end
    
end

end