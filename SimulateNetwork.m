
function output = SimulateNetwork(data, W)

input1 = data' * W.w{1};
input1_b =  bsxfun(@plus, input1, W.w{2});
output1 = max(input1_b, 0);

input2 = output1 * W.w{3};
input2_b =  bsxfun(@plus, input2, W.w{4});
output2 = max(input2_b, 0);


% output2(:, 33) = -50;

input3 = output2 * W.w{5};
input3_b =  bsxfun(@plus, input3, W.w{6});
output3 = tanh(input3_b);
% 

input4 = output3 * W.w{7};
input4_b =  bsxfun(@plus, input4, W.w{8});

output4 = input4_b;
output = {data output1' output2' output3', output4'};% };

end
