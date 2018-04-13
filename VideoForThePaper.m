

vidObj = VideoReader('C:\Users\a.mashhoori\Videos\Any Video Converter\Xbox\Implanted Rat on Elevator Maze_mpeg4.avi');

vidHeight = vidObj.Height;
vidWidth = vidObj.Width;

%s = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'), 'colormap',[]);

k = 1;
while (hasFrame(vidObj))
    
    s{k} = readFrame(vidObj);   
        
    %image(s.cdata);

    pause(0.001);
    k = k+1;    
    
end




figure 
for i = 1:1  
%     subplot(3, 3, i)
    image(s{575 + (i-1)})    
    set(gca, 'XTick', []);
    set(gca, 'YTick', []);
    set(gca, 'XTickLabel', []);
    set(gca, 'YTickLabel', []);
%     axis equal
end




FN  = 65;
for i = FN+400:FN+700         %numel(s)    
    image(s{i})
    title(num2str(i))
    pause(0.04);
end

