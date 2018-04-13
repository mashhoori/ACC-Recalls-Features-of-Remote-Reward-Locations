
location =  dlmread('C:\Users\a.mashhoori\Desktop\Proj\P1958_25p\vtm1.pvd');
location(:, 1) = round(location(:, 1) /1000);
location(:, 4:5) = [];

locTimeStart = location(1, 1) / 1000;


plot(location(end-2500:end, 2), location(end-2500:end, 3))
axis([0 700 0 450])


vidObj = VideoReader('C:\Users\a.mashhoori\Desktop\Proj\P1958_25p\VT1.mpg');


vidHeight = vidObj.Height;
vidWidth = vidObj.Width;


s = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),...
    'colormap',[]);

k = 1;
vidObj.CurrentTime = locTimeStart - 470;
while (hasFrame(vidObj))    
    
    s.cdata = readFrame(vidObj);
    a = vidObj.CurrentTime;
    
    s.cdata = convn(s.cdata, ones(2, 2) / 4, 'same');
    s.cdata = uint8(s.cdata(1:2:end, 1:2:end, :));
    s.cdata = rot90(s.cdata, 2);
    s.cdata = flip(s.cdata, 2);
    
    subplot(1, 2, 1);
    
    [m, ind] = min(abs(location(:, 1) / 1000 - a - 548.4 ));
    fprintf('%d %f %f\n', ind, location(ind, 1) / 1000, a);
    plot(location(ind, 2), location(ind, 3), '*');    
    axis([0 700 0 450]);
    
    subplot(1, 2, 2);
    image(s.cdata);

    pause(0.0001);
    k = k+1;
    
end
