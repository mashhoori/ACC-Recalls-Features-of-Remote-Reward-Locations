

folderNames = {'P1353_15p', 'P1353_16p', 'P1353_17p', 'P1353_18p', 'P1958_24p', 'P1958_25p', 'P1958_27p'};
outputNames = {'thN15p75_50', 'thN16p75_50', 'thN17p75_50', 'thN18p75_50', 'thN24p75_50', 'thN25p75_50', 'thN27p75_50'};

cnt = 1;

countAll = zeros(1, 49);

for rat = 1:numel(folderNames)

fprintf('rat %d \n ', rat);
folderPath = ['E:\New folder\' folderNames{rat} '\']; 
%
data = CreateAllData(folderPath, []);
[timestamps, binData, binLoc, trial] = BinData(data, 20, 0);
binLoc = MapToRect(binLoc, trial, data);
[code, codeMap, edges] = CoarseGrid(binLoc, rat);
choice = [data.trInfo.choice];
%
RD = load(outputNames{rat}); 
RD = RD.RD;

%%
countAllSession = zeros(1, 49);
for i = 1:10
    choiceProfile = choice(RD.tr_c{i});    
    codeRes = GetCodeForLocation(RD.pred_val{i}, edges);   
    codeResMat = reshape(codeRes, 75, []); 
    
    error = sqrt(sum(((RD.pred_val{i} - RD.loc_val{i}) .^ 2), 1)); 
    errormat = reshape(error, 75, []);
    
    [maxVal, maxindex] =  max(errormat, [], 1); 
       
    peakCode = [];
    for j = 1:size(codeResMat, 2)
        peakCode = [peakCode codeResMat(maxindex(j) , j)];
    end
    
    peakCode_zero = peakCode(choiceProfile == 0);
    peakCode_zero(peakCode_zero == 49) = [];
    
    peakCode_one = peakCode(choiceProfile == 1);
    peakCode_one(peakCode_one == 43) = [];
    
    peakCode = [peakCode_zero peakCode_one];
    counts = histcounts(peakCode, 1:50);
    countAllSession = countAllSession + counts;
end

countAll = countAll + (countAllSession / 10);

end

cccccc = countAll;
cccccc( [[9 10 12 13], [9 10 12 13] + 7, [9 10 12 13] + 14, [9 10 12 13] + 21, [9 10 12 13] + 28]) = [];
        
nullexpected = ones(1, 29) * (sum(cccccc) / 29);
    
chi = sum(((cccccc - nullexpected) .^ 2) ./ nullexpected);
df = 28;
chi2cdf(chi, df)   


observed = [];
for i=1:29
    observed  = [observed ones(1, round(cccccc(i))) * i];
end

[h,p,stats] = chi2gof(observed, 'Expected', nullexpected(1:29), 'Ctrs', 1:29);


