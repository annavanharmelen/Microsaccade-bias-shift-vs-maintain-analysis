%% Create main sequenceplot of saccades
% first run get_SaccadeBias with only the pp's you want to include

%% set parameters
saveFigures         = 0;

x_bins = [0:0.02:2.5];
y_bins = [0:0.002:0.5];
x_window = 0.04;
y_window = 0.004;
x_edges = [x_bins - (x_window/2), x_bins(end) + (x_window/2)];
y_edges = [y_bins - (y_window/2), y_bins(end) + (y_window/2)];
main_sequence = histcounts2(amplitudes, velocities, x_edges, y_edges, 'Normalization', 'probability');

%% figure
figure;
hold on
imagesc('XData', x_bins(3:end-2), 'YData', y_bins(5:end-2), 'CData', main_sequence(3:end-2, 5:end-2)');
xlim([0, 2.5]);
ylim([0, 0.25]);
yticks([0 0.1 0.2]);
xticks([0 1 2]);
colormap(brewermap(1000, 'greens'));
c = colorbar;
caxis([0 0.000004]);
c.Ticks=[0, 2, 4]*0.000001;
c.TickLabels = {[]};
yline(0.25, 'LineWidth', 1, 'Alpha', 1);
plot([1,1], [0.246, 0.25], 'LineWidth', 1, 'Color', [0 0 0 1]);
plot([2,2], [0.246, 0.25], 'LineWidth', 1, 'Color', [0 0 0 1]);
xlabel('Saccade amplitude ( )');
ylabel('Saccade peak velocity ( /ms)');
set(gca, 'Box', 'on');
set(gca, 'FontSize', [24.6]);
set(gca, 'FontName', 'Aptos');
set(gca, 'LineWidth', 1);
axis('square');
set(gcf(), 'Position', [500 500 800 600]);

if saveFigures
    print(fullfile(figure_path, "supl_mainsequence_E2"), "-dsvg")
    print(fullfile(figure_path, "supl_mainsequence_E2"), "-dpng")
end
