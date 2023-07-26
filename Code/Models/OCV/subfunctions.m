function params = subfunctions(params)
% A function that is used to load any subfunctions required by the model.
% Find the relevant subfunctions in the Code/Models/MODEL/subfunctions
% folder and in Code/Common/Functions.

% OCV function
params.OCV = OCV_function(params);

% Turn off model plotting
params.plot_model = false;

end
