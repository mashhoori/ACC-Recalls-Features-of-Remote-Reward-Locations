function code = GetCodeForLocation(location, edges)

% code = zeros(1, length(location));
% 
% xGrid = edges.x;
% yGrid = edges.y;

% for i=1:numel(xGrid)-1
%     for j=1:numel(yGrid)-1
%         c = (i-1) * (numel(yGrid)-1) + j;
%         
%         ind1 = (location(1, :) < xGrid(i+1) & location(1, :) >= xGrid(i));
%         ind2 = (location(2, :) < yGrid(j+1) & location(2, :) >= yGrid(j));
%         indT = ind1 & ind2;
%         
%         code(indT) = c;           
%     end
% end


code = zeros(1, length(location));

xGrid = edges.x;
yGrid = edges.y;

for i=1:numel(yGrid)-1
    for j=1:numel(xGrid)-1
        c = (i-1) * (numel(xGrid)-1) + j;
        
        ind1 = (location(1, :) < xGrid(j+1) & location(1, :) >= xGrid(j));
        ind2 = (location(2, :) < yGrid(i+1) & location(2, :) >= yGrid(i));
        indT = ind1 & ind2;
        
        code(indT) = c;           
    end
end



 
% for i=1:numel(edges.x)-1
%     for j=1:numel(edges.y)-1
%         c = (i-1) * (gridDim(1)-1) + j;
%         
%         ind1 = (location(2, :) < codemap(2, c+1) & location(2, :) >= codemap(2, c));
%         ind2 = (location(1, :) < codemap(1, c + gridDim(2)) & location(1, :) >= codemap(1, c));
%         indT = ind1 & ind2;
%         
%         if(sum(indT) > 0)
%             sum(indT)
%         else
%             sum(indT)
%         end
%         
%         code(indT) = c;
%     end
% end
% 
% 
% for i=1:numel(edges.x)-1
%     for j=1:numel(edges.y)-1
%         c = (i-1) * (gridDim(1)-1) + j;
%         
%         ind1 = (location(2, :) < codemap(2, c+1) & location(2, :) >= codemap(2, c));
%         ind2 = (location(1, :) < codemap(1, c + gridDim(2)) & location(1, :) >= codemap(1, c));
%         indT = ind1 & ind2;
%         
%         if(sum(indT) > 0)
%             sum(indT)
%         else
%             sum(indT)
%         end
%         
%         code(indT) = c;
%     end
% end
% 




end