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

% Restart from an existing output
if isempty(out)
    n_restart = 1;
    k_restart = 1;
else
    if isempty(input_params), params = load_output(out); end
    n_restart = out.Cell_Number(end);
    k_restart = out.Test_Number(end)+1;
end


%% Iterations
% Load index of measurement data to access multiple files
% index_filename = 'Data/test_index.parquet';
folder = 'Data/ULB/Final Dataset/';
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
for n = cell_num(cell_num>=n_restart)

% Find files and folders for this cell
filenumbers = find(index.Cell_Number'==single(n));
filenumber1 = filenumbers(1);
for k = filenumbers(filenumbers>=k_restart)

% Reset the parameters for each cell
if k==filenumber1, out = []; params = input_params; end

if any(k==[149,211,435])
    warning(['Skipping ' num2str(k) '...']);
    continue;
end

foldername = char(index.Folder_Name(k));
filename = char(index.File_Name(k));
cycle = 1; take_one = true;

while cycle < 12


%% Setup
% The following settings must be defined.
% ModelName: choose from the available Models (OCV, RORC, EHMT, etc.)
% Target: choose from Simulate, Plot, Compare or Parameter
% Estimator: choose from the available Methods (Fmincon, PEM)

% Settings
Target = 'Parameter';
Estimator = 'PEM';

if index.OCV_Test(k)==true
    % Fit the pseudo OCV
    j = [1;3]; % cycle_step
    ModelName = 'OCV';
    disp('Loading OCV charge data.')
    Dataset = import_parquet([folder '/' foldername '/' filename '.parquet']);

% elseif index.Performance_Test(k)==true
% Step 5 for 1C CCCV charge, 11 for C/2 CCCV charge and 10 for Relaxation
%     % Fit the thermal parameters --- do not fit, just use mean values
%     j = [1; 5]; % cycle_step
%     ModelName = 'OCVT';
%     disp('Loading performance data.')
%     Dataset = import_parquet([folder '/' foldername '/' filename '.parquet']);
%     continue;

elseif index.Cycling_Test(k)==true && take_one
    % Fit the diffusion timescale using rest after discharge
    if any(n==[3,3.2,3.3,20])        % 1C CCCV
        j = [cycle; 9];
    elseif any(n==[4,4.2,4.3])       % 2C CCCV
        j = [cycle; 10];
    elseif any(n==[11,11.2,21,21.2]) % C/2 CCCV
        j = [cycle; 10];
    else                             % NCCV
        j = [cycle; 11];
    end
    ModelName = 'EHMT';
    disp('Loading dynamic data.')
    Dataset = import_parquet([folder '/' foldername '/' filename '.parquet']);

elseif index.Cycling_Test(k)==true
    % Fit the dynamics and film resistance
    if any(n==[3,3.2,3.3,20])        % 1C CCCV
        j = [cycle; 6];
    elseif any(n==[4,4.2,4.3])       % 2C CCCV
        j = [cycle; 7];
    elseif any(n==[11,11.2,21,21.2]) % C/2 CCCV
        j = [cycle; 7];
    else                             % NCCV
        j = [cycle; 7; 8];
    end

else
    cycle = 12;
    continue;
end


%% Start
fprintf('\nComputation started at %s\n', datetime("now"));

% Add relevant paths
reset_path;
addpath(genpath(strcat('./Code/Models/',ModelName)));
addpath(genpath(strcat('./Code/Methods/',Estimator)));
addpath(genpath(strcat('./Data/ULB')));

% Define dimensionless model
params.fit_derivative = false; % true or false
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
if strcmp(Target,'Parameter')
    if ~isfolder(['Data/ULB/Cell' num2str(n)]), mkdir(['Data/ULB/Cell' num2str(n)]); end
    if j==3
        save_output(out,['Data/ULB/Cell' num2str(n) '/out_' ModelName '0_' num2str(k) '_' num2str(cycle)],true);
        save_plot(gcf,['Data/ULB/Cell' num2str(n) '/plot_' ModelName '0_' num2str(k) '_' num2str(cycle)],true);
    else
        save_output(out,['Data/ULB/Cell' num2str(n) '/out_' ModelName '_' num2str(k) '_' num2str(cycle)],true);
        save_plot(gcf,['Data/ULB/Cell' num2str(n) '/plot_' ModelName '_' num2str(k) '_' num2str(cycle)],true);
    end
end

if any(k==[159,160]) && cycle==4
    warning('Only 4 cycles in 159 and 160...');
    cycle = 12;
end

if index.OCV_Test(k)==true
    cycle = 12;
% elseif index.Performance_Test(k)==true
elseif index.Cycling_Test(k)==true && take_one
    take_one = false;
elseif index.Cycling_Test(k)==true && cycle==11
    take_one = true; cycle = 12;
elseif index.Cycling_Test(k)==true
    cycle = cycle+1;
end

end
end
end

end

