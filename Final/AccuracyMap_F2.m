clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));

%%

folderNames = {'P1353_15p', 'P1353_16p', 'P1353_17p', 'P1353_18p', 'P1958_24p', 'P1958_25p', 'P1958_27p'};
img = cell(numel(folderNames), 2, 3);

for rat = 1:numel(folderNames)

    fprintf('rat %d \n ', rat);
    
    
folderPath = ['E:\New folder\' folderNames{rat}  '\']; 
data = CreateAllData(folderPath, []);
% data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 150, 1);

%%
[timestamps, binData, binLoc, trial] = BinData(data, 20, 0);

[code, codeMap] = CoarseGrid(binLoc, rat);
choice = [data.trInfo.choice];
ramp = [data.trInfo.rampTrial];
reward = [data.trInfo.durTrial];
freeChoice = [data.trInfo.freeChoice];

%%

mtAll = cell(1, length(codeMap));
for i = 1:length(codeMap)
    
    if(sum(code == i) < 400)
        continue
    end
    
    mt = [];
    for tr = data.trials
        ind  = find(trial == tr & code == i);
        dt = sum(binData(:, ind), 2);
        mt = [mt dt];        
    end    
    mtAll{i} = mt;    
end


label = {'Choice', 'Reward', 'Ramp'};
offsetLabel = {'Current', 'Previous'};
for offset = [0 1]
    
    fprintf('offset %d \n ',offset);
    
    for trgt = 1:3
        
        fprintf('target %d \n ', trgt);
        
        switch trgt
            case 1
                target = choice(data.trials - offset);
            case 2
                target = reward(data.trials - offset);
            case 3
                target = ramp(data.trials - offset);
        end           
        
        acc = zeros(1, length(codeMap));
        for i = 1:length(codeMap)        
            
           fprintf('%d ', i);

            if(isempty(mtAll{i}))
                continue;
            end

            posTrial = find(target == 1);
            negTrial = find(target == 0);    

            minNum = min(numel(posTrial), numel(negTrial)); 
            
                
            acc_iter = zeros(1, 7);
            for iter = 1:7

            posSample = randsample(posTrial, minNum);
            negSample = randsample(negTrial, minNum);

            selectedAll = [posSample negSample];
            selectedAll = selectedAll(randperm(numel(selectedAll)));

            r = rand(size(selectedAll));
            trainIndices = selectedAll(r > 0.3);
            testIndices  = selectedAll(r <= 0.3);   

            tr_data = mtAll{i}(:, trainIndices);
            tr_tar  = target(trainIndices);

            ts_data = mtAll{i}(:, testIndices);
            ts_tar  = target(testIndices) ; 

%             SVMStruct = fitcsvm(tr_data', tr_tar', 'KernelFunction', 'polynomial', 'PolynomialOrder', 2);
%             preds = predict(SVMStruct, ts_data');            
%             
            [B, FitInfo] = lassoglm(tr_data', tr_tar', 'binomial', 'Alpha', 0.9, 'CV', 4, 'DFmax', 15, 'Options', statset('UseParallel', true));
%             nNonZeroF = sum(B ~= 0);
            ind = FitInfo.IndexMinDeviance; 

            preds = glmval([FitInfo.Intercept(ind); B(:, ind)], ts_data', 'logit') > 0.5;
            acc_iter(iter) = sum(preds(:) == ts_tar(:))/ numel(ts_tar(:));  

            end
            acc(i) = mean(acc_iter);            
        end
        fprintf('\n ');

        acc(7) = mean([acc(6) acc(14)]);
        acc(1) = mean([acc(2) acc(8)]);
        img{rat, offset+1, trgt} = flip(rot90(reshape(acc, 7, [])', 2), 2);
%         figure
%         imagesc(img{rat, offset+1, trgt})
%         title([ folderNames{rat}, '-', label{trgt},'-', offsetLabel{offset+1} ])
%         caxis([0 1])
        
    end
end

% pause(5)


end

% save('.\AccuracyMap\AccuracyMapLasso20', 'img');


mnACC = cell(2, 3);
for j = 1:size(img, 2)
   for k = 1:size(img, 3)
       mnACC{j, k} = zeros(7, 7);
       for i = 1:size(img, 1)
           mnACC{j, k} = mnACC{j, k} + img{i, j, k};
       end

       mnACC{j, k} = mnACC{j, k} / 7;           
   end
end       


for j = 1:size(img, 2)
   for k = 1:size(img, 3)
        figure
        mnACC{j, k}(mnACC{j, k} < 0.5) = 0.5;
        imagesc(mnACC{j, k});
        title([ label{k},'-', offsetLabel{j}])
        caxis([0.5 1])
        colorbar
   end
end

