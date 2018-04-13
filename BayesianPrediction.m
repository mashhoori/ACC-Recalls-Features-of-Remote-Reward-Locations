function [prediction, probs]= BayesianPrediction(data, meanFR, prior)
    
    logPrior = zeros(1, size(meanFR, 2));
    if(~isempty(prior))
        logPrior = log(prior);
    end
    
    numPoints  = length(data);
    prediction = zeros(1, numPoints);
    logLanda   = log(meanFR+eps);
    
    probs = zeros(numPoints, size(meanFR, 2));
    
    for i = 1: numPoints
       fr = data(:, i);
       x = repmat(fr, 1, size(meanFR, 2));
       y = x .* logLanda - meanFR;
       
       if(size(y, 1) > 1)
            y = sum(y);
       end
        
       y = y + logPrior;       
       max_y = max(y);       
       probs(i, :) = y;
              
       candidates = find(y == max_y);  
       if(numel(candidates) > 1)
           prediction(i) = randsample(candidates, 1);
       else
           prediction(i) = candidates;
       end       
       
    end
    
end
