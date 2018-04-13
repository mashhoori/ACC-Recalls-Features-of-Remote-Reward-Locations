function Animate(input1, input2, tl, limits, record, trial, trInfo, data)

    writerObj = VideoWriter('out.avi');
    writerObj.FrameRate = 50;
    
    if(isempty(limits))
        mx = max(input1, [], 2);
        mn = min(input1, [], 2);
    else
        mn = limits([1, 3]);
        mx = limits([2, 4]);
    end
    
    mv = [];    
    startIndex = 60;
    
    figure   
    
    hold on
    for i = startIndex:size(input1, 2)
%         if(isempty(data))
            ax = subplot(10, 4, 1:40);     
%         else
%             ax = subplot(10, 4, 1:4:40) ;    
%         end
        hold on    
        plot(input1(1, i), input1(2, i), '.', 'MarkerSize', 50, 'Color', 'b')
%         plot(input1(1, i-59:i), input1(2, i-59:i), '.', 'MarkerSize', 5, 'Color', [15 15 150]/256)
        plot(input2(1, i-59:i), input2(2, i-59:i), '.', 'MarkerSize', 10, 'Color', [150 15 15]/256)
        plot(input2(1, i), input2(2, i), '.', 'MarkerSize', 30, 'Color', 'r')
        axis([mn(1) mx(1) mn(2) mx(2)]) 
        
        if(nargin > 5)
            title([num2str(i), ' - ', num2str(trInfo(trial(i)).choice)' '--', num2str(trial(i)), ' -- ',  num2str(trInfo(trial(i)).gates) ' -- '  num2str(trInfo(trial(i)).heights) '--' num2str(trInfo(trial(i)).feeder_dur)])
            %title(num2str(trial(i)));
        end
        
        
%         if(~isempty(data))
%             ind = 0;
%             for sp = 1:40
% 
%                 if(mod(sp, 4) == 1 || ind >= size(data, 1))
%                     continue
%                 else
%                     ind = ind + 1;
%                 end
% 
%                subplot(10, 4, sp)           
%                plot(data(ind, i-59:i))
%                title(num2str(ind))
%                ylim([-4 4]) 
%             end                     
%         end
                
        if(record)
            mv{i - startIndex + 1} = getframe();
        end
        
        pause(tl)
        cla(ax)
        axis([mn(1) mx(1) mn(2) mx(2)])
    end    
    
    if(record)
        open(writerObj);
        for i=1:numel(mv)
            writeVideo(writerObj, mv{i});
        end    
        close(writerObj);
    end
    
end

