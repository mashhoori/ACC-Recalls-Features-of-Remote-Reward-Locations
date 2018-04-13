% P1958_24

clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));

%%
folderPath = 'E:\New folder\P1353_17p\'; 
data = CreateAllData(folderPath, []);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 50, 1);

clear folderPath
%%
binWidth = 50;

d = data.data(data.dataIndex, :);
d = reshape(d, size(d, 1), binWidth, []);
binData = squeeze(sum(d, 2));

loc = data.data(data.locIndex, :);
loc = reshape(loc, size(loc, 1), binWidth, []);
binLoc = squeeze(mean(loc, 2));
figure
plot(binLoc(1, :), binLoc(2, :), '.');

trial = data.data(data.trialIndex, :);
trial = trial(1:binWidth:end);

binData = sqrt(binData);
binData = zscore(binData, 0, 2);
binLoc = zscore(binLoc, 0, 2);

a = find(binLoc(1, :) < -0.5, 1);
b = find(binLoc(1, :) > 1, 1, 'last');

binData = binData(:, a:b);
binLoc  = binLoc(:, a:b);
trial   = trial(a:b);

%%

num = floor(length(binData) * 4 / 5);
train = binData(:, 1:num);
loc_t = binLoc(:, 1:num);
valid = binData(:, num + 1:end);
loc_v = binLoc(:, num + 1:end);
trial_v = trial(num + 1:end);

save('data', 'train', 'loc_t', 'valid', 'loc_v');


a = load('data_out');
res = a.res';
res2 = a.res2';

plot(loc_t(1, :), loc_t(2, :), '.')
hold on 
plot(res2(1, :), res2(2, :), 'r.')
axis([-3 3 -3 3])

figure
plot(loc_v(1, :), loc_v(2, :), '.')
hold on 
plot(res(1, :), res(2, :), 'r.')
axis([-3 3 -3 3])
%%

mdlx = fitlm(train', loc_t(1, :) , 'linear');
xp_t = predict(mdlx, train');
xp_v = predict(mdlx, valid');

mdly = fitlm(train', loc_t(2, :) , 'linear');
yp_t = predict(mdly, train');
yp_v = predict(mdly, valid');


plot(loc_t(1, :), loc_t(2, :), '.')
hold on 
plot(xp_t, yp_t, 'r.')
axis([-3 3 -3 3])
figure
plot(loc_v(1, :), loc_v(2, :), '.')
hold on 
plot(xp_v, yp_v, 'r.')
axis([-3 3 -3 3])

%%


mdlx = fitlm(train', loc_t(1, :) , 'quadratic');
xp_t = predict(mdlx, train');
xp_v = predict(mdlx, valid');

mdly = fitlm(train', loc_t(2, :) , 'quadratic');
yp_t = predict(mdly, train');
yp_v = predict(mdly, valid');


plot(loc_t(1, :), loc_t(2, :), '.')
hold on 
plot(xp_t, yp_t, 'r.')
axis([-3 3 -3 3])
figure
plot(loc_v(1, :), loc_v(2, :), '.')
hold on 
plot(xp_v, yp_v, 'r.')
axis([-3 3 -3 3])


