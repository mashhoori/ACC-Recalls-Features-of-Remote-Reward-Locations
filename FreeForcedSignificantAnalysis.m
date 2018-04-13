

val = zeros(6, 5, 4);

for rat = 1:6

    full = load(['errorPerRegionFF_Full_', num2str(rat)]);
    sel  = load(['errorPerRegionFF_Sel_', num2str(rat)]);
  
    Full_FreeImgAll = sum(full.FreeImgAll .* full.FreeImgCountAll, 3) ./ sum(full.FreeImgCountAll, 3);
    Full_ForcedImgAll = sum(full.ForcedImgAll .* full.ForcedImgCountAll, 3) ./ sum(full.ForcedImgCountAll, 3);
    
    Sel_FreeImgAll = sum(sel.FreeImgAll .* sel.FreeImgCountAll, 3) ./ sum(sel.FreeImgCountAll, 3);
    Sel_ForcedImgAll = sum(sel.ForcedImgAll .* sel.ForcedImgCountAll, 3) ./ sum(sel.ForcedImgCountAll, 3);
   
%     val(rat, :, 1) = full.ForcedImgAll(2, 4, :);
%     val(rat, :, 2) = full.FreeImgAll(2, 4, :);
%     val(rat, :, 3) = sel.ForcedImgAll(2, 4, :);
%     val(rat, :, 4) = sel.FreeImgAll(2, 4, :);
        
%     a = [9 10 11 12 13 16 17 18 19 20 7 30 31 32 33 34 37 38 39 40 41];
%     Full_FreeImgAll(a) = 0;
%     Full_ForcedImgAll(a) = 0;
%     Sel_FreeImgAll(a) = 0;
%     Sel_ForcedImgAll(a) = 0;
%             
%      fprintf('Full_Forced:%2.2f   Full_Free:%2.2f   Sel_Forced:%2.2f   Sel_Free:%2.2f  \n', Full_ForcedImgAll(2, 4), Full_FreeImgAll(2, 4), Sel_ForcedImgAll(2, 4), Sel_FreeImgAll(2, 4));

%     mat1 = Full_FreeImgAll - Full_ForcedImgAll;
%     mat2 = Sel_FreeImgAll  - Sel_ForcedImgAll;
%     mat3 = Full_ForcedImgAll - Sel_ForcedImgAll;
%     mat4 = Full_FreeImgAll - Sel_FreeImgAll;

%     figure    
%     subplot(2,2,1)
%     imagesc(mat1(:, 4))
%     subplot(2,2,2)
%     imagesc(mat2(:, 4))
%     subplot(2,2,3)
%     imagesc(mat3(:, 4))
%     subplot(2,2,4)
%     imagesc(mat4(:, 4))   


    f1(rat) =  Full_FreeImgAll(2, 4);
    f2(rat) =  Full_ForcedImgAll(2, 4);
    f3(rat) =  Sel_FreeImgAll(2, 4);
    f4(rat) =  Sel_ForcedImgAll(2, 4);
    
end



for rat = 1:6
    
[h1, p1, ci1, stats1] = ttest(val(rat, :, 1), val(rat, :, 3));
[h2, p2, ci2, stats2] = ttest(val(rat, :, 3), val(rat, :, 4), 'Tail', 'left');

fprintf('%.2f  %.2f  %.2f  %.2f  %.2f %.2f  %.2f  \n', h1, p1, h2, p2, stats1.tstat, stats2.tstat, mean(val(rat, :, 4)) -mean( val(rat, :, 3)) );

end

