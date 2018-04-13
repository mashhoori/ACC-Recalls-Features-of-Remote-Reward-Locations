
v = VideoReader('E:\New folder\P1353_15p\VT1.mpg');
for tr = testTrials

figure
hh = find(trial_v == tr);

plot(loc_v(1, hh), loc_v(2, hh), '.' )
hold on
plot(res(1, hh), res(2, hh), 'd' )

title(num2str(tr))

pause(6)
close

end


save('KKKGGG_15_thingipp', 'timestamps_v', 'FTS', 'loc_v', 'res', 'trial_v')
load('KKKGGG_15_pp')
% a = [76  177 70 126  16 61 85];
% offset =  [1300 750 -250 1500 1450 -1500];

a      = [ 91  207 159 155   219  247 225];
offset = [ -50  0   0    0  -100  500  0  0];


a      = [83    230    126  181 ];
offset = [-150  -100   100  -200 ];
for tr = 1:numel(a)
    hh = find( trial_v == a(tr) );
    kk{tr} = CreateMovie(timestamps_v(hh(1)), timestamps_v(hh(end)), FTS, loc_v(:, hh), res(:, hh) , timestamps_v(hh), v, offset(tr));
end


writerObj = VideoWriter('out15_thingi.avi');
writerObj.FrameRate = 25;
    
open(writerObj);
for k = [1:4]
    for j = 1:numel(kk{k})        
%         imshow(kk{k}{j}.cdata(30:425, 70:530, :)) 
         img = kk{k}{j}.cdata(30:425, 70:530, :);
         img = img(end:-1:1, end:-1:1, :);
         %imshow(img)         
         writeVideo(writerObj, img);        
%          pause(0.001)        
    end
end
close(writerObj);

% 1 2 4 
