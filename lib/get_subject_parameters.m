function param = get_subject_parameters(experiment, pp, data_path)

%% participant-specific notes

%% set path and pp-specific file locations
param.path = append(data_path, '\');

if pp < 10
    param.subjName = sprintf('pp0%d', pp);
else
    param.subjName = sprintf('pp%d', pp);
end

log_string = sprintf('exp%d_beh_%d.csv', experiment, pp);
param.log = [param.path, log_string];

eds_string = sprintf('exp%d_eye_%d.asc', experiment, pp);
param.eds = [param.path, eds_string];
