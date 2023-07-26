function params = set_parameters(j)
% This function creates a parameters structure containing the cell
% properties, code settings and model parameters for the chosen model.

if nargin==0
    j = [];
end

% Cell properties
params = cell_parameters(j);

% Set and rescale parameters
params = model_parameters(params,j);

% Code switches (true or false)
params = code_switches(params);

% Define polynomial splitting in terms of SOC if necessary
if params.polyapprox
    [params.xsplits, params.expected_charge_time] = SOC_split(params);
end

end
