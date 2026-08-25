%% Script for doing stats on behavioural data.
% =========================================================================
% SCRIPT: s02_behaviour_stats.m
% DESCRIPTION: Performs all statistical tests on the behavioural data.

% DEPENDENCIES: 
%   1. behaviour/s01_get_behaviour.m

% NOTE 1: run the above dependent script with only those pp's you want to include in the analysis here.
% =========================================================================

%% Bar stats
[h,p,ci,stats] = ttest(reaction_time_validity(:,1), reaction_time_validity(:,2))
[h,p,ci,stats] = ttest(error_validity(:,1), error_validity(:,2))

% Cohens d's for paired samples
rt_d = meanEffectSize(reaction_time_validity(:,1), reaction_time_validity(:,2), "Paired", true, "Effect", "cohen") 
acc_d = meanEffectSize(error_validity(:,1), error_validity(:,2), "Paired", true, "Effect", "cohen")

%% SOA t-test stats
for soa = 1:size(trial_lengths, 2)
    disp(['soa: ', num2str(trial_lengths(soa))])
    [h,p,i,stats] = ttest(reaction_time_per_soa_valid(:,soa), reaction_time_per_soa_invalid(:,soa));
    disp(['rt: ', 'p=', num2str(p)])
    disp(stats)
    [h,p,i,stats] = ttest(accuracy_per_soa_valid(:,soa), accuracy_per_soa_invalid(:,soa));
    disp(['acc: ', 'p=', num2str(p)])
    disp(stats)
    disp(' ');
end

%% SOA cluster stats
statcfg.xax = trial_lengths;
statcfg.npermutations = 1000;
statcfg.clusterStatEvalaluationAlpha = 0.05;
statcfg.nsub = 24;
statcfg.statMethod = 'analytic';

data_cond1 = accuracy_per_soa_valid;
data_cond2 = accuracy_per_soa_invalid;
data_cond3 = reaction_time_per_soa_valid;
data_cond4 = reaction_time_per_soa_invalid;

stat_a = frevede_ftclusterstat1D(statcfg, data_cond1, data_cond2)
stat_r = frevede_ftclusterstat1D(statcfg, data_cond3, data_cond4)
