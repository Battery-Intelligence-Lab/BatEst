function [out, params] = ULB_main(Dataset,out,input_params)
% This is the main script. The inputs and outputs are optional.

close all;
reset_path;
addpath(genpath(strcat('./Data/ULB')));

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
% index_filename = 'Data/test_index.parquet';
folder = '../../../Data from Brussels/Final Dataset/';
index_filename = 'Test_Index.parquet';
index = parquetread([folder index_filename]);

% Only a small subset of tests have reliable temperature data:
% cell_num = [3,3.2,4,4.2,4.3,5,6,7,8,11]; % test 1 with temp data
% cell_num = [3,3.2,3.3,7,9,9.2,11,11.2]; % test 2 with temp data
% cell_num = [3,3.2,7,9,11,11.2]; % test 3 with temp data
% cell_num = [3,3.3,11.2]; % test 4 with temp data
% So let's use constant tauT and tauA based on the mean OCVT results.

% Set the cell number(s)
cell_num = [3,3.2,3.3,4,4.2,4.3,5,6,7,8,9,9.2,10,10.2,11,11.2,20,21,21.2,22];
for n = cell_num

OCV_index = find(index.Cell_Number==single(n) & index.OCV_Test);
Performance_index = find(index.Cell_Number==single(n) & index.Performance_Test);
% Select only Performance tests that occur alongside an OCV test
Performance_index = Performance_index([1,7:5:end]);
file_index = [OCV_index, Performance_index(1:length(OCV_index))]';
filenames = index.File_Name(file_index(:));
subfolder = index.Folder_Name(file_index(:));
for k = 1:length(filenames)/2

% Reset the parameters for each test
params = input_params; out = [];

% Set the section number(s) or number of repetitions
rep_num = 1:4;
for j = rep_num


%% Setup
% The following settings must be defined.
% ModelName: choose from the available Models (OCV, RORC, EHMT, etc.)
% Target: choose from Simulate, Plot, Compare or Parameter
% Estimator: choose from the available Methods (Fmincon, PEM)

% Settings
if j==1
    Target = 'Parameter';
    Estimator = 'PEM';

    % Fit the stoichiometry bounds if not already done
    ModelName = 'OCV';
    try
        out = parquetread(['Data/ULB/out_' ModelName '_' num2str(n) '_' num2str(k) '.parquet']);
        params = load_output(out);
        continue;
    catch
        disp('Loading OCV charge data.')
        Dataset = import_parquet([folder '/' subfolder{2*k-1} '/' filenames{2*k-1} '.parquet']);
    end
elseif j==2
    % Fit the thermal parameters --- do not fit, just use mean values
    ModelName = 'OCVT';
    disp('Loading dynamic data.')
    Dataset = import_parquet([folder '/' subfolder{2*k} '/' filenames{2*k} '.parquet']);
    continue;
elseif j==3
    % Fit the diffusion timescale
    ModelName = 'EHMT';
    try
        out = parquetread(['Data/ULB/out_' ModelName '0_' num2str(n) '_' num2str(k) '.parquet']);
        params = load_output(out);
        continue;
    catch
    end
elseif j>3
    % Fit the dynamics and film resistance
end


%% Start
fprintf('\nComputation started at %s\n', datetime("now"));

% Add relevant paths
reset_path;
addpath(genpath(strcat('./Code/Models/',ModelName)));
addpath(genpath(strcat('./Code/Methods/',Estimator)));
addpath(genpath(strcat('./Data/ULB')));

% Define dimensionless model
params.fit_derivative = true; % true or false
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
out = tabulate_output(params,out,n,k);

% Save output and current figure (true = overwrite by default)
if j==3
    save_output(out,['Data/ULB/out_' ModelName '0_' num2str(n) '_' num2str(k)],true);
    save_plot(gcf,['Data/ULB/plot_' ModelName '0_' num2str(n) '_' num2str(k)],true);
else
    save_output(out,['Data/ULB/out_' ModelName '_' num2str(n) '_' num2str(k)],true);
    save_plot(gcf,['Data/ULB/plot_' ModelName '_' num2str(n) '_' num2str(k)],true);
end


end
end
end

end

