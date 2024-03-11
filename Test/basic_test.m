function tests = basic_test
% The main function which collects all of the local test functions into a
% test array. These tests simply check if the main functions run.
% Run these tests from the main repository folder using: run(basic_test)

tests = functiontests(localfunctions);

close all;

end

%% Tests for main_one taken from the GUIDE
function test_main_one(testCase)

% Test the main script
[out, params] = main_one;

% Repeat without plotting
params.plot_model = false;
params.plot_results = false;
[out, params] = main_one([],[],params);

end

function test_one_with_new_values(testCase)
close all;
reset_path;

% Inputs
Dataset = [];
out = [];
input_params.Qn = 5*3600;
% Also suggests updating u1 = @(t) t/t_end; in cell_protocol

% Settings
ModelName = 'EHMT';
Target = 'Simulate';
Estimator = 'PEM';
j = 0;

% Computation
fprintf('\nComputation started at %s\n', datetime("now"));
reset_path;
addpath(genpath(strcat('./Code/Models/',ModelName)));
addpath(genpath(strcat('./Code/Methods/',Estimator)));
input_params.fit_derivative = false; % true or false
[Model, params] = step0(ModelName,j,input_params);
Model.Noise = false; % true or false
[true_sol, params] = step1(Target,Model,params,j,Dataset);
[est_sol,  params] = step2(Target,Model,params,j);
[pred_sol, params] = step3(Target,Model,params,j,est_sol);
params = step4(Target,params,true_sol,pred_sol);
out = tabulate_output(params,out);

end

function test_one_with_dataset(testCase)
close all;
reset_path;

% Inputs
Dataset = import_parquet('Data/Examples/Raj2020_Cycling.parquet');
out = [];
input_params = [];

% Settings
ModelName = 'ROCV';
Target = 'Compare';
Estimator = 'PEM';
j = 0;

% Computation
fprintf('\nComputation started at %s\n', datetime("now"));
reset_path;
addpath(genpath(strcat('./Code/Models/',ModelName)));
addpath(genpath(strcat('./Code/Methods/',Estimator)));
input_params.fit_derivative = false; % true or false
[Model, params] = step0(ModelName,j,input_params);
Model.Noise = false; % true or false
[true_sol, params] = step1(Target,Model,params,j,Dataset);
[est_sol,  params] = step2(Target,Model,params,j);
[pred_sol, params] = step3(Target,Model,params,j,est_sol);
params = step4(Target,params,true_sol,pred_sol);
out = tabulate_output(params,out);

end

function test_one_with_fitting(testCase)
close all;
reset_path;

% Inputs
Dataset = import_parquet('Data/Examples/Raj2020_Cycling.parquet');
out = [];
input_params = [];

% Settings
ModelName = 'ROCV';
Target = 'Parameter';
Estimator = 'PEM';
j = 0;

% Computation
fprintf('\nComputation started at %s\n', datetime("now"));
reset_path;
addpath(genpath(strcat('./Code/Models/',ModelName)));
addpath(genpath(strcat('./Code/Methods/',Estimator)));
input_params.fit_derivative = false; % true or false
[Model, params] = step0(ModelName,j,input_params);
Model.Noise = false; % true or false
[true_sol, params] = step1(Target,Model,params,j,Dataset);
[est_sol,  params] = step2(Target,Model,params,j);
[pred_sol, params] = step3(Target,Model,params,j,est_sol);
params = step4(Target,params,true_sol,pred_sol);
out = tabulate_output(params,out);

end

function test_one_with_noise(testCase)
close all;
reset_path;

% Inputs
Dataset = import_parquet('Data/Examples/Raj2020_Cycling.parquet');
out = [];
input_params = [];

% Settings
ModelName = 'ROCV';
Target = 'Parameter';
Estimator = 'PEM';
j = 0;

% Suggests changing the uncertainties in set_model

% Computation
fprintf('\nComputation started at %s\n', datetime("now"));
reset_path;
addpath(genpath(strcat('./Code/Models/',ModelName)));
addpath(genpath(strcat('./Code/Methods/',Estimator)));
input_params.fit_derivative = false; % true or false
[Model, params] = step0(ModelName,j,input_params);
Model.Noise = true; % true or false
[true_sol, params] = step1(Target,Model,params,j,Dataset);
[est_sol,  params] = step2(Target,Model,params,j);
[pred_sol, params] = step3(Target,Model,params,j,est_sol);
params = step4(Target,params,true_sol,pred_sol);
out = tabulate_output(params,out);

end

%% Tests for main_multi taken from the GUIDE
function test_main_multi(testCase)

% Test the main script
main_multi;

end

function test_multi_with_EHM(testCase)
close all;
reset_path;

Dataset = [];
out = [];
input_params = [];

% Iterations
index_name = 'Data/Examples/Test_Index.parquet';
index = parquetread(index_name);
n = 3;
params = input_params;
file_index = find(index.Cell_Number==n & index.Performance_Test);
filenames = index.File_Name(file_index(:));
subfolder = index.Folder_Name(file_index(:));
k = 1;
rep_num = 1:3;
for j = rep_num

% Settings
if j==1
    ModelName = 'OCV';
    Target = 'Parameter';
    Estimator = 'PEM';
    Dataset = import_parquet([subfolder{j} '/' filenames{j}]);
elseif j==2
    ModelName = 'EHM';
end

% Computation
fprintf('\nComputation started at %s\n', datetime("now"));
reset_path;
addpath(genpath(strcat('./Code/Models/',ModelName)));
addpath(genpath(strcat('./Code/Methods/',Estimator)));
params.fit_derivative = false; % true or false
[Model, params] = step0(ModelName,j,params);
Model.Noise = false; % true or false
[params.cycle_step, params.DataType] = data_selection(j);
[true_sol, params] = step1(Target,Model,params,j,Dataset);
[est_sol,  params] = step2(Target,Model,params,j);
[pred_sol, params] = step3(Target,Model,params,j,est_sol);
params = step4(Target,params,true_sol,pred_sol);
out = tabulate_output(params,out);

end

end
