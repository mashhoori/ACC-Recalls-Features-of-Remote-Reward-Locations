
clear

root = 'R:\gruberserver_ulethnet\scratch\Saeedeh\trial_eventsAndVideo\';
folderNames = {'tvP1958_24', 'tvP1958_25', 'tvP1958_26','tvP1958_27', 'tvP1353_15','tvP1353_16','tvP1353_17','tvP1353_18', 'tvR0935_38', 'tvR0935_39', 'tvR0935_43', 'tvR0935_22','tvP1068_26','tvP1068_28','tvP1068_37','tvP1068_41'};

load('R:\gruberserver_ulethnet\scratch\Saeedeh\trial_eventsAndVideo\SessionInfo.mat')

for fn = 1:1%numel(folderNames)
    A = load([root, folderNames{fn}]);    
    
    badTrials = [1 Sessions(fn).BadTrials];
    badCells  =  Sessions(fn).nonExpRltCell;
    
    choice = [A.trial_events.choice];
    reward = reshape([A.trial_events.feeder_dur], 3, []);
    rw = zeros(1, length(reward));
    rw(choice == 0) = reward(1, choice == 0) == 600;
    rw(choice == 1) = reward(2, choice == 1) == 600;    
    reward = rw;
    
    ramp = reshape([A.trial_events.heights], 2, []);
    rp = zeros(1, length(ramp));
    rp(choice == 0) = ramp(1, choice == 0) > 0;
    rp(choice == 1) = ramp(2, choice == 1) > 0;    
    ramp = rp;
        
    dt = zeros([numel(choice)-1, size(A.trial_events(1).FirRatePerBin)]);
    for t = 1:numel(choice)
        dt(t, :, :) = A.trial_events(t).FirRatePerBin;       
    end
    
    dt = sqrt(dt);
    dt = zscore(dt, [], 1);
    
    dt(badTrials, :, :) = [];
    dt(:, badCells, :)  = [];   
    
    choice(badTrials) = [];
    reward(badTrials) = [];
    ramp(badTrials) = [];
   
    numrepeats = 10; 
    
%     featureSet = cell(2, 3, size(dt, 3), numrepeats);
%     accuracy   = zeros(2, 3, size(dt, 3), numrepeats); 
      
     featureSet = cell(3, size(dt, 3), numrepeats);
     accuracy   = zeros(3, size(dt, 3), numrepeats);    
    
    for offset = [0] 
        
        for tr = 1:3
            switch tr
                case 1
%                     target = choice(2-offset:end-offset);
                    target = choice;
                case 2
%                     target = reward(2-offset:end-offset);
                    target = reward;
                case 3
%                     target = ramp(2-offset:end-offset);
                    target = ramp;
            end

            targetPos = find(target == 1);
            targetNeg = find(target == 0);

            minNum = min(numel(targetPos), numel(targetNeg));   
           
            for rg = 1:size(dt, 3)
                
                fprintf('%d %d %d\n', offset, tr, rg);
                
                for hhh = 1:numrepeats
                    selectedPos = randsample(targetPos, minNum);
                    selectedNeg = randsample(targetNeg, minNum);
                    selectedAll = [selectedPos selectedNeg];
                    selectedAll = selectedAll(randperm(numel(selectedAll)));

                    r = rand(size(selectedAll));
                    trainIndices = selectedAll(r > 0.25);
                    testIndices  = selectedAll(r <= 0.25);   

                    tr_data = squeeze(dt(trainIndices, :, rg))';
                    tr_tar  = target(trainIndices);

                    ts_data = squeeze(dt(testIndices, :, rg))';
                    ts_tar  = target(testIndices) ; 

                    [B, FitInfo] = lassoglm(tr_data' ,tr_tar', 'binomial', 'Standardize', false, 'CV', 3, 'DFmax', 20, 'Options', statset('UseParallel', true));%'NumLambda' , 25);
                    
                    ind = FitInfo.IndexMinDeviance;
%                     featureSet{offset + 1, tr, rg, hhh} = find(B(:, ind)); 
                    featureSet{tr, rg, hhh} = find(B(:, ind));      

                    preds = glmval([FitInfo.Intercept(ind); B(:, ind)], ts_data', 'logit') > 0.5;
%                     accuracy(offset + 1,tr, rg, hhh) = sum(preds(:) == ts_tar(:))/ numel(ts_tar(:));  
                    accuracy(tr, rg, hhh) = sum(preds(:) == ts_tar(:))/ numel(ts_tar(:));  
                end
            end
        end
    end
    
    outputFileName = [root, 'ACC4_',folderNames{fn}]; 
    save(outputFileName, 'accuracy', 'featureSet');
    
end