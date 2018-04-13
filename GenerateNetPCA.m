
load('NET_PCA')

colorArr = {[.80, 0.88, .97], [0.94, 0.87, 0.87], [.84 .91 .85] };
colorArr_2 = {[0.31, 0.40, 0.58], [0.42, 0.25, 0.39], [.11 .31 .21] };

signs = ['+', '*', '.'];

figure 
resValid = a.resValid;
for i = 1:numel(resValid)    
    subplot(3,2,i)
    hold on
    [coeff,score,latent] = pca(resValid{i});    
    for fc = 1:3        
        plot(score(feederCode == fc & good, 1), score(feederCode == fc & good, 2), '.', 'Color', colorArr{fc}  )
    end
    for fc = 1:3
        plot(score(feederCode == fc & bad, 1), score(feederCode == fc & bad, 2), signs(fc), 'Color',  colorArr_2{fc} ,'MarkerSize', 8, 'LineWidth', 1)
    end
    
    axis equal
    set(gca, 'XTickLabel', [])
    set(gca, 'YTickLabel', [])
    set(gca, 'XTick', [])
    set(gca, 'YTick', [])
    set(gca, 'Box', 'on')
end
