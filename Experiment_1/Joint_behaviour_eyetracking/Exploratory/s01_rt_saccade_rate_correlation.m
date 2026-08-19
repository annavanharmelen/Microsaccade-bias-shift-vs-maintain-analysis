%% Calculate correlation and create figure showing relationship between response times and microsaccade rates
% =========================================================================
% SCRIPT: s01_rt_saccade_rate_correlation.m (Exploratory)
% DESCRIPTION: Correlates response times (RT) with saccade rates across subjects.

% DEPENDENCIES: 
%   1. behaviour/01_get_behaviour.m
%   2. eyetracking/02_get_saccade_bias.m

% NOTE 1: run the two above dependent scripts with only those pp's you want to include in the analysis here.
% NOTE 2: whichever of the two above scripts you run second, run them without the "clear; clc; close all;" statements.
% =========================================================================

[r1, p1] = corr(overall_dt, saccade_rate(:,1), 'Type', 'Pearson');
[r2, p2] = corr(overall_dt, saccade_rate(:,2), 'Type', 'Pearson');
[r3, p3] = corr(overall_dt, saccade_rate(:,3), 'Type', 'Pearson');
[r4, p4] = corr(reaction_time_validity(:,1), saccade_rate_valid(:,1), 'Type', 'Pearson');
[r5, p5] = corr(reaction_time_validity(:,1), saccade_rate_valid(:,2), 'Type', 'Pearson')
[r6, p6] = corr(reaction_time_validity(:,1), saccade_rate_valid(:,3), 'Type', 'Pearson')


%% create figure

figure;
rt = subplot(2,1,1);
hold on
scatter(reaction_time_validity(:,1), saccade_rate_valid(:,2)/0.4, 60, 'k', 'filled');
line1 = lsline;
line1.LineWidth = 2;
line1.Color = [0,0,0];
ylim([0, 2]);
xlim([500, 1500]);
xticks([500, 1000, 1500]);
ylabel('Saccade rate (Hz)');
xlabel('Reaction time (ms)');
axis('square');

acc = subplot(2,1,2);
hold on
scatter(reaction_time_validity(:,1), saccade_rate_valid(:,3)/0.8, 60, 'k', 'filled');
line2 = lsline;
line2.LineWidth = 2;
line2.Color = [0,0,0];
ylim([0, 2]);
xlim([500, 1500]);
xticks([500, 1000, 1500]);
ylabel('Saccade rate (Hz)');
xlabel('Reaction time (ms)');
axis('square');

set(gcf(), 'Position', [600 250 600 1060]);

axes = {rt, acc};
for i = 1:size(axes,2)
    set(axes{i}, 'Box', 'on');
    set(axes{i}, 'FontSize', [24.6]);
    set(axes{i}, 'FontName', 'Aptos');
    set(axes{i}, 'LineWidth', 1);
end

print("..\..\..\..\Manuscripts\Shift-vs.-maintain\Figures\supl_rt_x_rate_E1", "-dsvg")
print("..\..\..\..\Manuscripts\Shift-vs.-maintain\Figures\supl_rt_x_rate_E1", "-dpng")
