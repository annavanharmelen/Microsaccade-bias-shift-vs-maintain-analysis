%% Create gaze heatmaps (for fixational control)

%% start clean
clear; clc; close all;

x_data = []; y_data = []; L_x_data = []; R_x_data = []; L_y_data = []; R_y_data = []; 

%% parameters
pp2do = [1:2,5:9,11,13:24,26:29];

nan_trial_overlap = 0;
nan_post_target = 1;

baselineCorrect     = 1; 

plotResults         = 0;

s = 0;
for pp = pp2do
    s = s + 1;

    %% load epoched data of this participant
    if nan_trial_overlap == 1
        toadd1 = '_NaNtrialoverlap';
    else
        toadd1 = '';
    end
    
    if nan_post_target == 1
        toadd2 = '_NaNposttarget';
    else
        toadd2 = '';
    end
    
    param = getSubjParam(pp);
    load([param.path, '\epoched_data\eyedata_AnnaMicro2', toadd1, toadd2, '__', param.subjName], 'eyedata');

    %% only keep channels of interest
    cfg = [];
    cfg.channel = {'eyeX','eyeY'}; % only keep x & y axis
    eyedata = ft_selectdata(cfg, eyedata); % select x & y channels
    
    %% reformat such that all data in single matrix of trial x channel x time
    cfg = [];
    cfg.keeptrials = 'yes';
    tl = ft_timelockanalysis(cfg, eyedata); % realign the data: from trial*time cells into trial*channel*time?
    tl.time = tl.time * 1000;

    %% pixel to degree
    [dva_x, dva_y] = frevede_pixel2dva(squeeze(tl.trial(:,1,:)), squeeze(tl.trial(:,2,:)));
    tl.trial(:,1,:) = dva_x;
    tl.trial(:,2,:) = dva_y;

    %% baseline correct?
    if baselineCorrect
        tsel = tl.time >= -250 & tl.time <= 0; 
        bl = mean(tl.trial(:,:,tsel),3, "omitnan");
        badBaseline = any(isnan(bl), 2);
        tl.trial = tl.trial - bl;
        tl.trial(badBaseline, :, :) = [];
        tl.trialinfo(badBaseline, :) = [];
    end

    %% save data for heatplots

    cueL = ismember(tl.trialinfo(:,1), [22,24,25,27]);
    cueR = ismember(tl.trialinfo(:,1), [21,23,26,28]);

    % collate all data into matrix
    x_data = [x_data; tl.trial(:,1,:)];
    y_data = [y_data; tl.trial(:,2,:)];

    L_x_data = [L_x_data; tl.trial(cueL,1,:)];
    L_y_data = [L_y_data; tl.trial(cueL,2,:)];

    R_x_data = [R_x_data; tl.trial(cueR,1,:)];
    R_y_data = [R_y_data; tl.trial(cueR,2,:)];


end

%% Make supplementary gaze heatplot figure
bins = [-6:0.05:6];
window = 0.1;
shift = 701:1100;
maintain = 1101:1901;
edges = [bins - (window/2), bins(end) + (window/2)];

whole_L = histcounts2(L_x_data, L_y_data, edges, edges, 'Normalization', 'probability');
whole_R = histcounts2(R_x_data, R_y_data, edges, edges, 'Normalization', 'probability');
whole_diff = whole_L - whole_R;

shift_L = histcounts2(L_x_data(:,:,shift), L_y_data(:,:,shift), edges, edges, 'Normalization', 'probability');
shift_R = histcounts2(R_x_data(:,:,shift), R_y_data(:,:,shift), edges, edges, 'Normalization', 'probability');
shift_diff = shift_L - shift_R;

maintain_L = histcounts2(L_x_data(:,:,maintain), L_y_data(:,:,maintain), edges, edges, 'Normalization', 'probability');
maintain_R = histcounts2(R_x_data(:,:,maintain), R_y_data(:,:,maintain), edges, edges, 'Normalization', 'probability');
maintain_diff = maintain_L - maintain_R;

%% Plot
c_lim = [-0.005, 0.005];
c_lim_diff = [-0.001, 0.001];

figure;
% whole trial period - L
subplot(3,3,1)
hold on
imagesc('XData', bins, 'YData', bins, 'CData', whole_L');
plot(2 * cos(0:pi/50:2*pi), 2 * sin(0:pi/50:2*pi));
colorbar
ax = gca();
ax.YTick = [-6:3:6];
ax.XTick = [-6:3:6];
ax.TickLength = [0.015 0.03];
xlim([-6,6])
ylim([-6,6])
set(gca, 'FontSize', 20,'Fontname','Arial', 'LineWidth', 1.5);
set(gca,'TickDir','out');
colormap(brewermap(1000, 'PRGn'));
caxis(c_lim)
title('L')

% whole trial period - R
subplot(3,3,2)
hold on
imagesc('XData', bins, 'YData', bins, 'CData', whole_R');
plot(2 * cos(0:pi/50:2*pi), 2 * sin(0:pi/50:2*pi));
colorbar
ax = gca();
ax.YTick = [-6:3:6];
ax.XTick = [-6:3:6];
ax.TickLength = [0.015 0.03];
xlim([-6,6])
ylim([-6,6])
set(gca, 'FontSize', 20,'Fontname','Arial', 'LineWidth', 1.5);
set(gca,'TickDir','out');
colormap(brewermap(1000, 'PRGn'));
caxis(c_lim)
title('R')

% whole trial period - diff
subplot(3,3,3)
hold on
imagesc('XData', bins, 'YData', bins, 'CData', whole_diff');
plot(2 * cos(0:pi/50:2*pi), 2 * sin(0:pi/50:2*pi));
colorbar
ax = gca();
ax.YTick = [-6:3:6];
ax.XTick = [-6:3:6];
ax.TickLength = [0.015 0.03];
xlim([-6,6])
ylim([-6,6])
set(gca, 'FontSize', 20,'Fontname','Arial', 'LineWidth', 1.5);
set(gca,'TickDir','out');
colormap(brewermap(1000, 'PRGn'));
caxis(c_lim_diff)
title('diff')

% shift trial period - L
subplot(3,3,4)
hold on
imagesc('XData', bins, 'YData', bins, 'CData', shift_L');
plot(2 * cos(0:pi/50:2*pi), 2 * sin(0:pi/50:2*pi));
colorbar
ax = gca();
ax.YTick = [-6:3:6];
ax.XTick = [-6:3:6];
ax.TickLength = [0.015 0.03];
xlim([-6,6])
ylim([-6,6])
set(gca, 'FontSize', 20,'Fontname','Arial', 'LineWidth', 1.5);
set(gca,'TickDir','out');
colormap(brewermap(1000, 'PRGn'));
caxis(c_lim)
title('L')

% shift trial period - R
subplot(3,3,5)
hold on
imagesc('XData', bins, 'YData', bins, 'CData', shift_R');
plot(2 * cos(0:pi/50:2*pi), 2 * sin(0:pi/50:2*pi));
colorbar
ax = gca();
ax.YTick = [-6:3:6];
ax.XTick = [-6:3:6];
ax.TickLength = [0.015 0.03];
xlim([-6,6])
ylim([-6,6])
set(gca, 'FontSize', 20,'Fontname','Arial', 'LineWidth', 1.5);
set(gca,'TickDir','out');
colormap(brewermap(1000, 'PRGn'));
caxis(c_lim)
title('R')

% shift trial period - diff
subplot(3,3,6)
hold on
imagesc('XData', bins, 'YData', bins, 'CData', shift_diff');
plot(2 * cos(0:pi/50:2*pi), 2 * sin(0:pi/50:2*pi));
colorbar
ax = gca();
ax.YTick = [-6:3:6];
ax.XTick = [-6:3:6];
ax.TickLength = [0.015 0.03];
xlim([-6,6])
ylim([-6,6])
set(gca, 'FontSize', 20,'Fontname','Arial', 'LineWidth', 1.5);
set(gca,'TickDir','out');
colormap(brewermap(1000, 'PRGn'));
caxis(c_lim_diff)
title('diff')

% maintain trial period - L
subplot(3,3,7)
hold on
imagesc('XData', bins, 'YData', bins, 'CData', maintain_L');
plot(2 * cos(0:pi/50:2*pi), 2 * sin(0:pi/50:2*pi));
colorbar
ax = gca();
ax.YTick = [-6:3:6];
ax.XTick = [-6:3:6];
ax.TickLength = [0.015 0.03];
xlim([-6,6])
ylim([-6,6])
set(gca, 'FontSize', 20,'Fontname','Arial', 'LineWidth', 1.5);
set(gca,'TickDir','out');
colormap(brewermap(1000, 'PRGn'));
caxis(c_lim)
title('L')

% maintain trial period - R
subplot(3,3,8)
hold on
imagesc('XData', bins, 'YData', bins, 'CData', maintain_R');
plot(2 * cos(0:pi/50:2*pi), 2 * sin(0:pi/50:2*pi));
colorbar
ax = gca();
ax.YTick = [-6:3:6];
ax.XTick = [-6:3:6];
ax.TickLength = [0.015 0.03];
xlim([-6,6])
ylim([-6,6])
set(gca, 'FontSize', 20,'Fontname','Arial', 'LineWidth', 1.5);
set(gca,'TickDir','out');
colormap(brewermap(1000, 'PRGn'));
caxis(c_lim)
title('R')

% maintain trial period - diff
subplot(3,3,9)
hold on
imagesc('XData', bins, 'YData', bins, 'CData', maintain_diff');
plot(2 * cos(0:pi/50:2*pi), 2 * sin(0:pi/50:2*pi));
colorbar
ax = gca();
ax.YTick = [-6:3:6];
ax.XTick = [-6:3:6];
ax.TickLength = [0.015 0.03];
xlim([-6,6])
ylim([-6,6])
set(gca, 'FontSize', 20,'Fontname','Arial', 'LineWidth', 1.5);
set(gca,'TickDir','out');
colormap(brewermap(1000, 'PRGn'));
caxis(c_lim_diff)
title('diff')