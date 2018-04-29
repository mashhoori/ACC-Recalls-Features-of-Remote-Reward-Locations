


clear



meanError = [];
stdError = [];

for s_id = 1:7
    
    fileName = ['Session_', num2str(s_id)];
    load(fileName)


    choice = [DataALL.choice];

    posTrial = find(choice == 1);
    negTrial = find(choice == 0);

    minNum = min([numel(posTrial), numel(negTrial)]);

    errList = [];
    for it = 1:10

        selectedPos = randsample(posTrial, minNum);
        selectedNeg = randsample(negTrial, minNum);

        AllSelected = [selectedPos selectedNeg];

        r = rand(1, numel(AllSelected));
        trainTrials = AllSelected(r <= 0.75);
        testTrials  = AllSelected(r  > 0.75);

        train = [DataALL(trainTrials).dataMatrix];
        train_loc = [DataALL(trainTrials).location];

        test = [DataALL(testTrials).dataMatrix];
        test_loc = [DataALL(testTrials).location];

        %%

        save('data', 'train', 'train_loc', 'test', 'test_loc');
        system('python .\LocNet.py');
        a = load('data_out');
        pred_loc = a.resValid{end}';

        error = test_loc - pred_loc;

        errList(it) = sqrt(  sum(sum(error .^ 2)) / numel(error)  );

    end

    meanError(s_id) = mean(errList);
    stdError(s_id)  = std(errList);
end



