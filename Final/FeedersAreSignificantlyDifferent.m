
clear
FC = load('FeederClassification_5');

numSession = numel(FC.accuracy_All);

%%

FCS.confMat_Mean = [];
for i = 1:numSession
    FCS.confMat_Mean{i} = mean(reshape(cell2mat(FC.CM_ALL{i}), 3, 3, []), 3);   
end
FCS.confMat_Mean_All = mean(reshape(cell2mat(FCS.confMat_Mean), 3, 3, []), 3);   

FCS.confMat_s_Mean = [];
for i = 1:numSession
    FCS.confMat_s_Mean{i} = mean(reshape(cell2mat(FC.CM_s_ALL{i}), 3, 3, []), 3);   
end
FCS.confMat_s_Mean_All = mean(reshape(cell2mat(FCS.confMat_s_Mean), 3, 3, []), 3);  

FCS.confMat_n_Mean = [];
for i = 1:numSession
    FCS.confMat_n_Mean{i} = mean(reshape(cell2mat(FC.CM_n_ALL{i}), 3, 3, []), 3);   
end
FCS.confMat_n_Mean_All = mean(reshape(cell2mat(FCS.confMat_n_Mean), 3, 3, []), 3);  

%%

FCS.accuracy  = cellfun(@mean, FC.accuracy_All);
FCS.accuracy_s  = cellfun(@mean, FC.accuracy_s_ALL);
FCS.accuracy_n  = cellfun(@mean, FC.accuracy_n_ALL);

%%

FCS.auc = [];
for i = 1:numSession
    FCS.auc{i}  = mean(cell2mat(FC.auc_ALL{i}'));    
end
FCS.auc_all = mean(cell2mat(FCS.auc'));    

FCS.auc_s = [];
for i = 1:numSession
    FCS.auc_s{i}  = mean(cell2mat(FC.auc_s_ALL{i}'));    
end
FCS.auc_s_all = mean(cell2mat(FCS.auc_s'));

FCS.auc_n = [];
for i = 1:numSession
    FCS.auc_n{i}  = mean(cell2mat(FC.auc_n_ALL{i}'));    
end
FCS.auc_n_all = mean(cell2mat(FCS.auc_n'));    

%%

figure
imagesc(FCS.confMat_Mean_All)
caxis([0,1])
set(gca, 'XTickLabel', [])
set(gca, 'YTickLabel', [])
colorbar()

figure
imagesc(FCS.confMat_s_Mean_All)
caxis([0,1])
set(gca, 'XTickLabel', [])
set(gca, 'YTickLabel', [])
colorbar()

figure
imagesc(FCS.confMat_n_Mean_All)
caxis([0,1])
set(gca, 'XTickLabel', [])
set(gca, 'YTickLabel', [])
colorbar()
%%

figure
bar([FCS.accuracy; FCS.accuracy_n; FCS.accuracy_s]')
legend('Original Data', 'Noisy Data', 'Shuffled Data')

%%


