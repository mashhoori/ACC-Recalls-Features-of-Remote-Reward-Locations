
function originalData = ShuffleSpikes(inputData, selector)

originalData = inputData;
spikeData = originalData(:, selector);
spikeDataCopy = zeros(size(spikeData));

for i = 1:size(spikeData, 1)
    spikeTime = find(spikeData(i, :));
    diffSpikeTime = diff(spikeTime);
    diffSpikeTime = diffSpikeTime(randperm(numel(diffSpikeTime)));
    spikeDataCopy(i, cumsum(diffSpikeTime)) = 1;
end

originalData(:, selector) = spikeDataCopy;


end


