function params = subfunctions(params)
% A function that is used to load any subfunctions required by the model.
% Find the relevant subfunctions in the Code/Models/MODEL/subfunctions
% folder and in Code/Common/Functions.

% OCV function
params.OCV = OCV_function(params);

% Define the reciprocal of the differential capacity
params.Cr = @(soc) 1;

% Define the hysteresis function
params.H = @(soc) 0.1;

% Turn off model plotting
params.plot_model = false;

end
