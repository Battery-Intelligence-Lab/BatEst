function params = subfunctions(params)
% A function that is used to load any subfunctions required by the model.
% Find the relevant subfunctions in the Code/Models/MODEL/subfunctions
% folder and in Code/Common/Functions.

% Equilibrium potentials
[params.UnFun, params.UpFun] = electrode_potentials(params);

% Surface overpotentials
[params.etan, params.etap] = reaction_overpotentials(params);

% Turn off model plotting
params.plot_model = false;

end
