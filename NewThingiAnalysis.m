folderPath = 'E:\New folder\P1353_18p\'; 
data = CreateAllData(folderPath, []);

ramp =   [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
choice = [data.trInfo.choice];
free = [data.trInfo.freeChoice];
%%

load('th18');
for i = 1:25
    
    choicePA(i) = sum(choice(tr_c{i})) / numel(tr_c{i});
    rewardPA(i) = sum(reward(tr_c{i})) / numel(tr_c{i});
    rampPA(i)   = sum(ramp (tr_c{i}))  / numel(tr_c{i}); 
    freePA(i)   = sum(free (tr_c{i}))  / numel(tr_c{i}); 
    
    
    choiceP(i) = sum(choice(tr{i})) / numel(tr{i});
    rewardP(i) = sum(reward(tr{i})) / numel(tr{i});
    rampP(i)   = sum(ramp (tr{i}))  / numel(tr{i}); 
    freeP(i)   = sum(free (tr{i}))  / numel(tr{i}); 

end

fprintf('Choice:  %.2f    %.2f  \n', mean(choicePA), mean(choiceP));
fprintf('Reward:  %.2f    %.2f  \n', mean(rewardPA), mean(rewardP));
fprintf('Ramp:  %.2f    %.2f  \n', mean(rampPA), mean(rampP));
fprintf('Free:  %.2f    %.2f  \n', mean(freePA), mean(freeP));












ChoiceOne = find(choice == 1);
ChoiceZero = find(choice == 0);

mmm = [];
nnn = [];
for i = 1:25 
      chOne = tr_c{i}(ismember(tr_c{i}, ChoiceOne));
      chZer = tr_c{i}(ismember(tr_c{i}, ChoiceZero));
    
      mmm(i) = sum(ismember(tr{i}, chOne)) / numel(chOne);
      nnn(i) = sum(ismember(tr{i}, chZer)) / numel(chZer);
end


mean(mmm)
mean(nnn)



18       0.4039     0.2889
17       0.0765     0.2684
16       0.4931     0.2813
15       0.2869     0.3429
24       0.2121     0.3619
25       0.1636     0.4131
27       0.1575     0.4738

a = [0.2889 0.0765 0.2813 0.2869 0.2121 0.1636 0.1575];
b = [0.4039 0.2684 0.4931 0.3429 0.3619 0.4131 0.4738];
bar(mean(a), mean(b))
bar(mean(a), mean(b))
bar([mean(a), mean(b)])
xlim([0 3])





mean(mmm)
mean(nnn)
mean(mmm ./ nnn)






mmm = [];
for i = 1:25   
      mmm(i) = sum(ismember(tr{i}, find(~free))) / numel(tr{i});
      nnn(i) = sum(ismember(tr_c{i}, find(~free))) / numel(tr_c{i});
end

mean(mmm)
mean(nnn)
mean(mmm ./ nnn)




return







total = zeros(1, numel(data.trInfo));
numThingi = zeros(1, numel(data.trInfo));
for i = 1:25
    numThingi(tr{i}) = numThingi(tr{i}) + 1;
    total(tr_c{i}) = total(tr_c{i}) + 1;
end
%%

d = data.data(data.dataIndex, :);
t = data.data(data.timeIndex, :);


kk = numThingi ./ (total + eps);
[~, ind] = sort(kk, 'descend');



tr_T = find(numThingi ./ (total + eps) >= 0.85 & total >= 5);
tr_NT = find(numThingi ./ (total + eps) < 0.15 & total >= 5);

numel(tr_T)
numel(tr_NT)

% 
% tr_T = find(reward == 1);
% tr_NT = find(reward == 0);

fprintf('choice: %f -- reward: %f -- ramp: %f -- free: %f\n', sum(choice(tr_T)) / numel(tr_T), sum(reward(tr_T)) / numel(tr_T), sum(ramp(tr_T)) / numel(tr_T), sum(free(tr_T)) / numel(tr_T));
fprintf('choice: %f %f \n',[sum(choice(tr_T) == 1) / sum(choice == 1)     sum(choice(tr_T) == 0) / sum(choice == 0)])
fprintf('reward: %f %f \n', [sum(reward(tr_T) == 1) / sum(reward == 1)    sum(reward(tr_T) == 0) / sum(reward == 0)])
fprintf('ramp: %f %f \n',[sum(ramp(tr_T) == 1) / sum(ramp == 1)           sum(ramp(tr_T) == 0) / sum(ramp == 0)])
fprintf('free: %f %f \n',[sum(free(tr_T) == 1) / sum(free == 1)           sum(free(tr_T) == 0) / sum(free == 0)])
fprintf('choice: %f -- reward: %f -- ramp: %f \n', sum(choice(data.trials)) / numel(data.trials), sum(reward(data.trials)) / numel(data.trials), sum(ramp(data.trials)) / numel(data.trials));

%%%%
return

tr_all = [tr_T tr_NT];
% tr_all = 1:numel(data.trials);
for c = 1:size(d, 1)
figure
mt = zeros(numel(tr_all), 40000);
remove = [];
for i = 1:numel(tr_all)
   ind = t > sfc(tr_all(i)) - 20000 & t <= sfc(tr_all(i)) + 20000;
   
   if(sum(ind) == 40000)
        mt(i, :) = d(c, ind);
   else
       remove = [remove i];
   end    
end

mt(remove, :) = [];

plotSpikeRaster(mt == 1, 'PlotType', 'vertline')
% title([num2str(c) ' '  num2str(mean(sum(mt(1:numel(tr_T), :), 2))) ' '  num2str(mean(sum(mt(numel(tr_T)+1:end, :), 2))) ])

end