function [data_path, figure_path] = setup(experiment)
% SETUP.M - This function is called before executing analyses
%   This function sets up a few different necessary things:
%   1. Checks whether the correct toolboxes are installed and setup
%   2. Contains the path to the data folder
%   3. Contains the path to the figure folder
%   4. Creates the output folders that are required (if they don't exist)
%   5. Adds the required folders to your matlab path

%% 1. Check whether the correct toolboxes are installed and setup
try
    ft_defaults;
catch
    warning("Fieldtrip is not installed, check the README for installation instructions.")
end

if ~license('test', 'statistics_toolbox')
    warning('The "Statistics and Machine Learning Toolbox" is not installed, please install it.');
end

%% 2. Add path to the data folder here:
main_data_path = '...';
experiment_paths = ["Experiment 1", "Experiment 2"];

if strcmp(experiment, "joint")
    data_path = [fullfile(main_data_path, experiment_paths(1)), fullfile(main_data_path, experiment_paths(2))];
else
    data_path = fullfile(main_data_path, char(experiment_paths(experiment)));
end


%% 3. Add path to the figure folder here:
figure_path = '...';

%% 4. Creates the output folders that are required (if they don't exist)
subfolders_needed = ["epoched_data", "saved_data"];

for subfolder = subfolders_needed
    
    % Combine all parts into single valid folder path
    target_path = fullfile(data_path, subfolder);

    % Check whether it exists and create if missing
    if ~isfolder(target_path)
        mkdir(target_path);
    end
end

%% 5. Add the required folders to your matlab path
% Lib has to be added in any case
addpath("lib")

% Add currently wanted folder to path
if strcmp(experiment, "joint")
    current_folder = "Joint_experiment_1_and_2";

else
    current_folder = sprintf("Experiment_%d", experiment);
end
addpath(genpath(current_folder));

% Remove all other folders from path, if they were on there
all_folders = ["Experiment_1", "Experiment_2", "Joint_experiment_1_and_2"];
other_folders = all_folders(all_folders ~= current_folder);
for folder = other_folders
    if contains(path, folder)
        rmpath(genpath(folder));
    end
end

end
