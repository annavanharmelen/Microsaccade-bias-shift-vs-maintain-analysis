pp_to_plot = [1:2,5:9,11,13:24, 26:29];

[r1, p1] = corr(overall_dt, saccade_rate(pp_to_plot,1), 'Type', 'Pearson')
[r2, p2] = corr(overall_dt, saccade_rate(pp_to_plot,2), 'Type', 'Pearson')
[r3, p3] = corr(overall_dt, saccade_rate(pp_to_plot,3), 'Type', 'Pearson')
[r4, p4] = corr(reaction_time_validity(:,1), saccade_rate_valid(pp_to_plot,1), 'Type', 'Pearson')
[r5, p5] = corr(reaction_time_validity(:,1), saccade_rate_valid(pp_to_plot,2), 'Type', 'Pearson')
[r6, p6] = corr(reaction_time_validity(:,1), saccade_rate_valid(pp_to_plot,3), 'Type', 'Pearson')

figure;
subplot(2,3,1)
scatter(overall_dt, saccade_rate(pp_to_plot,1), 'filled')
lsline;
title(sprintf('overall RT x overall saccade rate r: %0.2f p: %0.2f', r1, p1));

subplot(2,3,2)
scatter(overall_dt, saccade_rate(pp_to_plot,2), 'filled')
lsline;
title(sprintf('overall RT x shift saccade rate r: %0.2f p: %0.2f', r2, p2));

subplot(2,3,3)
scatter(overall_dt, saccade_rate(pp_to_plot,3), 'filled')
lsline;
title(sprintf('overall RT x sustain saccade rate r: %0.2f p: %0.2f', r3, p3));

subplot(2,3,4)
scatter(reaction_time_validity(:,1), saccade_rate_valid(pp_to_plot,1), 'filled')
lsline;
title(sprintf('valid RT x overall saccade rate r: %0.2f p: %0.2f', r4, p4));

subplot(2,3,5)
scatter(reaction_time_validity(:,1), saccade_rate_valid(pp_to_plot,2), 'filled')
lsline;
title(sprintf('valid RT x shift saccade rate r: %0.2f p: %0.2f', r5, p5));

subplot(2,3,6)
scatter(reaction_time_validity(:,1), saccade_rate_valid(pp_to_plot,3), 'filled')
lsline;
title(sprintf('valid RT x sustain saccade rate r: %0.2f p: %0.2f', r6, p6));
