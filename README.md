# Microsaccade bias shift vs. maintain analysis
> This code relates to the published paper: [Microsaccades track shifting but not necessarily maintaining covert visual-spatial attention](https://elifesciences.org/reviewed-preprints/108798).  
> The data are [freely available here](...).  

Analysis scripts (in MATLAB) for the data acquired from the microsaccade bias shift vs. maintain experiment (in Python).

The experiment code for both experiments can be found in: [Microsaccade-bias-shift-vs-maintain](https://github.com/annavanharmelen/Microsaccade-bias-shift-vs-maintain-experiment).
This analysis code analyses the data from both [Experiment 1](https://github.com/annavanharmelen/Microsaccade-bias-shift-vs-maintain-experiment/tree/main) and [Experiment 2](https://github.com/annavanharmelen/Microsaccade-bias-shift-vs-maintain-experiment/tree/live-gaze-checking).

## Author
Made by Anna van Harmelen in 2023 (last updated in August 2026), with scripts from Dr. Freek van Ede.

## Installation
Some of these analysis scripts are dependent on the [Fieldtrip toolbox](https://www.fieldtriptoolbox.org), and were originally built using the [2020.10.23 version of Fieldtrip](https://download.fieldtriptoolbox.org/historical/).
The analysis code was run in MATLAB version R2024b. If you don't have a MATLAB license, consider trying the open-source alternative [GNU Octave](https://octave.org/).

## Configuration
To make sure the scripts run correctly, open the get_subject_parameters.m file to either...:
- Enter the randomised participant numbers (in order of session number), if your filing system is the same as mine.
- Change the code, so this function can find the data corresponding to each participant.

## Running
### Naming and structure
- The analysis runs in multiple parts.
- The main analyses are performed by following the main number sequence: s01 &rarr; s02 &rarr; s03 &rarr; s04.
    - Files are named in the order that the analysis should be run, where "s01" is step 1, "s02" step 2, etc.
    - Additional analyses can be done and are denoted as an alternative next step, e.g. "s02a".
- Some analysis scripts depend on running another script first.
    - These dependencies are always given at the top of a script in a block comment.
- The 'lib' folder contains helper functions that are required for many of the analysis scripts.
- `setup.m` handles a few important things, like paths, without it scripts generally won't work.

### Running
1. Simply open the code repository in MATLAB (either download it, or clone it)
2. Open the script you want to run and try to run it.
3. MATLAB will prompt you to say that the script is not in the current path. Select 'Add to path'.  
    (All other functions and folders that need to be added or removed from the path are handled by `setup.m`.)
4. That's it! 🎉

### Recreating figures from the paper
All figures show the data from Experiment 1 and Experiment 2 side-by-side, so the following scripts must be run once for Experiment 1 and once for Experiment 2:
- **Figure 1**: s01_get_behaviour.m, with statistics done in s02_behaviour_stats.m 
- **Figure 2**:
    - **A** and **C**: s03_GA_saccade_bias.m
    - **B**: s04_saccade_bias_stats.m
- **Figure 3**: s03_GA_saccade_bias.m
- **Figure S2**: same panels as Figure 2 but with `only_over_1400` set to 0 and `xlimtoplot` set to [-100 3100]
- **Figure S3**: s03_GA_saccade_bias.m
- **Figure S4**:
    - **top**: s03_GA_saccade_bias.m
    - **bottom**: s04_saccade_bias_stats.m
- **Figure S5**: s01_supp_figS5_behaviour_saccade_correlation.m
- **Figure S6**: s02a_supp_figS6_get_gaze_heatmaps
- **Figure S7**: s03a_supp_figS7_main_sequence.m
- **Figure S8**:
    - **top**: s03_GA_saccade_bias.m
    - **bottom**: s04_saccade_bias_stats.m
- **Table S1**: s02_behaviour_stats.m 
- **Table S2**: s02_get_saccade_bias.m

### Script parameters
The scripts contain quite a few options that you can change under "parameters", depending on how you want the script to run.
This repository *should* contain the settings as they were used for the original publication, but just in case, this is an overview of the settings that were used: 

| setting           | Experiment 1                          | Experiment 2                              |
| ----------------- |                :----:                 |                  :----:                   |
| nan_trial_overlap | OFF, nan_post_target cuts off more    | OFF, nan_post_target cuts off more        |
| nan_post_target   | ON                                    | ON                                        |
| remove_unfixated  | OFF                                   | ON                                        |
| remove_prematures | ON                                    | ON                                        |
| only_over_1400    | ON                                    | ON                                        |
| only_under_1dva   | OFF                                   | N.A., gaze control built into experiment  |
| nsmooth           | set to 200                            | set to 200                                | 
