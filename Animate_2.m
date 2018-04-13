function Animate_2(input1, input2, tl, limits, record, ripples)

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
    axis([mn(1) mx(1) mn(2) mx(2)])
    hold on
    for i = startIndex:size(input1, 2)        
        plot(input1(1, i), input1(2, i), '.', 'MarkerSize', 50, 'Color', 'b')
        plot(input2(1, i-59:i), input2(2, i-59:i), '.', 'MarkerSize', 10, 'Color', [150 15 15]/256)
        plot(input2(1, i), input2(2, i), '.', 'MarkerSize', 30, 'Color', 'r')     
        
        title(num2str(ripples(i)))
        
        
%         if(nargin > 5)
%             title([num2str(i), ' - ', num2str(trial(i)), ' -- ',  num2str(trInfo(trial(i)).gates) ' -- '  num2str(trInfo(trial(i)).heights) '--' num2str(trInfo(trial(i)).feeder_dur)])
%             %title(num2str(trial(i)));
%         end
                
        if(record)
            mv{i - startIndex + 1} = getframe();
        end
        
        pause(tl)
        cla
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

