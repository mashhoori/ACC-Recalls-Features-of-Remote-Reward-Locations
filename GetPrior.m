function prior = GetPrior(code, gridDim, landa)    
    
    prior = zeros(1, prod(gridDim));
    for i= 1:prod(gridDim)
        prior(i) = sum(code == i) + landa;
    end
    prior(prior > 0) = prior(prior > 0) + mean(prior(prior > 0));
    prior = prior / sum(prior);     
        
    imgG = reshape(prior, gridDim(2), []);
    imgG = conv2(imgG, ones(2, 2)/ 4, 'same');
    
    prior = imgG(:)';
%     
%     img = reshape(prior, gridDim(2), []);
%     img = rot90(img, 2);
%     img = img(:, end:-1:1); 
%     img = conv2(img, ones(2, 2)/ 4);
%     
%     imagesc(log(img));
%     colormap jet
%     
%     title('log(Prior)')

end