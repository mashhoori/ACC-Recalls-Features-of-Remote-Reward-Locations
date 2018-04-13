function [code, codeMap, gridDim, edgeLoc] = GridLocations(location, gridWidth)


xMin = floor(min(location(1, :)));
xMax = ceil(max(location(1, :)));
yMin = floor(min(location(2, :)));
yMax = ceil(max(location(2, :)));

r1 = xMax - xMin;
r2 = yMax - yMin;

xMin = xMin - r1 / 40;
yMin = yMin - r2 / 40;
xMax = xMax + r1 / 40;
yMax = yMax + r2 / 40;


xGrid = xMin:gridWidth(1):xMax;
yGrid = yMin:gridWidth(2):yMax;

code = zeros(1, length(location));

numCodes = (numel(xGrid)-1) * (numel(yGrid)-1);
codeMap = zeros(2, numCodes);

for i=1:numel(xGrid)-1
    for j=1:numel(yGrid)-1
        c = (i-1) * (numel(yGrid)-1) + j;
        
        ind1 = (location(1, :) < xGrid(i+1) & location(1, :) >= xGrid(i));
        ind2 = (location(2, :) < yGrid(j+1) & location(2, :) >= yGrid(j));
        indT = ind1 & ind2;
        
        code(indT) = c;        
       
        codeMap(:, c) =  [  mean([xGrid(i), xGrid(i+1)]); mean([yGrid(j), yGrid(j+1)])];
        
    end
end

gridDim = [numel(xGrid)-1, numel(yGrid)-1];
edgeLoc.x = xGrid;
edgeLoc.y = yGrid;

end