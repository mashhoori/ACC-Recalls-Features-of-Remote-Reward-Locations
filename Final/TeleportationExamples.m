


load('thExamples');

figure
plot(binLoc(1, :), binLoc(2, :), '.', 'Color', [0.8 0.8 0.8])
hold on
ind = 9;
plot(binLoc(1, 2100:2100), binLoc(2, 2100:2100), '.', 'Color', [0 0 0], 'MarkerSize', 40)
plot(res(1, startIdx(ind):endIdx(ind)), res(2, startIdx(ind):endIdx(ind)), '.', 'Color', [0.87 0.49 0], 'MarkerSize', 10)

axis([-2 2 -2 2.7])
set(gca,'xtick',[])
set(gca,'ytick',[])
legend('Maze shape', 'Actual location of the rat', 'Predicted trajecctory')