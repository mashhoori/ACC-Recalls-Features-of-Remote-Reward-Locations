
zeroIndices = [9:13 16:20 30:34 37:41];


for i = 1:7

    fileName = ['errorPerRegionFF_', num2str(i)];
    load(fileName)
        
    FreeImgAll = sum(FreeImgAll .* FreeImgCountAll, 3) ./ sum(FreeImgCountAll, 3);
    ForcedImgAll = sum(ForcedImgAll .* ForcedImgCountAll, 3) ./ sum(ForcedImgCountAll, 3);
       
    FreeImgAll(zeroIndices) = 0;
    ForcedImgAll(zeroIndices) = 0;
    
    diffImg = rot90( FreeImgAll - ForcedImgAll, 2 );
    diffImg
    
    figure
    imagesc(diffImg );
    colorbar
end