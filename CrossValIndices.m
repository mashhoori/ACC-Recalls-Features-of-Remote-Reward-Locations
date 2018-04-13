function result = CrossValIndices(numInstance, k)

indices = randperm(numInstance);
foldSize = floor(numInstance / k);

result = [];

for i = 1:k
   testRange = (i-1)* foldSize+1: i*foldSize;
   trainRange = setdiff(1:numInstance, testRange);
   
   result(i).testIndices =  indices(testRange);
   result(i).trainIndices = indices(trainRange);   
end



end