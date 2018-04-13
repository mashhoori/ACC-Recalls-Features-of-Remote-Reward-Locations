
function mvOut = CreateMovie(st, ft, FTS, realLoc, predLoc, timestamps, vid, offset)

ct = (st - FTS(1)) / 1000;
% ct = ct - (550/1000);

try
  
index  = 1;
vid.CurrentTime =  ct  ;
v = {};
tm = [];
while (vid.CurrentTime <= ct + (ft - st) / 1000 )
    tm(index) = vid.CurrentTime + (offset/1000);
    v{index} = readFrame(vid);
    index = index + 1;
end
catch me
    display(me)
    
end

for i = 1: (index - 1)
    imshow(v{i})
    hold on
    
    [~, ind] = min( abs(  (tm(i)*1000 + FTS(1) - timestamps)  )  );
     
%      plot(realLoc(1, ind), realLoc(2, ind), 'o')
     plot(predLoc(1, ind), predLoc(2, ind), 'vr', 'MarkerSize', 15)

     mvOut{i} = getframe();     
     pause(0.01)    
     
end




end






