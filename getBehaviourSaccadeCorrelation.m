%% Calculate correlation and create figure showing relationship between behavioural benefits and microsaccade bias magnitude
% Run both getBehaviour.m and GA_SaccadeBias.m first

rt_effect = reaction_time_validity(:,1) - reaction_time_validity(:,2);
acc_effect = error_validity(:,1) - error_validity(:,2);

[rt_r,rt_p] = corr(rt_effect, avg_saccade_effect(:,1), 'Type', 'Pearson');
[acc_r,acc_p] = corr(acc_effect, avg_saccade_effect(:,1), 'Type', 'Pearson');

figure;
subplot(1,2,1)
scatter(-rt_effect, avg_saccade_effect(:,1), 'k', 'filled');
lsline;
xline(0, '--');
yline(0, '--');
ylabel('Avg. saccade bias 200-600 ms (ΔHz)');
xlabel('RT benefit (ms)');

subplot(1,2,2)
scatter(acc_effect, avg_saccade_effect(:,1), 'k', 'filled');
lsline;
xline(0, '--');
yline(0, '--');
ylabel('Avg. saccade bias 200-600 ms (ΔHz)');
xlabel('Accuracy benefit (ms)');