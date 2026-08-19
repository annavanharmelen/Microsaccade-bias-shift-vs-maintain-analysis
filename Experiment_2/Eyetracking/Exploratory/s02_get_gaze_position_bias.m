%% Step2--Gaze position calculation

%% start clean
clear; clc; close all;

[data_path, figure_path] = setup(2);

%% parameters
for pp = [1:29];

nan_trial_overlap = 0;
nan_post_target = 1;

baselineCorrect     = 0; 
removeTrials        = 0; % remove trials where gaze deviation larger than value specified below. Only sensible after baseline correction!
max_eye_pos         = 2; % remove trials with x_position bigger than 2 degrees visual angle
remove_prematures   = 1;

plotResults         = 0;

%% load epoched data of this participant
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

param = get_subject_parameters_exp2(pp, data_path);
load([param.path, '\epoched_data\eyedata_exp2', toadd1, toadd2, '__', param.subjName], 'eyedata');

%% only keep channels of interest
cfg = [];
cfg.channel = {'eyeX','eyeY'}; % only keep x & y axis
eyedata = ft_selectdata(cfg, eyedata); % select x & y channels

%% reformat such that all data in single matrix of trial x channel x time
cfg = [];
cfg.keeptrials = 'yes';
tl = ft_timelockanalysis(cfg, eyedata); % realign the data: from trial*time cells into trial*channel*time?
tl.time = tl.time * 1000;

% dirty hack to get proxy for blink rate
tl.blink = squeeze(isnan(tl.trial(:,1,:))*100); % 0 where not nan, 1 where nan (putative blink, or eye close etc.)... *100 to get to percentage of trials where blink at that time

%% baseline correct?
if baselineCorrect
    tsel = tl.time >= -250 & tl.time <= 0; 
    bl = squeeze(mean(tl.trial(:,:,tsel),3));
    for t = 1:length(tl.time);
        tl.trial(:,:,t) = ((tl.trial(:,:,t) - bl));
    end
end

%% remove trials with gaze deviation >= 2 dva
chX = ismember(tl.label, 'eyeX');
chY = ismember(tl.label, 'eyeY');

if plotResults
figure;
plot(tl.time, squeeze(tl.trial(:,chX,:)));
title('all trials - full time range');
end

if removeTrials
    tsel = tl.time>= 0 & tl.time <=3200; % only check within this time range of interest
    
    figure;
    subplot(1,2,1);
    plot(tl.time(tsel), squeeze(tl.trial(:,chX,tsel)));
    title('before');
    
    for trl = 1:size(tl.trial,1)
        oktrial(trl) = sum(sqrt(abs(tl.trial(trl,chX,tsel)).^2 + abs(tl.trial(trl,chY,tsel)).^2  ) > max_eye_pos) ==0;
    end
    tl.trial = tl.trial(oktrial,:,:);
    tl.trialinfo = tl.trialinfo(oktrial,:);

    subplot(1,2,2);
    plot(tl.time(tsel), squeeze(tl.trial(:,chX,tsel)));
    title('after');
    proportionOK(pp) = mean(oktrial)*100;
    fprintf('%s has %.2f%% OK trials\n\n', param.subjName, mean(oktrial)*100)

end

%% selection vectors for conditions -- this is where it starts to become interesting!

% cued item location
targL = ismember(tl.trialinfo(:,1), [21,22,23,24]);
targR = ismember(tl.trialinfo(:,1), [25,26,27,28]);

captureL = ismember(tl.trialinfo(:,1), [22,24,25,27]);
captureR = ismember(tl.trialinfo(:,1), [21,23,26,28]);

% validity
valid = ismember(tl.trialinfo(:,1), [22,24,26,28]);
invalid = ismember(tl.trialinfo(:,1), [21,23,25,27]);
       

%% get relevant contrasts out
gaze = [];
gaze.time = tl.time;
gaze.label = {'all','valid','invalid','valid-invalid'};

for selection = [1:3] % conditions.
    if     selection == 1  sel = ones(size(valid))==1;
    elseif selection == 2  sel = valid;
    elseif selection == 3  sel = invalid;
    end
    gaze.dataL(selection,:) = squeeze(nanmean(tl.trial(sel&targL, chX,:)));
    gaze.dataR(selection,:) = squeeze(nanmean(tl.trial(sel&targR, chX,:)));
    gaze.blinkrate(selection,:) = squeeze(nanmean(tl.blink(sel, :)));
end

% add towardness field
gaze.towardness = (gaze.dataR - gaze.dataL) ./ 2;

% add valid vs. invalid (essentially: how much toward distractor)
gaze.dataL(end+1,:) = (gaze.dataL([2],:) - gaze.dataL([3],:)) ./ 2;
gaze.dataR(end+1,:) = (gaze.dataR([2],:) - gaze.dataR([3],:)) ./ 2;
gaze.towardness(end+1,:) = (gaze.towardness([2],:) - gaze.towardness([3],:)) ./ 2;
gaze.blinkrate(end+1,:) = (gaze.blinkrate([2],:) - gaze.blinkrate([3],:)) ./ 2;

%% plot
if plotResults
    figure;
    for sp = 1:4 subplot(2,3,sp);
        hold on;
        plot(gaze.time, gaze.dataR(sp,:), 'r');
        plot(gaze.time, gaze.dataL(sp,:), 'b');
        
        title(gaze.label(sp)); legend({'R','L'},'autoupdate', 'off');
        plot([0,0], ylim, '--k');plot([1500,1500], ylim, '--k');
    end

    figure;
    for sp = 1:4 subplot(2,3,sp);
        hold on;
        plot(gaze.time, gaze.towardness(sp,:), 'k');
        plot(xlim, [0,0], '--k');
        title(gaze.label(sp)); legend({'T'},'autoupdate', 'off');
        plot([0,0], ylim, '--k');
        plot([1500,1500], ylim, '--k');
    end

    figure;
    hold on;
    plot(gaze.time, gaze.towardness([1:4],:));
    plot(xlim, [0,0], '--k');
    legend(gaze.label([1:4]),'autoupdate', 'off');
    plot([0,0], ylim, '--k');plot([1500,1500], ylim, '--k'); 

    figure;
    hold on;
    plot(gaze.time, gaze.blinkrate([1:4],:)); plot(xlim, [0,0], '--k');
    legend(gaze.label([1:4]),'autoupdate', 'off'); plot([0,0], ylim, '--k');
    plot([1500,1500], ylim, '--k'); title('blinkrate');
end

%% save
if baselineCorrect == 1
    toadd1 = '_baselineCorrect';
else
    toadd1 = '';
end 

if nan_trial_overlap == 1
    toadd2 = '_NaNtrialoverlap';
else
    toadd2 = '';
end    

if removeTrials == 1
    toadd3 = '_removeUnfixated';
else
    toadd3 = '';
end    

if nan_post_target == 1
    toadd4 = '_NaNposttarget';
else
    toadd4 = '';
end

if remove_prematures == 1
    toadd5 = '_removePremature';
else
    toadd5 = '';
end


save([param.path, '\saved_data\gazePositionEffects', toadd1, toadd2, toadd3, toadd4, toadd5, '__', param.subjName], 'gaze');

drawnow; 

%% close loops
end % end pp loop
