function params = plot_sol(sol,params)
% A function to plot the results.

if params.plot_results

% Rescale and plot the variables
params = default_plotting(sol,params);

drawnow;
end

end
