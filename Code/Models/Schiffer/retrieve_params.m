function params = retrieve_params(params,sol)
% A function to estimate new physical parameters from the lumped parameter
% estimates.

% Load constant parameters
[hr, fac] = struct2array(params, {'hr','fac'});

% Unpack parameter estimates
if isstruct(sol)
    c0 = mean(sol.psol)';
else
    c0 = sol(end,1:length(params.c0))';
end
p = num2cell(c0.*fac);
[rQ, Rs] = deal(p{:});

% Update model parameters accordingly
Q = 1/rQ;

% Update initial states
if isstruct(sol)
    S0 = sol.xsol(1,1);
    X0 = sol.xsol(1,:)';
else
    S0 = sol(end,2*length(c0)+1);
    X0 = sol(end,2*length(c0)+(1))';
end

if isstruct(sol)
    % Save dimensional parameters
    pdim = [Q, Rs];
    
    % Display new parameters
    disp(['Q = ' num2str(Q/hr) '*hr; % cell capacity (As)']);
    disp(['Rs = ' num2str(Rs) ';']);

    % Display initial states
    disp(['S0 = ' num2str(S0) ';']);
end


%% Compile all parameters into the params structure
vars = setdiff(who,{'params','vars','sol'});
for i=1:length(vars), params.(vars{i}) = eval(vars{i}); end


end
