v = VideoReader('E:\New folder\P1958_24p\VT1.mpg');

folderPath = 'E:\New folder\P1958_27p\'; 
[data, FTS] = CreateAllData(folderPath, []);

[timestamps, binData, binLoc, trial] = BinData(data, 1, 0);
%%
ct = (timestamps(1) - FTS(1)) / 1000;
% 
COff = [data.trInfo.centralOff];
plot(binLoc(1, :), binLoc(2, :), 'color', [0.8 0.8 0.8])
hold on
for i = 2:60
   ind =  find(timestamps >= COff(i) & timestamps <= COff(i) + 100);
   plot(binLoc(1, ind), binLoc(2, ind), '.')   
end


try
    
index  = 1;
v.CurrentTime =  ct;
while (v.CurrentTime <= (ct + 1*60) )
    tm(index) = v.CurrentTime;
    video{index} = readFrame(v);
    index = index + 1;
end
catch me
    display(me)    
end


for i = 1:5000
    imshow(video{i})
    hold on
    
    [~, ind] = min( abs(  (tm(i)*1000 + FTS(1) - timestamps)  )  );
     
     plot(binLoc(1, ind), binLoc(2, ind), 'o')
     pause(0.001)
end


