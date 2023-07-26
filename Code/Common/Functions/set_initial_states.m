function params = set_initial_states(params,sol)
% A function to set the initial state(s) for the chosen model based either
% on the data or a previously computed value.

% Unpack initial states
X0 = params.X0;

% Determine the initial SOC estimate
if ~isfield(sol,'xsol')
    % Compute steady-state SOC from initial voltage
    [Vrng, Vcut] = struct2array(params, {'Vrng','Vcut'});
    SOC = initial_SOC(params,Vrng*sol.ysol(1,1)+Vcut,0.5);
    if length(X0)>1
        SOC = [SOC, SOC];
    end
elseif isnan(sol.xsol(1,1))
    % Do not overwrite input
    SOC = [];
else
    % Take initial SOC (and CSC) from data
    SOC = sol.xsol(1,1:min(length(X0),2));
end

% Set initial states according to model
X0 = update_states(params.X0,SOC,sol.ysol(1,:));

% Check that values lie with bounds
if any(X0.*(1-X0)<0)
    warning(['Estimated initial conditions are outside the bounds: ' ...
             num2str(X0') '. Try updating the OCV curve.']);
end

% Update initial states
params.X0 = X0;

end
