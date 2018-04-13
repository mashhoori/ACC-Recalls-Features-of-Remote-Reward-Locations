function [timestamps, binData, binLoc, trial] = BinData(data, binWidth, bayes)

timestamps = data.data(data.timeIndex, :);
timestamps = timestamps(1:binWidth:end);

d = data.data(data.dataIndex, :);
d = reshape(d, size(d, 1), binWidth, []);
binData = squeeze(sum(d, 2));

loc = data.data(data.locIndex, :);
loc = reshape(loc, size(loc, 1), binWidth, []);
binLoc = squeeze(mean(loc, 2));

trial = data.data(data.trialIndex, :);
trial = trial(1:binWidth:end);

if(~bayes)
    binData = sqrt(binData);
    binData = zscore(binData, 0, 2);
end

binLoc = zscore(binLoc, 0, 2);

% a = find(trial > 1, 1);
% b = find(trial < numel(data.trInfo), 1, 'last');
% 
% timestamps = timestamps(a:b);
% binData = binData(:, a:b);
% binLoc  = binLoc(:, a:b);
% trial   = trial(a:b);

end