%% Determine effect of ISI

%% start clean
clear; clc; close all;

[data_path, figure_path] = setup(2);

%% parameter
plotResults = 0;
nan_trial_overlap = 0;
nan_post_target = 1;

remove_unfixated = 1;
remove_prematures = 1;
only_over_1400 = 1;

%% loop over participants
for pp = [1:2,5:9,11,13:24, 26:29];

    %% load epoched data of this participant data
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

    param = get_subject_parameters(2, pp, data_path);
    load([param.path, '\epoched_data\eyedata_exp2', toadd1, toadd2, '__', param.subjName], 'eyedata');

    %% only keep channels of interest
    cfg = [];
    cfg.channel = {'eyeX','eyeY'}; % only keep x & y axis
    eyedata = ft_selectdata(cfg, eyedata); % select x & y channels

    %% reformat all data to a single matrix of trial x channel x time
    cfg = [];
    cfg.keeptrials = 'yes';
    tl = ft_timelockanalysis(cfg, eyedata); % realign the data: from trial*time cells into trial*channel*time?
    tl.time = tl.time * 1000;

    %% remove trials interrupted by eyetracker
    if remove_unfixated
        % get behavioural data
        behdata = readtable(get_subject_parameters(2, pp, data_path).log);

        % remove trials already not in eyedata from behavioural data
        to_remove = ismember(behdata.exit_stage, {'stimuli_onset'});
        behdata = behdata(logical(1-to_remove), :);
        
        % select unbroken trials
        oktrials = ismember(behdata.broke_fixation, {'False'});

        % select trials broken after target change
        also_oktrials = ismember(behdata.exit_stage, {'orientation_change'});
        
        % remove non-oktrials from behavioural and eye-tracking data
        behdata = behdata(logical(oktrials+also_oktrials), :);
        tl.trial = tl.trial(logical(oktrials+also_oktrials),:,:);
        tl.trialinfo = tl.trialinfo(logical(oktrials+also_oktrials),:,:);
    end

    %% remove trials with premature keyboard response
    if remove_prematures
        % get behavioural data
        if remove_unfixated == 0
            behdata = readtable(get_subject_parameters(2, pp, data_path).log);
        end
        
        % select premature trials
        oktrials = ismember(behdata.premature_pressed, {'False'});
    
        % remove non-oktrials from behavioural and eye-tracking data
        behdata = behdata(logical(oktrials), :);
        tl.trial = tl.trial(oktrials,:,:);
        tl.trialinfo = tl.trialinfo(oktrials,:,:);
    end
    
    %% select only trials of min 1400 ms long
    if only_over_1400
        % load data if necessary
        if remove_unfixated == 0 & remove_prematures == 0
            behdata = readtable(get_subject_parameters(2, pp, data_path).log);
        end
        
        % keep only trials of min 1400 ms long
        to_keep = behdata.static_duration>=1400;
        
        behdata = behdata(logical(to_keep), :);
        tl.trial = tl.trial(logical(to_keep),:,:);
        tl.trialinfo = tl.trialinfo(logical(to_keep),:,:);
    end

    %% pixel to degree
    [dva_x, dva_y] = frevede_pixel2dva(squeeze(tl.trial(:,1,:)), squeeze(tl.trial(:,2,:)));
    tl.trial(:,1,:) = dva_x;
    tl.trial(:,2,:) = dva_y;

    % channels
    chX = ismember(tl.label, 'eyeX');
    chY = ismember(tl.label, 'eyeY');

    %% get gaze shifts using our custom function
    cfg.minISI = 100;
    data_input = squeeze(tl.trial);
    time_input = tl.time;

    [shiftsX,shiftsY, peakvelocity, times] = PBlab_gazepos2shift_2D(cfg, data_input(:,chX,:), data_input(:,chY,:), time_input);
    saccades(pp,1) = sum(abs(shiftsX) > 0, 'all');

    cfg.minISI = 50;

    [shiftsX,shiftsY, peakvelocity, times] = PBlab_gazepos2shift_2D(cfg, data_input(:,chX,:), data_input(:,chY,:), time_input);
    saccades(pp,2) = sum(abs(shiftsX) > 0, 'all');

end

%% calculate effect of ISI
percentage_saccade = mean(saccades([1:2,5:9,11,13:24, 26:29], 2) ./ saccades([1:2,5:9,11,13:24, 26:29], 1));
