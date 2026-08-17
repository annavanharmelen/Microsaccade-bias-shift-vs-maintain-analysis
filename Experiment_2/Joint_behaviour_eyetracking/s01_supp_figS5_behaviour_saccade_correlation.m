%% Calculate correlation and create figure showing relationship between behavioural benefits and microsaccade bias magnitude
% Run both getBehaviour.m and GA_SaccadeBias.m first

rt_effect = reaction_time_validity(:,1) - reaction_time_validity(:,2);
acc_effect = (error_validity(:,1) - error_validity(:,2))*100;

[rt_r_p,rt_p_p] = corr(rt_effect, avg_saccade_effect(:,1), 'Type', 'Pearson')
[rt_r_s,rt_p_s] = corr(rt_effect, avg_saccade_effect(:,1), 'Type', 'Spearman')
[acc_r_p,acc_p_p] = corr(acc_effect, avg_saccade_effect(:,1), 'Type', 'Pearson')
[acc_r_s,acc_p_s] = corr(acc_effect, avg_saccade_effect(:,1), 'Type', 'Spearman')

figure;
rt = subplot(2,1,1);
hold on
plot([-200,800], [0,0], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
plot([0,0], [-0.05, 0.25], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
scatter(-rt_effect, avg_saccade_effect(:,1), 60, 'k', 'filled');
line1 = lsline;
line1.LineWidth = 2;
line1.Color = [0,0,0];
ylim([-0.05, 0.25]);
xlim([-200, 800]);
xticks([0, 400, 800]);
ylabel('Saccade bias (ΔHz)');
xlabel('RT benefit (ms)');
axis('square');

acc = subplot(2,1,2);
hold on
plot([-20,80], [0,0], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
plot([0,0], [-0.05, 0.25], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
scatter(acc_effect, avg_saccade_effect(:,1), 60, 'k', 'filled');
line2 = lsline;
line2.LineWidth = 2;
line2.Color = [0,0,0];
ylim([-0.05, 0.25]);
xlim([-20, 80]);
xticks([0, 40, 80]);
ylabel('Saccade bias (ΔHz)');
xlabel('Accuracy benefit (%)');
axis('square');

set(gcf(), 'Position', [600 250 680 1060]);

axes = {rt, acc};
for i = 1:size(axes,2)
    set(axes{i}, 'Box', 'on');
    set(axes{i}, 'FontSize', [24.6]);
    set(axes{i}, 'FontName', 'Aptos');
    set(axes{i}, 'LineWidth', 1);
end

print("..\..\..\..\Manuscripts\Shift-vs.-maintain\Figures\supl_behaviour_x_bias_E2", "-dsvg")
print("..\..\..\..\Manuscripts\Shift-vs.-maintain\Figures\supl_behaviour_x_bias_E2", "-dpng")