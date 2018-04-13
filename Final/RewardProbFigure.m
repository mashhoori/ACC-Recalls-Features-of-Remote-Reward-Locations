clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));

%%
% folderPath = 'E:\New folder\P1958_25p\';

folderNames = {'P1353_15p', 'P1353_16p', 'P1353_17p', 'P1353_18p', 'P1958_24p', 'P1958_25p', 'P1958_27p'};
outputNames = {'thN15p75_50', 'thN16p75_50', 'thN17p75_50', 'thN18p75_50', 'thN24p75_50', 'thN25p75_50', 'thN27p75_50'};

for rat = 1:numel(folderNames)

fprintf('rat %d \n ', rat);
folderPath = ['E:\New folder\' folderNames{rat} '\'];

data = CreateAllData(folderPath, []);
load(outputNames{rat});
%%
choice = [data.trInfo.choice];
ramp   = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];
sideOff    = [data.trInfo.SideOff];
centerOff  = [data.trInfo.centralOff];

pref(rat) = sum(choice(freeChoice)) / sum(freeChoice);
rewardFreeProp(rat) = sum(ramp(freeChoice)) / sum(freeChoice);

rewardChoiceProp_0(rat) = sum(reward  & (( choice == 0 ) )) / sum(choice == 0 ); %& freeChoice& freeChoice
rewardChoiceProp_1(rat) = sum(reward  & (( choice == 1 ) )) / sum(choice == 1 ); %& freeChoice& freeChoice

rampChoiceProp_0(rat) = sum(ramp .* ( choice == 0 ) ) / sum( choice == 0 ); %& freeChoice& freeChoice
rampChoiceProp_1(rat) = sum(ramp .* ( choice == 1 ) ) / sum( choice == 1 );%& freeChoice& freeChoice

target = reward;

prop = zeros(1, 10);  
prop_c = zeros(1, 10);
for hhh = 1:10
    %prop(hhh) = mean(( (2*~ramp(RD.tr{hhh})) +  reward(RD.tr{hhh})));    
    %prop_c(hhh) = mean(( 2*(~ramp(RD.tr_c{hhh})) +  reward(RD.tr_c{hhh})));     
     % & ~freeChoice(RD.tr{hhh})& ~freeChoice(RD.tr{hhh})& ~freeChoice(RD.tr_c{hhh}) 
    
    prop_r_1(hhh)  = sum(ramp(RD.tr{hhh}) & ~target(RD.tr{hhh}) &  choice(RD.tr{hhh})&~freeChoice(RD.tr{hhh})) / sum(ramp(RD.tr_c{hhh}) & ~target(RD.tr_c{hhh}) & ~freeChoice(RD.tr_c{hhh})&choice(RD.tr{hhh})); %& choice(RD.tr_c{hhh}) & ~freeChoice(RD.tr_c{hhh})
    prop_nr_1(hhh) = sum( (~ramp(RD.tr{hhh}) | target(RD.tr{hhh})) &choice(RD.tr{hhh})& ~freeChoice(RD.tr{hhh}) ) / sum(   (~ramp(RD.tr_c{hhh}) | target(RD.tr_c{hhh})) & ~freeChoice(RD.tr_c{hhh})&choice(RD.tr{hhh}) ); %& choice(RD.tr_c{hhh}) & ~freeChoice(RD.tr_c{hhh})
    
    prop_r_0(hhh)  = sum(ramp(RD.tr{hhh}) & target(RD.tr{hhh})) / sum(ramp(RD.tr_c{hhh}) & target(RD.tr_c{hhh}) ); %& choice(RD.tr_c{hhh}) & ~freeChoice(RD.tr_c{hhh})
    prop_nr_0(hhh) = sum(ramp(RD.tr{hhh}) & ~target(RD.tr{hhh}) ) / sum(ramp(RD.tr_c{hhh}) & ~target(RD.tr_c{hhh}) );%& choice(RD.tr_c{hhh}) & ~freeChoice(RD.tr_c{hhh})
    
%        &  choice(RD.tr{hhh})  & ~freeChoice(RD.tr{hhh}) & choice(RD.tr{hhh})  & ~freeChoice(RD.tr{hhh})
% & choice(RD.tr{hhh})  & ~freeChoice(RD.tr{hhh})


%     prop_r_0(hhh)  = sum(target(RD.tr{hhh}) & ~choice(RD.tr{hhh})  & ~freeChoice(RD.tr{hhh})) / sum(target(RD.tr_c{hhh}) & ~choice(RD.tr_c{hhh}) & ~freeChoice(RD.tr_c{hhh}));
%     prop_nr_0(hhh) = sum(~target(RD.tr{hhh}) & ~choice(RD.tr{hhh}) & ~freeChoice(RD.tr{hhh}) ) / sum(~target(RD.tr_c{hhh}) & ~choice(RD.tr_c{hhh}) & ~freeChoice(RD.tr_c{hhh}));
%     
%     %sum(~target(RD.tr{hhh}) ) / sum(~target(RD.tr_c{hhh}));
%     
%     prob_c_0(hhh) = sum(choice(RD.tr{hhh})==0  & ~freeChoice(RD.tr{hhh}) ) / sum( ~freeChoice(RD.tr_c{hhh}) & choice(RD.tr_c{hhh})== 0); 
     prob_c(hhh) = sum(choice(RD.tr{hhh})  & ~freeChoice(RD.tr{hhh}) ) / sum( ~freeChoice(RD.tr_c{hhh}) & choice(RD.tr_c{hhh})); 
%     
    nnn(hhh) = sum(target(RD.tr{hhh})) / numel(target(RD.tr{hhh}));
end

jhjh(rat) = mean(nnn);

r_1(rat) = mean(prop_r_1(~isnan(prop_r_1)));
nr_1(rat) = mean(prop_nr_1(~isnan(prop_nr_1)));

r_0(rat) = mean( prop_r_0(~isnan(prop_r_0)));
nr_0(rat) = mean(prop_nr_0(~isnan(prop_nr_0)));

tp(rat) = mean(prob_c);
% tp_0(rat) = mean(prob_c_0);

end

figure
plot([1:7], [r; nr], 'o')

figure
plot(c, r_0, 'o').3

figure
plot(c, nr_0, 'o')
figure
plot(pref, nr_1' ./ r_1', 'o')
figure
plot(pref, nr_0' ./ r_0', 'o')

% [val, pval] = corr(c', )
% [val, pval] = corr(c', )

[val, pval] = corr(pref', nr_1' ./ r_1')
[val, pval] = corr(pref', nr_0' ./ r_0')

return
% 
% values = linspace(0, 1, 10);
% for i = 1:numel(values)
%     figure
%     lili = values(i)*rewardChoiceProp_1 + (1 - values(i))* (1 - rampChoiceProp_1/5);
%     cr = corr(pref', lili');
%     plot(pref, lili, 'o' );
%     title([num2str(cr), ' ', num2str(values(i))] );
% end
% 
% figure
% lili = rewardChoiceProp_1 ;
% cr = corr(c', lili');
% plot(c, lili, 'o' );



