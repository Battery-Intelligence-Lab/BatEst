function params = set_initial_states(params,sol)
% A function to set the initial state(s) for the chosen model based either
% on the data or a previously computed value.

% Unpack initial states
X0 = params.X0;

% Check and complete init structure
if nargin==2 && isfield(sol,'init')
    init = sol.init;
else
    init = struct();
end
if ~isfield(init,'X')
    if isfield(params,'S0')
        init.X = params.S0;
    else
        % Compute steady-state SOC from initial voltage
        [Vrng, Vcut] = struct2array(params, {'Vrng','Vcut'});
        init.X = initial_SOC(params,Vrng*sol.ysol(1,1)+Vcut,0.5);
    end
end
if ~isfield(init,'S')
    init.S = init.X;
end
if ~isfield(init,'T')
    init.T = 0;
end

% Set initial states according to model
X0 = update_states(X0,init);

% Check that values lie with bounds
if any(X0.*(1-X0)<0)
    warning(['Estimated initial conditions are outside the bounds: ' ...
             num2str(X0') '. Try updating the OCV curve.']);
end

% Update initial states
params.X0 = X0;

end
