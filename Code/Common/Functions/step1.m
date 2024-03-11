function [true_sol,params] = step1(Target,Model,params,j,Dataset)
% This step loads the data or simulates the model to generate data.

true_sol = [];

% Unpack model properties
[ModelName, Noise] = struct2array(Model,{'Name','Noise'});

% Check for data selection
if ~isfield(params, 'cycle_step'), params.cycle_step = []; end
if ~isfield(params, 'DataType'), params.DataType = ''; end

if istable(Dataset) && any(strcmp(Target,{'Simulate','Plot','Compare','Parameter'}))
    % Unpack the data
    true_sol = unpack_data(Dataset,params,j);
    true_sol.Type = 'True';
    
    % Update the parameters accordingly
    params = inform_params(params,ModelName,true_sol);
    
    % Set the protocol based on the data
    params = set_protocol(params,true_sol);
elseif any(strcmp(Target,{'Simulate','Parameter'}))
    % Set the protocol based on script
    params = set_protocol(params);
elseif strcmp(Target,'Control')
    % Do nothing
else
    error(['Check that Target is set to one of the available options ' ...
           'and/ or import a Dataset and pass it to the function by ' ...
           'entering main(Dataset); in the command window.']);
end

if strcmp(Target,'Simulate') || (~istable(Dataset) && strcmp(Target,'Parameter'))
    % Simulate the protocol
    true_sol = run_simulation(Model,params);
    true_sol.Type = 'True';
end

if isstruct(true_sol)
    % Plot any simulation
    params = plot_sol(true_sol,params);
    % Option to add measurement noise with a given standard deviation
    if Noise
        std = 0.01;
        true_sol.ysol = true_sol.ysol+std*randn(size(true_sol.ysol));
        params = plot_sol(true_sol,params);
    end
    % Save the output
    params.yy = true_sol.ysol;
    if params.verbose
        disp('Forward pass complete.');
    end
end
    
end
