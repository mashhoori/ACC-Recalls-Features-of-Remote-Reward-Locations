load('OneLapPrediction.mat');



plot(binLoc(1, :), binLoc(2, :), '.', 'Color', [8 8 8] / 10)
hold on

a = loc_v(:, trial_v == 70);
b = res(:, trial_v == 70);


plot(a(1, 1:3:end), a(2, 1:3:end), '.', 'Color', [0 0 0] / 10, 'MarkerSize', 15)
plot(b(1, 1:3:end), b(2, 1:3:end), '.', 'Color', [0.87 0.49 0], 'MarkerSize', 11, 'MarkerEdgeColor', [0.87 0.49 0], 'MarkerFaceColor', [0.87 0.49 0]);
axis([-2 2 -2 2.7])
set(gca,'xtick',[])
set(gca,'ytick',[])

legend('Maze Shape', 'Actual Trajectory', 'Reconstructed Trajectory')

