function CreatePerTrialErrorMap()

load('.\err17New')
load('.\Ratio.mat')
figure
imagesc(1:0.1:18, 1:130, 1.5:0.1:18.5)
caxis([0 19])
set(gca,'Ydir','Normal')
hold on

for i = 5:5
   
    error = A(i).pred_v - A(i).real_v;
    error(1, :) = error(1, :) * xRatio(3);
    error(2, :) = error(2, :) * yRatio(3);
    
    error = sqrt(sum(error .^ 2)) * 100;
    
    [code, codeMap] = CoarseGrid(A(i).real_v, 3);
    code = ConvertCode(code);
    
    tbl = table(error(:), code(:), A(i).trial_v(:), 'VariableNames', {'error', 'code', 'trial'} );
    tblg = grpstats(tbl, {'code', 'trial'}, 'mean');
    
    uTrials = unique(tblg.trial);
    
    plot(tbl.code, tbl.error, '.', 'LineWidth', 1, 'Color', [0.3 0.3 0.3]);
    
%     for tr = uTrials'       
%         trialTable = tblg(tblg.trial == tr, :);
%         plot(trialTable.code, trialTable.mean_error, '.', 'LineWidth', 1, 'Color', [0.3 0.3 0.3]);
%         hold on
%     end
        
    tblg_all = grpstats(tbl, {'code'}, 'median');
    plot(tblg_all.code, tblg_all.median_error, 'k-d', 'LineWidth', 2);
   % plot(tbl.code, tbl.error, 'k-d', 'LineWidth', 2);

    ylim([0, 130]);
    xlim([1, 18]);
    set(gca, 'XTick', [1:18]);
    set(gca, 'XTickLabel', []);
    line([7 7] , [115, 130],  'Color',[.2 .2 .4], 'LineStyle','--', 'LineWidth', 3)
    ylabel('Error (cm)')
end


end

function newCode = ConvertCode(code)

 newCode = zeros(size(code)); 

 newCode(code == 25) = 1;
 newCode(code == 32) = 2;
 newCode(code == 39) = 3;
 newCode(code == 46) = 4;
 newCode(code == 45 | code == 47) = 5;
 newCode(code == 44 | code == 48) = 6;
 newCode(code == 43 | code == 49) = 7;
 newCode(code == 36 | code == 42) = 8;
 newCode(code == 29 | code == 35) = 9;
 newCode(code == 22 | code == 28) = 10;
 newCode(code == 15 | code == 21) = 11;
 newCode(code == 8 | code == 14) = 12;
 newCode(code == 1 | code == 7) = 13;
 newCode(code == 2 | code == 6) = 14;
 newCode(code == 3 | code == 5) = 15;
 newCode(code ==  4) = 16;
 newCode(code == 11) = 17;
 newCode(code == 18) = 18;
 

end

