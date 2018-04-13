function PlotNeuralActivity(meanFR, gridDim)
% 
% arr = 1:size(meanFR, 1);%[2 3 4 5 6 8 20 22 24 25 30 42 40 38 39 51];
% % 
% 
% nNeuron = size(meanFR, 1);
% 
% figure
% for ii = 1:16    
%     subplot(4, 4 , ii)
%     avg = meanFR(arr(ii), :);
%     avg1 = reshape(avg, gridDim(2), []);        
%     avg1 = conv2(avg1, ones(5, 5)/25);        
%     avg1 = rot90(avg1, 2);
%     avg1 = avg1(:, end:-1:1);
%     imagesc(avg1)
%     colormap jet    
% end
% 
% 





nNeuron = size(meanFR, 1);

for ii = 0:ceil(nNeuron / 42) - 1
    figure
    for jj=1: min(nNeuron - 42*ii, 42)
        subplot(7, 6, jj)
        avg = meanFR(ii*42+jj, :);
        avg1 = reshape(avg, gridDim(2), []);        
        avg1 = conv2(avg1, ones(3, 3)/9);        
        avg1 = rot90(avg1, 2);
        avg1 = avg1(:, end:-1:1);
        imagesc(avg1)
        set(gca, 'xtick', []);
        set(gca, 'ytick', []);
        colormap jet
    end
end


end