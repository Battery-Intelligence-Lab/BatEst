function params = code_switches(params)
% The function which sets the true/false switches in the code.

% Choose whether to display warnings and parameters in the command window
verbose = true;

% Choose whether to plot the results and/or the model functions
plot_results = true;
plot_model = true;

% Choose whether to approximate the model functions as polynomials
polyapprox = false;


%% Compile all parameters into the params structure
vars = setdiff(who,{'params','vars'});
for i=1:length(vars), params.(vars{i}) = eval(vars{i}); end


end
