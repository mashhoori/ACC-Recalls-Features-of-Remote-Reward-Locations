
clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));

%%

folderNames = {'P1353_15p', 'P1353_16p', 'P1353_17p', 'P1353_18p', 'P1958_24p', 'P1958_25p', 'P1958_27p'};
impStructure = cell(numel(folderNames), 2);

for rat = 1:numel(folderNames)

fprintf('rat %d \n ', rat);         
folderPath = ['E:\New folder\' folderNames{rat}  '\']; 
% folderPath = 'E:\New folder\P1958_25p\'; 
data = CreateAllData(folderPath, []);
d = data.data(data.dataIndex, :);

choice = [data.trInfo.choice];
reward = [data.trInfo.durTrial];
ramp = [data.trInfo.rampTrial];

timepoints = data.data(data.timeIndex, :);
feederTime = [data.trInfo.SideOff];

mt = [];
trials = [];
for i = 2:numel(feederTime)
    ind = timepoints >= feederTime(i) & timepoints < feederTime(i) + 1500;
    if(sum(ind) == 1500)
        a = d(:, ind);
        b = sum(a, 2);
        mt = [mt b];
        trials = [trials i]; 
    end    
end

mt = sqrt(mt);
mt = zscore(mt);

offset = 0;
ramp = ramp(trials - offset);
choice = choice(trials - offset);
reward = reward(trials - offset);


for tr = 2:2

switch tr
    case 1
        target = choice;
    case 2
        target = reward;
    case 3
        target = ramp;
end

targetPos = find(target == 1);
targetNeg = find(target == 0);

minNum = min(numel(targetPos), numel(targetNeg));

featureSet = [];
for hhh = 1:50
%     hhh
    
    selectedPos = randsample(targetPos, minNum);
    selectedNeg = randsample(targetNeg, minNum);
    selectedAll = [selectedPos selectedNeg];
    selectedAll = selectedAll(randperm(numel(selectedAll)));
    
    r = rand(size(selectedAll));
    trainIndices = selectedAll(r > 0.3);
    testIndices  = selectedAll(r <= 0.3);   
    
    tr_data = mt(:, trainIndices);
    tr_tar  = target(trainIndices);
    
    ts_data = mt(:, testIndices);
    ts_tar  = target(testIndices) ; 
  
    [B, FitInfo] = lassoglm(tr_data' ,tr_tar', 'binomial', 'Standardize', false, 'CV', 4, 'DFmax', 20, 'Options', statset('UseParallel', true));%'NumLambda' , 25);
    %nNonZeroF = sum(B ~= 0);
    %ind = find(nNonZeroF >= 10 & nNonZeroF <= 20, 1,'first');    
    ind = FitInfo.IndexMinDeviance;
    featureSet{hhh} = find(B(:, ind));      
    
    preds = glmval([FitInfo.Intercept(ind); B(:, ind)], ts_data', 'logit') > 0.5;
    acc(hhh) = sum(preds(:) == ts_tar(:))/ numel(ts_tar(:));    
    
end
% mean(acc)


mean(cellfun(@numel, featureSet)) / size(d, 1)

% 
% importance = zeros(1, size(d, 1));
% for i = 1:50
%     importance( featureSet{i} ) = importance( featureSet{i} ) + 1;
% end
% sum(importance > 0.7 * 50) / numel(importance)
% 
% % [importance, feature] = sort(importance, 'descend');
% % [importance', feature']'
% 
% impStructure{rat, tr} =  importance(:)';

end

end

% 0.1633 0.2245  0.3488  0.2791  0.2174

% 16
% choice =    1     6    26    31    28     4    17     8    38    35
% reward =   17    26    28    29    35     1    14    10     3    20    22
% ramp   =    3    17    20    22    30     2    28     1    24    23    33
% thingi =    4    26     6    38     8     1    19     5

% 25
% choice =    3     5    16    38    10    49    15     1
% reward =    5    35    45    47    24    33    21    55
% ramp   =    13   35    49    47    28    55    50
% thingi =    5     3    27    40     1     6    22


% 27
% choice =    7    49     1    19    46     2     4    61    41    16     3    56    65    72
% reward =    1    49    19    41    62    63    66    54    68    10    56    52    36    39
% ramp   =    1    55    35    62    19    52    16     2    65    27    14    36     8    13

%     indNonZ = featureSet{hhh};    
%     SVMStruct = fitcsvm(tr_data(indNonZ, :)', tr_tar);
%     pred = predict(SVMStruct, ts_data(indNonZ, :)');
%     accuracy(hhh) = sum(pred(:) == ts_tar(:)) / numel(ts_tar);



