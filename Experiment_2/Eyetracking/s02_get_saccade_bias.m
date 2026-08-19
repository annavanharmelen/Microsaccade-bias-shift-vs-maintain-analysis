%% Step3-- gaze-shift calculation

%% start clean
clear; clc; close all;

velocities = []; amplitudes = [];
all_toward = cell(25, 1);
all_away   = cell(25, 1);
all_nosacc = cell(25, 1);
p = 0;

%% parameter
plotResults = 0;
nan_trial_overlap = 0;
nan_post_target = 1;

remove_unfixated = 1;
remove_prematures = 1;
only_over_1400 = 1;

%% loop over participants
for pp = [1:2,5:9,11,13:24, 26:29];

    p = p + 1;

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

    param = getSubjParam(pp);
    load([param.path, '\epoched_data\eyedata_AnnaMicro2', toadd1, toadd2, '__', param.subjName], 'eyedata');

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
        behdata = readtable(getSubjParam(pp).log);

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
            behdata = readtable(getSubjParam(pp).log);
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
            behdata = readtable(getSubjParam(pp).log);
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

    %% selection vectors for conditions -- this is where it starts to become interesting!
    % cued item location
    targL = ismember(tl.trialinfo(:,1), [21,22,23,24]);
    targR = ismember(tl.trialinfo(:,1), [25,26,27,28]);

    cueL = ismember(tl.trialinfo(:,1), [22,24,25,27]);
    cueR = ismember(tl.trialinfo(:,1), [21,23,26,28]);

    % orientation direction change 
    clockwise       =  ismember(tl.trialinfo(:,1), [21,22,25,26]);
    anticlockwise   =  ismember(tl.trialinfo(:,1), [23,24,27,28]);
    
    % validity
    valid = ismember(tl.trialinfo(:,1), [22,24,26,28]);
    invalid = ismember(tl.trialinfo(:,1), [21,23,25,27]);

    % response accuracy
    correct = ismember(behdata.feedback, {'correct'});
    incorrect = ismember(behdata.feedback, {'incorrect'});

    % response speed
    fast = logical(behdata.response_time_in_ms < median(behdata.response_time_in_ms, "omitnan"));
    slow = logical(behdata.response_time_in_ms >= median(behdata.response_time_in_ms, "omitnan"));
       
    % channels
    chX = ismember(tl.label, 'eyeX');
    chY = ismember(tl.label, 'eyeY');

    %% get gaze shifts using our custom function
    cfg = [];
    data_input = squeeze(tl.trial);
    time_input = tl.time;

    [shiftsX,shiftsY, peakvelocity, times] = PBlab_gazepos2shift_2D(cfg, data_input(:,chX,:), data_input(:,chY,:), time_input);
    
    %% turn post-change data to NaN
    if nan_post_target

        trial_lengths = behdata.static_duration;
        
        for trial = 1:length(trial_lengths)
            selection = times > trial_lengths(trial);
    
            shiftsX(trial, selection) = NaN;
            shiftsY(trial, selection) = NaN;
            peakvelocity(trial, selection) = NaN;
        end

    end

    %% select usable gaze shifts
    minDisplacement = 0;
    maxDisplacement = 1000;

    saccadesizes = abs(shiftsX+shiftsY*1i);

    shiftsNE = double(shiftsX>0 & shiftsY>0 & (saccadesizes>minDisplacement & saccadesizes<maxDisplacement));
    shiftsNW = double(shiftsX<0 & shiftsY>0 & (saccadesizes>minDisplacement & saccadesizes<maxDisplacement));
    shiftsSE = double(shiftsX>0 & shiftsY<0 & (saccadesizes>minDisplacement & saccadesizes<maxDisplacement));
    shiftsSW = double(shiftsX<0 & shiftsY<0 & (saccadesizes>minDisplacement & saccadesizes<maxDisplacement));

    saccadeAngles = atan2d(shiftsY, shiftsX);

    shiftsSE_45 = double(abs(saccadeAngles - (-45)) <= 22.5 & (saccadesizes>minDisplacement & saccadesizes<maxDisplacement));
    shiftsSW_45 = double(abs(saccadeAngles - (-135)) <= 22.5 & (saccadesizes>minDisplacement & saccadesizes<maxDisplacement));

    shiftsSE_18 = double(abs(saccadeAngles - (-45)) <= 9 & (saccadesizes>minDisplacement & saccadesizes<maxDisplacement));
    shiftsSW_18 = double(abs(saccadeAngles - (-135)) <= 9 & (saccadesizes>minDisplacement & saccadesizes<maxDisplacement));

    %% get saccade rate per participant
    % always in order: all, shift, sustain
    saccades(p,1) = sum(abs(shiftsX) > 0, 'all');
    saccades(p,2) = sum(abs(shiftsX(:,651:1051)) > 0, 'all');
    saccades(p,3) = sum(abs(shiftsX(:,1051:1851)) > 0, 'all');

    saccades_valid(p,1) = sum(abs(shiftsX(valid,:)) > 0, 'all');
    saccades_valid(p,2) = sum(abs(shiftsX(valid,651:1051)) > 0, 'all');
    saccades_valid(p,3) = sum(abs(shiftsX(valid,1051:1851)) > 0, 'all');

    saccades_toward(p,1) = sum(abs(shiftsSW(cueL,:)) > 0, 'all') + sum(abs(shiftsSE(cueR,:)) > 0, 'all');
    saccades_toward(p,2) = sum(abs(shiftsSW(cueL,651:1051)) > 0, 'all') + sum(abs(shiftsSE(cueR,651:1051)) > 0, 'all');
    saccades_toward(p,3) = sum(abs(shiftsSW(cueL,1051:1851)) > 0, 'all') + sum(abs(shiftsSE(cueR,1051:1851)) > 0, 'all');

    saccades_away(p,1) = sum(abs(shiftsSW(cueR,:)) > 0, 'all') + sum(abs(shiftsSE(cueL,:)) > 0, 'all');
    saccades_away(p,2) = sum(abs(shiftsSW(cueR,651:1051)) > 0, 'all') + sum(abs(shiftsSE(cueL,651:1051)) > 0, 'all');
    saccades_away(p,3) = sum(abs(shiftsSW(cueR,1051:1851)) > 0, 'all') + sum(abs(shiftsSE(cueL,1051:1851)) > 0, 'all');

    trials(p,1) = size(shiftsX,1);
    trials(p,2) = sum(valid);

    %% save saccade data for behavioural comparison
    all_nosacc{pp} = ~any(abs(shiftsX(:,651:1051)) > 0, 2); % no microsaccades

    toward_shift_trials = false(size(shiftsX, 1), 1);
    away_shift_trials = false(size(shiftsX, 1), 1);

    toward_shift_trials(cueL) = any(abs(shiftsSW(cueL,651:1051)) > 0, 2); % toward microsaccades
    toward_shift_trials(cueR) = any(abs(shiftsSE(cueR,651:1051)) > 0, 2); % toward microsaccades
    away_shift_trials(cueR) = any(abs(shiftsSW(cueR,651:1051)) > 0, 2); % away microsaccades
    away_shift_trials(cueL) = any(abs(shiftsSE(cueL,651:1051)) > 0, 2); % away microsaccades

    if sum(toward_shift_trials & away_shift_trials) > 0
        multisaccade_trials = find(toward_shift_trials & away_shift_trials);
        for trial = multisaccade_trials
            % Determine which matrix is "Toward" and which is "Away" for this trial
            if cueL(trial)
                toward_matrix = shiftsSW;
                away_matrix   = shiftsSE;
            else % cueR
                toward_matrix = shiftsSE;
                away_matrix   = shiftsSW;
            end
            
            % Find the index of the first toward AND away microsaccade
            first_toward_idx = find(abs(toward_matrix(trial, 651:1051)) > 0, 1);
            first_away_idx   = find(abs(away_matrix(trial, 651:1051)) > 0, 1);
            
            % Compare previously found indexes and update the arrays accordingly
            if first_toward_idx < first_away_idx
                away_shift_trials(trial) = false;
            else
                toward_shift_trials(trial) = false;
            end
        end
    end

    all_toward{pp} = toward_shift_trials;
    all_away{pp} = away_shift_trials;

    %% create data for main-sequence plot
    velocities = [velocities; nonzeros(peakvelocity(:))];
    amplitudes = [amplitudes; nonzeros(saccadesizes(:))];

    %% get relevant contrasts out
    saccade = [];
    saccade.time = times;
    sel = ones(size(cueL)); %NB: selection of oktrials has happened at the start when remove_unfixated is "on".
    saccade.label = {'target','opp_target','nontarget','opp_nontarget', 'effect', 'target_axis', 'nontarget_axis', 'axis_effect'};

    saccade.data(1,:) = (mean(shiftsSW(cueL&sel,:), "omitnan") + mean(shiftsSE(cueR&sel,:), "omitnan")) ./ 2;
    saccade.data(2,:) = (mean(shiftsNE(cueL&sel,:), "omitnan") + mean(shiftsNW(cueR&sel,:), "omitnan")) ./ 2;
    saccade.data(3,:) = (mean(shiftsSW(cueR&sel,:), "omitnan") + mean(shiftsSE(cueL&sel,:), "omitnan")) ./ 2;
    saccade.data(4,:) = (mean(shiftsNE(cueR&sel,:), "omitnan") + mean(shiftsNW(cueL&sel,:), "omitnan")) ./ 2;
    saccade.data(5,:) = (saccade.data(1,:) - saccade.data(3,:)) / 2;
    
    % add aggregated fields
    saccade.data(6,:) = (saccade.data(1,:) + saccade.data(2,:)) / 2;
    saccade.data(7,:) = (saccade.data(3,:) + saccade.data(4,:)) / 2;
    saccade.data(8,:) = (saccade.data(6,:) - saccade.data(7,:)) / 2;

    % add extra comparisons
    saccade.data(9,:) = (mean(shiftsSW(cueL&correct,:), "omitnan") + mean(shiftsSE(cueR&correct,:), "omitnan")) ./ 2;
    saccade.data(10,:) = (mean(shiftsSW(cueR&correct,:), "omitnan") + mean(shiftsSE(cueL&correct,:), "omitnan")) ./ 2;
    saccade.data(11,:) = (saccade.data(9,:) - saccade.data(10,:)) / 2;
    saccade.data(12,:) = (mean(shiftsSW(cueL&incorrect,:), "omitnan") + mean(shiftsSE(cueR&incorrect,:), "omitnan")) ./ 2;
    saccade.data(13,:) = (mean(shiftsSW(cueR&incorrect,:), "omitnan") + mean(shiftsSE(cueL&incorrect,:), "omitnan")) ./ 2;
    saccade.data(14,:) = (saccade.data(12,:) - saccade.data(13,:)) / 2;

    saccade.data(15,:) = (mean(shiftsSW(cueL&fast,:), "omitnan") + mean(shiftsSE(cueR&fast,:), "omitnan")) ./ 2;
    saccade.data(16,:) = (mean(shiftsSW(cueR&fast,:), "omitnan") + mean(shiftsSE(cueL&fast,:), "omitnan")) ./ 2;
    saccade.data(17,:) = (saccade.data(15,:) - saccade.data(16,:)) / 2;
    saccade.data(18,:) = (mean(shiftsSW(cueL&slow,:), "omitnan") + mean(shiftsSE(cueR&slow,:), "omitnan")) ./ 2;
    saccade.data(19,:) = (mean(shiftsSW(cueR&slow,:), "omitnan") + mean(shiftsSE(cueL&slow,:), "omitnan")) ./ 2;
    saccade.data(20,:) = (saccade.data(18,:) - saccade.data(19,:)) / 2;
    
    % add smaller slices
    saccade.data(21,:) = (mean(shiftsSW_45(cueL&sel,:), "omitnan") + mean(shiftsSE_45(cueR&sel,:), "omitnan")) ./ 2;
    saccade.data(22,:) = (mean(shiftsSW_45(cueR&sel,:), "omitnan") + mean(shiftsSE_45(cueL&sel,:), "omitnan")) ./ 2;
    saccade.data(23,:) = (saccade.data(21,:) - saccade.data(22,:)) / 2;
    
    saccade.data(24,:) = (mean(shiftsSW_18(cueL&sel,:), "omitnan") + mean(shiftsSE_18(cueR&sel,:), "omitnan")) ./ 2;
    saccade.data(25,:) = (mean(shiftsSW_18(cueR&sel,:), "omitnan") + mean(shiftsSE_18(cueL&sel,:), "omitnan")) ./ 2;
    saccade.data(26,:) = (saccade.data(24,:) - saccade.data(25,:)) / 2;

    %% smooth and turn to Hz
    integrationwindow = 100; % window over which to integrate saccade counts
    
    for i = 1:size(saccade.label, 2)
        saccade.data(i,:,:) = smoothdata(saccade.data(i,:,:), 2, 'movmean', integrationwindow)*1000;
    end
       
    %% plot
    if plotResults
        figure; 
        hold on
        plot(saccade.time, saccade.data(1,:,:), 'r');
        plot(saccade.time, saccade.data(2,:,:), 'Color', [1, 0.5, 0.5]);
        plot(saccade.time, saccade.data(3,:,:), 'b');
        plot(saccade.time, saccade.data(4,:,:), 'Color', [0.5, 0.5, 1]);
        hold off

        figure;
        hold on
        plot(saccade.time, saccade.data(5,:,:), 'r');
        plot(saccade.time, saccade.data(6,:,:), 'b');
        hold off
        
        figure;
        plot(saccade.time, saccade.data(7,:,:), 'k');

        figure;
        hold on
        plot(saccade.time, saccade.data(1,:,:), 'r');
        plot(saccade.time, saccade.data(3,:,:), 'b');
        hold off
    end

    %% polar histogram
    % set shifts
    shifts = shiftsX+shiftsY*1i;
    for trial = 1:length(trial_lengths)
        selection = times > trial_lengths(trial);
        shifts(trial, selection) = NaN;
    end
    
    saccadedirection = [];
    saccadedirection.shiftsL = shifts(cueL, :);
    saccadedirection.shiftsR = shifts(cueR, :);
    saccadedirection.selectionL = abs(saccadedirection.shiftsL) > 0;
    saccadedirection.selectionR = abs(saccadedirection.shiftsR) > 0;

    if plotResults
        figure;
        subplot(2,2,1);
        polarhistogram(angle(saccadedirection.shiftsL(saccadedirection.selectionL)),20);
        subplot(2,2,2);
        polarhistogram(angle(saccadedirection.shiftsR(saccadedirection.selectionR)),20);
        subplot(2,2,3);
        histogram(abs(saccadedirection.shiftsL(saccadedirection.selectionL)));
        xlim([0 10]);
        subplot(2,2,4);
        histogram(abs(saccadedirection.shiftsR(saccadedirection.selectionR)));
        xlim([0 10]);
    end

    %% also get as function of saccade size - identical as above, except with extra loop over saccade size.
    binsize = 0.5;
    halfbin = binsize/2;

    saccadesize = [];
    saccadesize.dimord = 'chan_freq_time';
    saccadesize.freq = halfbin:0.1:7-halfbin; % shift sizes, as if "frequency axis" for time-frequency plot
    saccadesize.time = times;
    saccadesize.label = saccade.label;

    c = 0;
    for sz = saccadesize.freq;
        c = c+1;
        
        shiftsNE = [];
        shiftsNW = [];
        shiftsSE = [];
        shiftsSW = [];

        saccadeswithinrange = (sqrt(shiftsX.^2 + shiftsY.^2) > sz-halfbin) & (sqrt(shiftsX.^2 + shiftsY.^2) < sz+halfbin);

        shiftsNE = double(shiftsX>0 & shiftsY>0 & saccadeswithinrange);
        shiftsNW = double(shiftsX<0 & shiftsY>0 & saccadeswithinrange);
        shiftsSE = double(shiftsX>0 & shiftsY<0 & saccadeswithinrange);
        shiftsSW = double(shiftsX<0 & shiftsY<0 & saccadeswithinrange);
        
        % NaN data after orientation change
        for trial = 1:length(trial_lengths)
            selection = times > trial_lengths(trial);
            shiftsNE(trial, selection) = NaN;
            shiftsNW(trial, selection) = NaN;
            shiftsSE(trial, selection) = NaN;
            shiftsSW(trial, selection) = NaN;
        end

        saccadesize.data(1,c,:) = (mean(shiftsSW(cueL,:), "omitnan") + mean(shiftsSE(cueR,:), "omitnan")) ./ 2;
        saccadesize.data(2,c,:) = (mean(shiftsNE(cueL,:), "omitnan") + mean(shiftsNW(cueR,:), "omitnan")) ./ 2;
        saccadesize.data(3,c,:) = (mean(shiftsSW(cueR,:), "omitnan") + mean(shiftsSE(cueL,:), "omitnan")) ./ 2;
        saccadesize.data(4,c,:) = (mean(shiftsNE(cueR,:), "omitnan") + mean(shiftsNW(cueL,:), "omitnan")) ./ 2;
        saccadesize.data(5,c,:) = (saccadesize.data(1,c,:) - saccadesize.data(3,c,:)) ./ 2;
        
        % add aggregated fields
        saccadesize.data(6,c,:) = (saccadesize.data(1,c,:) + saccadesize.data(2,c,:)) ./ 2;
        saccadesize.data(7,c,:) = (saccadesize.data(3,c,:) + saccadesize.data(4,c,:)) ./ 2;
        saccadesize.data(8,c,:) = (saccadesize.data(6,c,:) - saccadesize.data(7,c,:)) ./ 2;
    
    end
   
    %% also get as function of trial length - identical as above, except for trial lengt
    saccade_lengthsplit = [];
    saccade_lengthsplit.dimord = 'chan_freq_time';
    saccade_lengthsplit.freq = unique(trial_lengths)'; % trial lengths, as if "frequency axis" for time-frequency plot
    saccade_lengthsplit.time = times;
    saccade_lengthsplit.label = saccade.label;

    c = 0;
    for tl = saccade_lengthsplit.freq;
        c = c+1;
        
        shiftsNE = [];
        shiftsNW = [];
        shiftsSE = [];
        shiftsSW = [];

        shiftsNE = double(shiftsX(trial_lengths == tl,:)>0 & shiftsY(trial_lengths == tl,:)>0);
        shiftsNW = double(shiftsX(trial_lengths == tl,:)<0 & shiftsY(trial_lengths == tl,:)>0);
        shiftsSE = double(shiftsX(trial_lengths == tl,:)>0 & shiftsY(trial_lengths == tl,:)<0);
        shiftsSW = double(shiftsX(trial_lengths == tl,:)<0 & shiftsY(trial_lengths == tl,:)<0);
        
        % NaN data after orientation change
        for trial = 1:length(trial_lengths)
            selection = times > trial_lengths(trial);
            shiftsNE(trial, selection) = NaN;
            shiftsNW(trial, selection) = NaN;
            shiftsSE(trial, selection) = NaN;
            shiftsSW(trial, selection) = NaN;
        end

        saccade_lengthsplit.data(1,c,:) = (mean(shiftsSW(cueL,:), "omitnan") + mean(shiftsSE(cueR,:), "omitnan")) ./ 2;
        saccade_lengthsplit.data(2,c,:) = (mean(shiftsNE(cueL,:), "omitnan") + mean(shiftsNW(cueR,:), "omitnan")) ./ 2;
        saccade_lengthsplit.data(3,c,:) = (mean(shiftsSW(cueR,:), "omitnan") + mean(shiftsSE(cueL,:), "omitnan")) ./ 2;
        saccade_lengthsplit.data(4,c,:) = (mean(shiftsNE(cueR,:), "omitnan") + mean(shiftsNW(cueL,:), "omitnan")) ./ 2;
        saccade_lengthsplit.data(5,c,:) = (saccade_lengthsplit.data(1,c,:) - saccade_lengthsplit.data(3,c,:)) ./ 2;
        
        % add aggregated fields
        saccade_lengthsplit.data(6,c,:) = (saccade_lengthsplit.data(1,c,:) + saccade_lengthsplit.data(2,c,:)) ./ 2;
        saccade_lengthsplit.data(7,c,:) = (saccade_lengthsplit.data(3,c,:) + saccade_lengthsplit.data(4,c,:)) ./ 2;
        saccade_lengthsplit.data(8,c,:) = (saccade_lengthsplit.data(6,c,:) - saccade_lengthsplit.data(7,c,:)) ./ 2;
    
    end

    %% smooth and turn to Hz
    integrationwindow = 100; % window over which to integrate saccade counts
   
    for i = 1:size(saccade.label, 2)
        saccadesize.data(i,:,:) = smoothdata(saccadesize.data(i,:,:), 3, 'movmean', integrationwindow)*1000;
        saccade_lengthsplit.data(i,:,:) = smoothdata(saccade_lengthsplit.data(i,:,:), 3, 'movmean', integrationwindow)*1000;
    end
    
    %% plot results
    if plotResults
        cfg = [];
        cfg.parameter = 'data';
        cfg.figure = 'gcf';
        cfg.zlim = 'maxabs';
        figure;
        for i = 1:size(saccade.label,2)
            subplot(2,4,i);
            cfg.channel = i;
            ft_singleplotTFR(cfg, saccadesize);
        end
        colormap('jet');
        drawnow;
    end

    %% save
    % depending on this option, append to name of saved file. 
    if nan_trial_overlap == 1
        toadd1 = '_NaNtrialoverlap';
    else
        toadd1 = '';
    end    

    if remove_unfixated == 1
        toadd2 = '_removeUnfixated';
    else
        toadd2 = '';
    end    

    if nan_post_target == 1
        toadd3 = '_NaNposttarget';
    else
        toadd3 = '';
    end

    if remove_prematures == 1
        toadd4 = '_removePremature';
    else
        toadd4 = '';
    end

    if only_over_1400 == 1
        toadd5 = '_onlyover1400';
    else
        toadd5 = '';
    end

    save([param.path, '\saved_data\saccadeEffects_4D', toadd1, toadd2, toadd3, toadd4, toadd5, '__', param.subjName], 'saccade', 'saccadedirection','saccadesize', 'saccade_lengthsplit');

    %% close loops
end % end pp loop

saccade_rate = saccades ./ trials(:,1);
saccade_rate_valid = saccades_valid ./ trials(:,2);
