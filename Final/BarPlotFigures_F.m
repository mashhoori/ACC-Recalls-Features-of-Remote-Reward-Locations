folderPath = 'E:\New folder\P1958_25p\'; 
data = CreateAllData(folderPath, []);

ramp =   [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
choice = [data.trInfo.choice];
free = [data.trInfo.freeChoice];

load('th25');

%%
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

%%

ChoiceOne = find(choice == 1 & free == 0);
ChoiceZero = find(choice == 0 & free == 0);

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

18       0.4001     0.3133
17       0.1171     0.2743
16       0.4755     0.2767
15       0.2837     0.3549
24       0.2358     0.3256
25       0.1160     0.3564
27       0.1873     0.4706

a = [0.3133 0.1171 0.2767 0.2837 0.2358 0.1160 0.1873];
b = [0.4001 0.2743 0.4755 0.3549 0.3256 0.3564 0.4706];

bar([mean(a), mean(b)])
xlim([0 3])


%%

freeT = find(free == 1);
forcedT = find(free == 0);

mmm = [];
nnn = [];
for i = 1:25   
    
    fr = tr_c{i}(ismember(tr_c{i}, freeT));
    fc = tr_c{i}(ismember(tr_c{i}, forcedT));
    
    
    mmm(i) = sum(ismember(tr{i}, fr)) / numel(fr);
    nnn(i) = sum(ismember(tr{i}, fc)) / numel(fc);
end


mean(mmm)
mean(nnn)


%     free     forced
18    0.3072   0.3645
17    0.1263   0.2010 
16    0.3635   0.3996
15    0.3067   0.3208
24    0.2968   0.2810
25    0.3290   0.2680
27    0.1502   0.3826

a = [0.3072    0.1263    0.3635    0.3067    0.2968    0.3290    0.1502];
b = [0.3645    0.2010    0.3996    0.3208    0.2810    0.2680    0.3826];


bar([mean(a), mean(b)])
xlim([0 3])

