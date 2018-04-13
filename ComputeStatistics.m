function [choicePro rewardPro rampPro freePro] = ComputeStatistics(trialNum, choice, reward, ramp, free)

choicePro = sum(choice(trialNum)) / numel(trialNum);
rewardPro = sum(reward(trialNum)) / numel(trialNum);
rampPro   = sum(ramp(trialNum)) / numel(trialNum);
freePro   = sum(free(trialNum)) / numel(trialNum);

fprintf('Choice: %f \n', choicePro);
fprintf('Reward: %f \n', rewardPro);
fprintf('Ramp: %f \n', rampPro);
fprintf('Free: %f \n', freePro);

end