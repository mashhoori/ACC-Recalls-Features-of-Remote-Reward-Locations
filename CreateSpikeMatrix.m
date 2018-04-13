
function [spikesMat, time] = CreateSpikeMatrix(spikes)

scales = 1000;

h = numel(spikes);

mx = cellfun(@(x) max(x.T), spikes);
mn = cellfun(@(x) min(x.T), spikes);

globMin = floor(min(mn));
globMax = ceil(max(mx));

spikesMat = zeros(h, ceil((globMax* scales - globMin* scales) ));

for i=1:h
   ts = spikes{i}.T - globMin;
   ts = floor(ts * scales);
     
   spikesMat(i, ts) = 1;
end

%time = floor(globMin*scales) : floor(globMax * scales);
time = (1:length(spikesMat)) + globMin*scales;

end