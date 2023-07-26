function params = plot_sol(sol,params)
% A function to plot the results.

if params.plot_results

% Rescale and plot the variables
params = default_plotting(sol,params);

subplot(2,2,4);
plot(sol.tsol/params.mn,sol.xsol(:,2));
xlabel('Time (min)');
ylabel('Hysteresis state');

drawnow;
end

end
