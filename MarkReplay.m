
function marker = MarkReplay(act, pred, rewardSiteBox)


rs1_x1 = rewardSiteBox(1, 1);
rs1_x2 = rewardSiteBox(1, 2);
rs1_y1 = rewardSiteBox(1, 3);
rs1_y2 = rewardSiteBox(1, 4);


rs2_x1 = rewardSiteBox(2, 1);
rs2_x2 = rewardSiteBox(2, 2);
rs2_y1 = rewardSiteBox(2, 3);
rs2_y2 = rewardSiteBox(2, 4);


rs1_ind = (act(1, :) > rs1_x1) & (act(1, :) < rs1_x2) & (act(2, :) > rs1_y1) & (act(2, :) < rs1_y2);
rs2_ind = (act(1, :) > rs2_x1) & (act(1, :) < rs2_x2) & (act(2, :) > rs2_y1) & (act(2, :) < rs2_y2);
prTop_ind = (pred(2, :) > rs1_y1) & (pred(2, :) < rs1_y2);
%(pred(1, :) > rs1_x2) & (pred(1, :) < rs2_x1) & (pred(2, :) > rs1_y1) & (pred(2, :) < rs1_y2);
repCandidate = (rs1_ind & prTop_ind) | (rs2_ind & prTop_ind);


% plot(repCandidate)
% plot(pred(1, repCandidate), pred(2, repCandidate), '--.')
% Animate(act(:, repCandidate ), pred(:, repCandidate ), 0.01, [-2.5 2.5 -2.5 2.5], 0)


marker = zeros(size(repCandidate));
ind = 1;
while(ind < numel(marker))   
   
    if(repCandidate(ind)) 
        tmp = ind;
        count_1 = 0;        
        
        sign = 1;
        if(rs2_ind(ind))
            sign = -1;
        end
        
        error = 0;
        while(repCandidate(tmp) && error <= 3 && tmp < numel(marker))            
            count_1 = count_1 + 1;
            tmp = tmp + 1;            
            
            if(sign * (pred(1, tmp) -  pred(1, tmp-1)) < 0 )
                error = error + 1;
            else
                error = 0;
            end            
        end       
        lastInd = tmp - error;
        d1 = abs(pred(:, lastInd) - pred(:, ind));        
        
        count_2 = error;
        error = 0;        
        while(repCandidate(tmp) &&  error <= 3 && tmp < numel(marker))
            count_2 = count_2 + 1;
            tmp = tmp + 1;
            
            if(-sign * (pred(1, tmp) -  pred(1, tmp-1)) < 0)
               error = error + 1; 
            else
                error = 0;
            end            
        end        
        d2 = abs(pred(:, tmp) - pred(:, lastInd ));
        
        if(count_1 > 2 && count_2 > 2 && d1(2) <  0.2 && d1(2) <  0.2 && d1(1) > 0.5 && d2(1) >  0.5)
           marker(ind) = 1;
           marker(tmp) = 2;
        end
        ind = tmp;
    end
    
    ind = ind + 1;
    ind
end
% % 
% 
% startIdx = find(marker == 1);
% endIdx   = find(marker == 2);
% for i = 1:numel(startIdx)
%     plot(pred(1, startIdx(i):endIdx(i)), pred(2, startIdx(i):endIdx(i)), '.')
%     axis([-3 3 -3 3])
%     pause(1)
%     close
% end
% % 
% 
% arr =  [2 3 6:10 11 12 14:23 25 27 29 30 31];
% 
% figure;
% for j = 1:numel(arr)
%     subplot(4, 6, j);
%     i = arr(j);
%     plot(pred(1, startIdx(i):endIdx(i)), pred(2, startIdx(i):endIdx(i)), 'LineWidth', 1)
%     axis([-3 3 -3 3])    
% end
% 



end
