
[data, ~] = CreateAllData('E:\New folder\P1353_15p\', [], 'vtm1.pvd');


loc = data.data(data.locIndex, :);
vel =  diff(loc, 1, 2);
vel = sqrt(sum(vel .^ 2));
vel = [0 conv(vel, ones(1, 100) / 100, 'same')];


plot(vel(1:500000))


trials = data.data(data.trialIndex, :);
uniqueTrials = unique(trials);


amme = [];
for tr  =  uniqueTrials
    
    velTr = vel(trials == tr);     
    amme = [amme sum(velTr > 0.09)];
    
end

plot(loc(1, vel > 0.1), loc(2, vel > 0.1), '.')