function output = GetMeanFiringRateByCell(frates, codes, numCodes)

uniqueCodes = unique(codes);
numCells = size(frates, 1);
output = zeros(numCells, numCodes);

% grandMean = mean(frates, 2);
% output = repmat(grandMean, 1, numCodes);
% numCodes%codes == i

 for i= 1:numel(uniqueCodes)
     avg = mean(frates(:, codes == uniqueCodes(i)), 2);
%     if(any(isnan(avg)))
%        avg =  mean(frates, 2);
%     end
     output(:, uniqueCodes(i)) = avg;%
 end

% for jj=1:numCells
%     avg = zeros(1, numCodes);
%     for i=1:numel(uniqueCodes)        
%         avg(uniqueCodes(i)) = mean(frates(jj, codes == uniqueCodes(i)));        
%     end      
%     
%     output(jj, :) = avg;
% end

end