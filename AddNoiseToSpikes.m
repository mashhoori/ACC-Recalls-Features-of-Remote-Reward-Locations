

function noisyData = AddNoiseToSpikes(inputData, selector, coefficient)

noisyData = inputData;
spikeData = noisyData(:, selector);
spikeDataCopy = zeros(size(spikeData));
HH = [];
for i = 1:size(spikeData, 1)
    spikeTime = find(spikeData(i, :));
    diffSpikeTime = diff(spikeTime);
    stSTD = std(diffSpikeTime(diffSpikeTime < quantile(diffSpikeTime, .75) + 1.5*iqr(diffSpikeTime)));    

%    stSTD = std(diffSpikeTime(diffSpikeTime < quantile(diffSpikeTime, .75) & diffSpikeTime > quantile(diffSpikeTime, .25)));    
%     stSTD = 40;
%     coefficient = 1;

    HH = [HH abs((randn(size(spikeTime))* stSTD * coefficient))];

    newSpikeTime = round(spikeTime + (randn(size(spikeTime))* stSTD * coefficient) .* rand(size(spikeTime) > 0.0));    
    newSpikeTime = max(newSpikeTime, 1);
    newSpikeTime = min(newSpikeTime, size(spikeData, 2) );
    
    spikeDataCopy(i, newSpikeTime) = 1;    
end

noisyData(:, selector) = spikeDataCopy;

end