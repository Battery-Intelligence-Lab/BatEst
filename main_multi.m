function [out, params] = main_multi(Dataset,out,input_params)
% This is the main script to run multiple iterations, try main_one.m first.
% The inputs and outputs are optional.

close all;
reset_path;

% To create a Dataset use: Dataset = importParquet('XXX.csv');
% Dataset = parquetread('Code/Common/Import/ExampleDataset.parquet');
if ~exist('Dataset','var'), Dataset = []; end

% To append the output from a previous estimation, use the input out.
if ~exist('out','var'), out = []; end

% To pass the parameters from a previous estimation, use the input params.
% To generate a parameters structure, use: params = load_output(out);
if ~exist('input_params','var'), input_params = []; end


%% Iterations
% Load index of measurement data to access multiple files
index_name = 'Data/Examples/Test_Index.parquet';
index = parquetread(index_name);

% Set the cell number(s)
cell_num = [3];
for n = cell_num

% Reset the parameters for each cell
params = input_params;

% Select files from the index
file_index = find(index.Cell_Number==n & index.Performance_Test);
filenames = index.File_Name(file_index(:));
subfolder = index.Folder_Name(file_index(:));
for k = 1:length(filenames)

% Reset the parameters for each test
params = input_params;

% Set the section number(s) or number of repetitions
rep_num = 1:3;
for j = rep_num


%% Setup
% The following settings must be defined.
% ModelName: choose from the available Models (OCV, RORC, EHMT, etc.)
% Target: choose from Simulate, Plot, Compare or Parameter
% Estimator: choose from the available Methods (Fmincon, PEM)

if j==1
    % Settings
    ModelName = 'OCV';
    Target = 'Parameter';
    Estimator = 'PEM';
    Dataset = import_parquet([subfolder{j} '/' filenames{j}]);
elseif j==2
    ModelName = 'RORC';
end


%% Start
fprintf('\nComputation started at %s\n', datetime("now"));

% Add relevant paths
reset_path;
addpath(genpath(strcat('./Code/Models/',ModelName)));
addpath(genpath(strcat('./Code/Methods/',Estimator)));

% Define dimensionless model
[Model, params] = step0(ModelName,j,params);
Model.Noise = false; % true or false

% Load or generate data
[true_sol, params] = step1(Target,Model,params,j,Dataset);

% Perform estimation and update parameter values
[est_sol,  params] = step2(Target,Model,params,j);

% Run simulation using updated parameters
[pred_sol, params] = step3(Target,Model,params,j,est_sol);

% Compare prediction and data
params = step4(Target,params,true_sol,pred_sol);


%% Save
% Only need to save the updated parameters structure as plots
% can be re-generated using Simulate or Compare.

% Convert and save the parameters in a table
out = tabulate_output(params,out);

% Save output and current figure (true = overwrite by default)
save_output(out,['Data/out_' ModelName '_' num2str(n) '_' num2str(k)],true);
% save_plot(gcf,['Data/plot_' ModelName '_' num2str(n) '_' num2str(k)],true);


end
end
end

end

