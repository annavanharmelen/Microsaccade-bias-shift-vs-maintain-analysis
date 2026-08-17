%% Determine whether the first saccade in the shift period has an effect on RT
% =========================================================================
% SCRIPT: 01_effect_saccade_direction_on_rt.m (Exploratory)
% DESCRIPTION: Tests whether the direction of the first saccade made during the shift period affects response times (across subjects).

% DEPENDENCIES: 
%   1. eyetracking/02_get_saccade_bias.m

% NOTE 1: run the above dependent script with only those pp's you want to include in the analysis here.
% =========================================================================

pp2do = [2:25];
p = 0;

for pp = pp2do
    p = p+1;
    ppnum(p) = pp;
    figure_nr = 1;
    figure_nr =  figure_nr+5;
    
    param = getSubjParam(pp);
    disp(['getting data from ', param.subjName]);
    
    %% load actual behavioural data
    behdata = readtable(param.log);

    %% check unbroken trials
    % remove trials with premature keyboard response
    oktrials = ismember(behdata.premature_pressed, {'False'});
    behdata = behdata(logical(oktrials), :);

    %% trial selections
    valid_trials = ismember(behdata.trial_condition, {'valid'});
    invalid_trials = ismember(behdata.trial_condition, {'invalid'});
    
    total_trial_numbers(p,1) = sum(valid_trials);
    total_trial_numbers(p,2) = sum(invalid_trials);

    %% extract data of interest
    reaction_time_saccade(p,1) = nanmean(behdata.response_time_in_ms(valid_trials&all_toward{pp}));
    reaction_time_saccade(p,2) = nanmean(behdata.response_time_in_ms(valid_trials&all_away{pp}));
    reaction_time_saccade(p,3) = nanmean(behdata.response_time_in_ms(valid_trials&all_nosacc{pp}));
    
end

%% compare reaction time on toward, away and no saccade trials
figure;
hold on
bar(mean(reaction_time_saccade));
errorbar([1, 2, 3], mean(reaction_time_saccade), (std(reaction_time_saccade) ./ sqrt(size(pp2do, 2))), "LineStyle","none");
xticks([1, 2, 3])
xticklabels({'toward saccade', 'away saccade', 'no saccade'})
title('About saccades in shift window and valid trials only');

%% stats
[h,p,ci,stats] = ttest(reaction_time_saccade(:,1), reaction_time_saccade(:,2))
