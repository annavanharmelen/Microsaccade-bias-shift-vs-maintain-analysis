%% Create gaze heatmaps (for fixational control)

%% start clean
clear; clc; close all;

[data_path, figure_path] = setup(1);

x_data = []; y_data = []; L_x_data = []; R_x_data = []; L_y_data = []; R_y_data = []; 

%% parameters
pp2do = [2:25];

nan_trial_overlap = 0;
nan_post_target = 1;

baselineCorrect     = 1; 

plotResults         = 0;
saveFigures         = 0;

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
    
    param = get_subject_parameters(1, pp, data_path);
    load([param.path, '\epoched_data\eyedata_exp1', toadd1, toadd2, '__', param.subjName], 'eyedata');

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

%% Creat data for supplementary gaze heatplot figure
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

if plotResults
    %% Plot all time periods
    c_lim = [-0.005, 0.005];
    c_lim_diff = [-0.0005, 0.0005];
    
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
    set(gca, 'FontSize', 20,'Fontname','Aptos', 'LineWidth', 1.5);
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
    set(gca, 'FontSize', 20,'Fontname','Aptos', 'LineWidth', 1.5);
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
    set(gca, 'FontSize', 20,'Fontname','Aptos', 'LineWidth', 1.5);
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
    set(gca, 'FontSize', 20,'Fontname','Aptos', 'LineWidth', 1.5);
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
    set(gca, 'FontSize', 20,'Fontname','Aptos', 'LineWidth', 1.5);
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
    set(gca, 'FontSize', 20,'Fontname','Aptos', 'LineWidth', 1.5);
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
    set(gca, 'FontSize', 20,'Fontname','Aptos', 'LineWidth', 1.5);
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
    set(gca, 'FontSize', 20,'Fontname','Aptos', 'LineWidth', 1.5);
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
    set(gca, 'FontSize', 20,'Fontname','Aptos', 'LineWidth', 1.5);
    set(gca,'TickDir','out');
    colormap(brewermap(1000, 'PRGn'));
    caxis(c_lim_diff)
    title('diff')

    %% Plot shift period only for supplementary figure
    c_lim = [-0.006, 0.006];
    c_lim_diff = [-0.0006, 0.0006];
    
    figure;
    % shift trial period - L
    L = subplot(1,3,1);
    hold on
    imagesc('XData', bins(6:236), 'YData', bins(6:236), 'CData', shift_L(6:236,6:236)');
    plot(2 * cos(0:pi/50:2*pi), 2 * sin(0:pi/50:2*pi), '--', 'LineWidth', 2.6, 'Color', [0.6, 0.6, 0.6]);
    yticks([-6:3:6]);
    xticks([-6:3:6]);
    xlim([-6,6]);
    ylim([-6,6]);
    ylabel('Y-position gaze ( )');
    colormap(brewermap(1000, 'PRGn'));
    colorbar('off');
    caxis(c_lim)
    title('Left')
    
    % shift trial period - R
    M = subplot(1,3,2);
    hold on
    imagesc('XData', bins(6:236), 'YData', bins(6:236), 'CData', shift_R(6:236,6:236)');
    plot(2 * cos(0:pi/50:2*pi), 2 * sin(0:pi/50:2*pi), '--', 'LineWidth', 2.6, 'Color', [0.6, 0.6, 0.6]);
    yticks([-6:3:6]);
    xticks([-6:3:6]);
    xlim([-6,6]);
    ylim([-6,6]);
    colormap(brewermap(1000, 'PRGn'));
    caxis(c_lim)
    c1 = colorbar();
    c1.Position = [0.5307 0.37 0.012 0.30];
    c1.Ticks = [-0.005, 0, 0.005];
    c1.TickLabels = {[]};
    title('Right')
    
    % shift trial period - diff
    R = subplot(1,3,3);
    hold on
    imagesc('XData', bins(6:236), 'YData', bins(6:236), 'CData', shift_diff(6:236,6:236)');
    plot(2 * cos(0:pi/50:2*pi), 2 * sin(0:pi/50:2*pi), '--', 'LineWidth', 2.6, 'Color', [0.6, 0.6, 0.6]);
    yticks([-6:3:6]);
    xticks([-6:3:6]);
    xlim([-6,6]);
    ylim([-6,6]);
    ylabel('Y-position gaze ( )');
    colormap(brewermap(1000, 'PRGn'));
    caxis(c_lim_diff)
    c2 = colorbar();
    c2.Position = [0.8729 0.37 0.012 0.30];
    c2.Ticks=[-0.005, 0, 0.005];
    c2.TickLabels = {[]};
    title('Left vs. Right')
    
    % general
    set(gcf(), 'Position', [500 500 1500 400]);

    axes = {L, M, R};
    for i = 1:size(axes,2)
        xlabel(axes{i}, 'X-position gaze ( )');
        set(axes{i}, 'Box', 'on');
        set(axes{i}, 'TickLabelInterpreter', 'tex');
        set(axes{i}, 'FontSize', [20.7]);
        set(axes{i}, 'FontName', 'Aptos');
        set(axes{i}, 'LineWidth', 1);
        axis(axes{i}, "square");
    end

    set(L, 'position', [0.1300 0.1100 0.1703 0.8150]);
    set(M, 'position', [0.3500 0.1100 0.1703 0.8150]);
    set(R, 'position', [0.6916 0.1100 0.1703 0.8150]);

    set(gcf, 'Renderer', 'Painters');
    
    if saveFigures
        print(fullfile(figure_path, "supl_gazeheatmaps_E1"), "-dsvg", "-vector")
        print(fullfile(figure_path, "supl_gazeheatmaps_E1"), "-dpng")
    end
end
