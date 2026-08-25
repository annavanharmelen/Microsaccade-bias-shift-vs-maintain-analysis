%% Script for doing stats on saccade bias data.
% =========================================================================
% SCRIPT: s02_saccade_bias_stats.m
% DESCRIPTION: Performs all statistical tests on the eyetracking data.

% DEPENDENCIES: 
%   1. eyetracking/s01_GA_saccade_bias.m

% NOTE 1: run the above dependent script with only those pp's you want to include in the analysis here.
% =========================================================================

%% Saccade bias data - stats
statcfg.xax = saccade.time(timeframe);
statcfg.npermutations = 10000;
statcfg.clusterStatEvalaluationAlpha = 0.05;
statcfg.nsub1 = 24; %for between pp
statcfg.nsub2 = 24; %for between pp
statcfg.statMethod = 'montecarlo';
%statcfg.statMethod = 'analytic';

timeframe = [451:1851]; %this is 0 to 1400 ms post-cue
ft_size = 26;

data_e1 = saccade_data(1:24,5,timeframe);
data_e2 = saccade_data(25:48,5,timeframe);

stat = frevede_ftclusterstat1D_indep(statcfg, data_e1, data_e2);

%% Saccade bias data - plot only effect
mask_comp = double(stat.mask);
mask_comp(mask_comp==0) = nan; % nan data that is not part of mark

figure;
hold on
p1 = frevede_errorbarplot(saccade.time, squeeze(saccade_data(1:24,5,:)), bright_colours(3,:), 'se');
p2 = frevede_errorbarplot(saccade.time, squeeze(saccade_data(25:48,5,:)), bright_colours(3,:), 'se');
p1.LineWidth = 2.5;
p2.LineWidth = 2.5;
sig2 = plot(saccade.time(timeframe), mask_comp*-0.015, 'k', 'LineWidth', 5);
fontsize(23, 'points')
xlim([-100, 1400]);
plot(xlim, [0,0], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
plot([0,0], ylim, '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
% legend([p7], 'effect', 'EdgeColor', 'w', 'Fontsize', 28);
ylabel('Rate (Hz)', 'Fontsize', 28);
xlabel('Time (ms)', 'Fontsize', 28);
set(gcf,'position',[0,0, 1800,900])
xlabel('Time (ms)');
hold off
