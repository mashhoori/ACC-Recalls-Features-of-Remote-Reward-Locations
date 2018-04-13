
plot([0.6316 .8554 .96 0.2], 1 - [0.48 .3261 .23 .6885], 'o', 'MarkerSize', 8)
axis([0 1 0 1])


coeff = fitlm([0.6316 .8554 .96 0.2], 1 - [0.48 .3261 .23 .6885], 'linear');
h = polyval(flip(coeff.Coefficients.Estimate), [0 1]);


hold on 
plot([0 1], h, 'LineWidth', 2)


xlabel('Probability of choosing RS1 in free choice trials')
ylabel('Probability of being at RS2 when the pattern occured')
