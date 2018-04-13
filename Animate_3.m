function Animate_3(input1, input2, tl, gridDim)
      
    startIndex = 60;    
    figure
    colormap jet
    hold on
    for i = startIndex:size(input2, 1)   
        
        subplot(2, 1, 1)
        img = exp(reshape(input2(i, :), gridDim(2), []));
        img = conv2(img, ones(2, 2)/ 4, 'same');
        imagesc(img);
        
        
        subplot(2, 1, 2)
        img2 = zeros(size(img));
        img2(input1(i)) = 1;
        imagesc(img2)
        
        
        pause(tl)
%         cla
    end    
      
    
end

