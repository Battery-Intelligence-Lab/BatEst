function [Model, params] = step0(ModelName,j,new_params)
% This step defines the settings, parameters and model functions.

% Define the parameters
params = set_parameters(j);

% If there is an input structure, overwrite with new parameters
if isstruct(new_params)
    params = convert_params(params,new_params);
end

% Define subfunctions
params = subfunctions(params);

% Define the model
[Model, params] = set_model(ModelName,params,j);

end
