%% Script for doing stats on saccade bias data.
% =========================================================================
% SCRIPT: s04_saccade_bias_stats.m
% DESCRIPTION: Performs all statistical tests on the eyetracking data.

% DEPENDENCIES: 
%   1. eyetracking/s03_GA_saccade_bias.m

% NOTE 1: run the above dependent script with only those pp's you want to include in the analysis here.
% =========================================================================

%% set parameters
saveFigures         = 0;

%% Avg saccade bias over time - stats
%% Bar stats
[h,p,ci,stats] = ttest(avg_saccade_effect(:,1))
[h,p,ci,stats] = ttest(avg_saccade_effect(:,2))
[h,p,ci,stats] = ttest(avg_saccade_effect(:,1), avg_saccade_effect(:,2))

% Cohens d's for paired samples
shift_d = meanEffectSize(avg_saccade_effect(:,1), "Effect", "cohen") 
maintain_d = meanEffectSize(avg_saccade_effect(:,2), "Effect", "cohen")
shift_vs_maintain_d = meanEffectSize(avg_saccade_effect(:,1), avg_saccade_effect(:,2), "Paired", true, "Effect", "cohen") 

%% Saccade bias data - stats
statcfg.xax = saccade.time;
statcfg.npermutations = 10000;
statcfg.clusterStatEvalaluationAlpha = 0.05;
statcfg.nsub = s;
statcfg.statMethod = 'montecarlo';
%statcfg.statMethod = 'analytic';

ft_size = 26;
timeframe = [451:1851]; %this is 0 to 1400 ms post-cue

data_cond1 = saccade_data(:,1,:);
data_cond2 = saccade_data(:,3,:);
data_cond3 = saccade_data(:,5,timeframe);
data_cond4 = zeros(size(data_cond3));

stat = frevede_ftclusterstat1D(statcfg, data_cond3, data_cond4)
% stat1 = frevede_ftclusterstat1D(statcfg, data_cond1, data_cond4)
% stat2 = frevede_ftclusterstat1D(statcfg, data_cond2, data_cond4)
%% Saccade bias data - plot only effect
mask_xxx = double(stat.mask);
mask_xxx(mask_xxx==0) = nan; % nan data that is not part of mark

figure;
hold on
p1 = frevede_errorbarplot(saccade.time, squeeze(saccade_data(:,5,:)), [0.6, 0.6, 0.6], 'se');
p1.LineWidth = 6;
sig = plot(saccade.time(timeframe), mask_xxx*-0.01, 'Color', 'k', 'LineWidth', 10); % verticaloffset for positioning of the "significance line"

fontsize(23, 'points')
xlim(xlimtoplot);
ylim([-0.02 0.1]);
yticks([0 0.05 0.1]);
plot(xlim, [0,0], '--', 'LineWidth',6, 'Color', [0.6, 0.6, 0.6]);
plot([0,0], ylim, '--', 'LineWidth',6, 'Color', [0.6, 0.6, 0.6]);
% legend([p7], 'effect', 'EdgeColor', 'w', 'Fontsize', 28);
ylabel('Saccade bias (ΔHz)', 'Fontsize', 28);
set(gcf,'position',[0,0, 1800,1060])
xlabel('Time after cue onset (ms)');
xticks([0, 400, 800, 1200])
set(gca, 'FontSize', 50)
set(gca, 'Box', 'on');
set(gca(), 'Linewidth', 2.6);
set(gca(), 'FontName', 'Aptos');
hold off

if saveFigures
    print(fullfile(figure_path, "fig2B_sac_towardness_E1"), "-dsvg")
    print(fullfile(figure_path, "fig2B_sac_towardness_E1"), "-dpng")
end

% set(gcf,'position',[0,0, 1800,900])
% fontsize(ft_size*1.5,"points")

%% Saccade bias data - 45 deg effect
statcfg.xax = saccade.time;
statcfg.npermutations = 10000;
statcfg.clusterStatEvalaluationAlpha = 0.05;
statcfg.nsub = s;
statcfg.statMethod = 'montecarlo';
%statcfg.statMethod = 'analytic';

ft_size = 26;
timeframe = [451:1851]; %this is 0 to 1400 ms post-cue

data_cond1 = saccade_data(:,23,timeframe);
data_cond2 = zeros(size(data_cond1));

stat = frevede_ftclusterstat1D(statcfg, data_cond1, data_cond2)

mask_xxx = double(stat.mask);
mask_xxx(mask_xxx==0) = nan; % nan data that is not part of mark

figure;
hold on
p1 = frevede_errorbarplot(saccade.time, squeeze(saccade_data(:,23,:)), [0.6, 0.6, 0.6], 'se');
p1.LineWidth = 6;
sig = plot(saccade.time(timeframe), mask_xxx*-0.00001, 'Color', 'k', 'LineWidth', 10); % verticaloffset for positioning of the "significance line"

fontsize(23, 'points')
xlim(xlimtoplot);
ylim([-0.2 0.8]*0.0001);
yticks([0 0.4 0.8]*0.0001);
yticklabels([0, 0.4, 0.8]);
plot(xlim, [0,0], '--', 'LineWidth',6, 'Color', [0.6, 0.6, 0.6]);
plot([0,0], ylim, '--', 'LineWidth',6, 'Color', [0.6, 0.6, 0.6]);
% legend([p7], 'effect', 'EdgeColor', 'w', 'Fontsize', 28);
ylabel('Saccade bias (ΔHz)', 'Fontsize', 28);
set(gcf,'position',[0,0, 1800,1060])
xlabel('Time after cue onset (ms)');
xticks([0, 400, 800, 1200])
set(gca, 'FontSize', 60)
set(gca, 'Box', 'on');
set(gca(), 'Linewidth', 2.6);
set(gca(), 'FontName', 'Aptos');
hold off

if saveFigures
    print(fullfile(figure_path, "figS8_supl_45deg_towardness_E1"), "-dsvg")
    print(fullfile(figure_path, "figS8_supl_45deg_towardness_E1"), "-dpng")
end

%% Saccade bias upwards data
statcfg.xax = saccade.time;
statcfg.npermutations = 10000;
statcfg.clusterStatEvalaluationAlpha = 0.05;
statcfg.nsub = s;
statcfg.statMethod = 'montecarlo';
%statcfg.statMethod = 'analytic';

timeframe = [451:1851]; %this is 0 to 1400 ms post-cue

data_cond1 = saccade_data(:,2,timeframe);
data_cond2 = saccade_data(:,4,timeframe);

stat = frevede_ftclusterstat1D(statcfg, data_cond1, data_cond2)

mask_xxx = double(stat.mask);
mask_xxx(mask_xxx==0) = nan; % nan data that is not part of mark

figure;
hold on
p1 = frevede_errorbarplot(saccade.time, squeeze(saccade_data(:,2,:)) - squeeze(saccade_data(:,4,:)), [0.6, 0.6, 0.6], 'se');
p1.LineWidth = 6;
sig = plot(saccade.time(timeframe), mask_xxx*-0.075, 'Color', 'k', 'LineWidth', 10); % verticaloffset for positioning of the "significance line"

xlim(xlimtoplot);
ylim([-0.1 0.12]);
yticks([-0.1 0 0.1]);
plot(xlim, [0,0], '--', 'LineWidth',6, 'Color', [0.6, 0.6, 0.6]);
plot([0,0], ylim, '--', 'LineWidth',6, 'Color', [0.6, 0.6, 0.6]);
% legend([p7], 'effect', 'EdgeColor', 'w', 'Fontsize', 28);
ylabel('Saccade bias (ΔHz)', 'Fontsize', 28);
set(gcf,'position',[0,0, 1800,1060])
xlabel('Time after cue onset (ms)');
xticks([0, 400, 800, 1200])
set(gca, 'FontSize', 60)
set(gca, 'Box', 'on');
set(gca(), 'Linewidth', 2.6);
set(gca(), 'FontName', 'Aptos');
hold off

if saveFigures
    print(fullfile(figure_path, "figS4_supl_upward_towardness_E1"), "-dsvg")
    print(fullfile(figure_path, "figS4_supl_upward_towardness_E1"), "-dpng")
end

%% Saccade bias data - plot both
mask1_xxx = double(stat1.mask);
mask1_xxx(mask1_xxx==0) = nan; % nan data that is not part of mark

mask2_xxx = double(stat2.mask);
mask2_xxx(mask2_xxx==0) = nan; % nan data that is not part of mark

figure; hold on;

p1 = frevede_errorbarplot(saccade.time, squeeze(saccade_data(:,1,:)), bright_colours(1,:), 'se');
p2 = frevede_errorbarplot(saccade.time, squeeze(saccade_data(:,3,:)), bright_colours(2,:), 'se');

p1.LineWidth = 3.5;
p2.LineWidth = 3.5;

% plot(xlim, [0,0], '--','LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
plot([0,0], [-0.5, 1], '--','LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
xlim(xlimtoplot);

% sig1 = plot(saccade.time, mask1_xxx*0.02, 'Color', colours(1,:), 'LineWidth', 5); % verticaloffset for positioning of the "significance line"
% sig2 = plot(saccade.time, mask2_xxx*0.01, 'Color', colours(2,:), 'LineWidth', 5);

ylim([0 0.25]);
yticks([0.1 0.2]);
ylabel('Saccade bias (ΔHz)', 'Position', [-892.5697 0.1250 -1]);
xlabel('Time (ms)');
set(gcf,'position',[0,0, 2000,900])
fontsize(ft_size*1.5,"points")
legend([p1,p2], {'Target', 'Non-target'}, 'EdgeColor', 'w', 'Location', 'northeast');
