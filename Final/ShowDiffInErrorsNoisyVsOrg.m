
load('Ratio.mat')
diffAll = [];
for rat = 1:7

    name = ['shuffleError_NN', num2str(rat)];
    load(['E:\Proj\Scripts\Shuffled ACC NN\', name])
    
    for jj = 1:5
%         figure
        diff = A(jj).pred_v - A(jj).pred_n;        
        diff(1, :) = diff(1, :) * xRatio(rat);
        diff(2, :) = diff(2, :) * yRatio(rat);
        diff = sqrt(sum(diff .^ 2))* 100;
        diffAll = [diffAll diff];
%         ratio = mean(diff > 25);        
%         diffHH(jj) = ratio;
%         plot(diff);
    end
%     gg(rat) = mean(diffHH); 
end


% 
% err_all = [];
% err_all_n = [];
% for rat = 1:7
% 
%     name = ['shuffleError_NN', num2str(rat)];
%     load(['E:\Proj\Scripts\Shuffled ACC NN\', name])
% 
%     err = [];
%     err_n = [];
%     
%     for jj = 1:5
%         %figure
%         diff = A(jj).pred_v - A(jj).real_v;        
%         diff(1, :) = diff(1, :) * xRatio(rat);
%         diff(2, :) = diff(2, :) * yRatio(rat);
%         err(end + 1) = sqrt(sum(sum(diff .^ 2)) / numel(A(jj).real_v))* 100;
%         
%         
%         diff = A(jj).pred_n - A(jj).real_v;        
%         diff(1, :) = diff(1, :) * xRatio(rat);
%         diff(2, :) = diff(2, :) * yRatio(rat);
%         err_n(end + 1) = sqrt(sum(sum(diff .^ 2)) / numel(A(jj).real_v))* 100;        
%         
%     end
%     
%     err_all(end + 1) = mean(err);
%     err_all_n(end + 1) = mean(err_n);    
%     
% end



