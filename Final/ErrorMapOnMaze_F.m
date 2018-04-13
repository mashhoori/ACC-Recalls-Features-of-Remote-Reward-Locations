
load('Ratio.mat')

numList = [15:18 24 25 27];

tmp = cell(numel(numList), 10);
tri = cell(numel(numList), 10);
cd  = cell(numel(numList), 10);

for i = 1:numel(numList)      
    fname = ['err', num2str(numList(i)), 'New'];
    A = load(fname);         
    for j = 1:10    
        pred =  A.A(j).pred_v;
        targ = A.A(j).real_v; 
        error = (pred - targ);
        
        error(1, :) = error(1, :) * xRatio(i);
        error(2, :) = error(2, :) * yRatio(i);
        
        error = sum(error .^ 2);               
        tmp{i, j} = error;
%         [code_v, codeMap] = CoarseGrid(targ, i);        
        tri{i, j} = A.A(j).trial_v;   % 
        cd{i, j} = A.A(j).code_v;   % 
    end        
end

gridDim = [42, 52];

mse = cell(1, numel(numList));
for i = 1:numel(numList)
    
    mse{i} = zeros(1, prod(gridDim));
    count = zeros(1, prod(gridDim));
    
     for j = 1:10          
         tbl = table(tri{i, j}', tmp{i, j}', cd{i, j}', 'VariableNames', {'tr', 'er', 'cd'});
         tbl2 = grpstats(tbl, {'tr', 'cd'}, 'max');
         tbl3 = grpstats(tbl2, {'cd'}, 'sum');    
         mse{i}(tbl3.cd) = mse{i}(tbl3.cd) + tbl3.sum_max_er';
         count(tbl3.cd) = count(tbl3.cd) + tbl3.GroupCount';
     end
     
    mse{i} = mse{i} ./ count;        
    mse{i}(isnan(mse{i})) = 0;
    
    badLoc = find(count < 10);
    mse{i}(badLoc) = 0;    
    
    avg1 = reshape(sqrt(mse{i}), gridDim(2), []);        
    avg1 = rot90(avg1, 2);
    avg1 = avg1(:, end:-1:1);
    avg1 = conv2(avg1, ones(3, 3)/9, 'same');    

%     figure
%     imagesc(avg1)
%     colormap jet
%     axis equal
%     axis tight
%     set(gca, 'xtick', []);
%     set(gca, 'ytick', []);
end



mse = zeros(1, prod(gridDim));
count = zeros(1, prod(gridDim));

for i = 1:numel(numList)    
    
     for j = 1:10          
         tbl = table(tri{i, j}', tmp{i, j}', cd{i, j}', 'VariableNames', {'tr', 'er', 'cd'});
         tbl2 = grpstats(tbl, {'tr', 'cd'}, 'max');
         tbl3 = grpstats(tbl2, {'cd'}, 'sum');    
         mse(tbl3.cd) = mse(tbl3.cd) + tbl3.sum_max_er';
         count(tbl3.cd) = count(tbl3.cd) + tbl3.GroupCount';
     end
         
end

mse = mse ./ count;        
mse(isnan(mse)) = 0;

badLoc = find(count < 25);
mse(badLoc) = 0;    

% load('mseAll')

avg1 = reshape(sqrt(mse) * 100, gridDim(2), []);        
avg1 = rot90(avg1, 2);
avg1 = avg1(:, end:-1:1);
avg1 = conv2(avg1, ones(3, 3)/9, 'same');    

figure
imagesc(avg1)
colormap jet
axis equal
axis tight

set(gca, 'xtick', []);
set(gca, 'ytick', []);
caxis([0 38.11])



return




for i = 1:numel(numList)     
    mse = zeros(1, prod(gridDim));
    count = zeros(1, prod(gridDim)); 
    for k = 1:10
        for j = 1:prod(gridDim)
            
            arr = tmp{i, k}(tri{i, k} == j);
            if( isempty(arr) )
                b = 0;
            else
                b = max(arr);
            end
            
            mse(j) = mse(j) + b;
%             count(j) = count(j) + sum(tri{i, k} == j);
        end  
    end
    
% badLoc = find(count < 50);
% mse(badLoc) = 0;
% % 
% mse = mse ./ count;        
mse(isnan(mse)) = 0;
        
avg1 = reshape(mse, gridDim(2), []);        
avg1 = rot90(avg1, 2);
% avg1 = avg1(:, end:-1:1);

    
% imagesc(avg1)    
    
% 
% mseVec = reshape(mse(:), 4, []);    
% mseVec2 = mean(mseVec);
%    
% avg1 = reshape(count, gridDim(2), []);        
% avg1 = conv2(avg1, ones(3, 3)/9, 'same');        
% avg1 = rot90(avg1, 2);
% avg1 = avg1(:, end:-1:1);

figure
imagesc(avg1)
colormap jet
axis equal
axis tight

end



