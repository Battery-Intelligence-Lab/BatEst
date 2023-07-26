function params = add_bounds(params)
% A function to add upper and lower bounds to the initial parameter estimates.

% Unpack parameters
[c0, uncert] = struct2array(params, {'c0','uncert'});

% Add upper and lower bounds based on the uncertainty
ub = c0./(1-min(uncert,0.9));
lb = c0.*(1-min(uncert,1));

% Dimensional upper and lower bounds can be computed from:
% ub*fac and lb*fac, or 1/(lb*fac) and 1/(ub*fac) for reciprocal estimates,
% where fac = 2*guess.


%% Compile all parameters into the params structure
vars = setdiff(who,{'params','vars'});
for i=1:length(vars), params.(vars{i}) = eval(vars{i}); end


end
