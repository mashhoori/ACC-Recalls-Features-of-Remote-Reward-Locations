
function marker = MarkReplay3(act, pred, trial)


marker = zeros(1, length(act));
trialsU = unique(trial);
for tr = 1:numel(trialsU)   
    
    trialStart = find(trial == trialsU(tr) & act(2, :) > 1, 1, 'first');
    trialEnd = find(trial == trialsU(tr) & act(2, :) > 1, 1, 'last');  

%     trialStart = find(trial == trialsU(tr), 1, 'first');
%     trialEnd = find(trial == trialsU(tr), 1, 'last');    
    
    predTrial = pred(:, trialStart:trialEnd);
    realTrial = act(:, trialStart:trialEnd);
    
    error = predTrial - realTrial;
%     if(max(abs(error(2,:))) < 0.3)
%         
%          [mxd, mxi] =   max(abs(error(1, :)));
%          [mnd1, mni1] =   min(abs(error(1, 1:mxi)));
%          [mnd2, mni2] =   min(abs(error(1, mxi:end)));
%          
%          if(mxi + trialStart - 3 > trialEnd )
%              continue;
%          end
%          try
%          if(mnd1 < 0.1 && mnd2 < 0.1 && mxd > 0.8 && predTrial(2, mxi) > 1.5   && all(error(1, [mxi-3 mxi-2, mxi-1, mxi+1, mxi+2 mxi+3]) < mxd))
%             marker(  max(   mxi + trialStart - 2,  trialStart)  ) = 1 ;
%             marker(  min(   mxi + trialStart + 2,  trialEnd  )  ) = 2 ;
%          end
%          catch
%              disp('lll');
%          end
%    
%     end
    
    [mxd, mxi] =   max(abs(predTrial(1, :) - mean(realTrial(1, :))))  ; 
    if(mxd > 2.3)
        if( max(abs(predTrial(2, :) - mean(realTrial(2, :)))) < 0.3     )
            marker(  max(   mxi + trialStart - 2,  trialStart)  ) = 1 ;
            marker(  min(   mxi + trialStart + 2,  trialEnd  )  ) = 2 ;
        end
    end
end





end
