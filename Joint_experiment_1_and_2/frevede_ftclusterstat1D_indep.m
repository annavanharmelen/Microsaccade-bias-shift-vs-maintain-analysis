function stat = frevede_ftclusterstat1D_indep(statcfg, data_cond1, data_cond2);
% needs:
% statcfg.xax = xxx.time;
% statcfg.npermutations = 1000;
% statcfg.clusterStatEvalaluationAlpha = 0.05;
% statcfg.nsub = s;
% statcfg.statMethod = 'montecarlo';  / statcfg.statMethod = 'analytic';
% data_cond1 % paticipants x time
% data_cond2 % paticipants x time - if one condition against 0, enter as: data_cond2 = zeros(size(data_cond1));
% % assumes depsamples
% put into fieldtrip format
dummy = []; x = []; y = [];
dummy.time = statcfg.xax;
dummy.label = {'contrastofinterest'};
dummy.dimord = 'chan_time';
for s1 = 1:statcfg.nsub1
    x{s1} = dummy; x{s1}.avg(1,:) = squeeze(data_cond1(s1,:)); % 1  structure per participant.
end
for s2 = 1:statcfg.nsub2
    y{s2} = dummy; y{s2}.avg(1,:) = squeeze(data_cond2(s2,:)); % 1  structure per participant.
end
% run cluster stat
cfg = [];
cfg.method = statcfg.statMethod;
cfg.numrandomization = statcfg.npermutations;
if strcmp(cfg.method, 'montecarlo'); cfg.correctm='cluster'; else cfg.correctm = 'no'; end
cfg.clusteralpha     = 0.05;
cfg.alpha            = statcfg.clusterStatEvalaluationAlpha;
cfg.tail             = 0;
cfg.design           = [ones(1,s1), ones(1,s2)*2]; % specifies which dataset belongs to which participant and which condition (effect or zeros)
cfg.ivar             = 1;
cfg.statistic        = 'indepsamplesT';
cfg.neighbours       = [];
stat = ft_timelockstatistics(cfg, x{:},y{:});
end
% plot mask as horizontal line using e.g.
%mask_xxx = double(stat.mask); mask_xxx(mask_xxx==0) = nan; % nan data that is not part of mark
% plot(timevector, mask_xxx*verticaloffset, 'k', 'LineWidth', 2); % verticaloffset for positioning of the "significance line"