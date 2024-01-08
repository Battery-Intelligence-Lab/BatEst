function params = retrieve_params(params,sol)
% A function to compute new parameters from the parameter estimates.

% Load constant parameters
[hr, fac, verbose] = struct2array(params, {'hr','fac','verbose'});

% Unpack parameter estimates
if isstruct(sol)
    c0 = mean(sol.psol)';
else
    c0 = sol(end,1:length(params.c0))';
end
p = num2cell(c0.*fac);
[rQ, nu, miu] = deal(p{:});

% Update reciprocal parameters
Q = 1/rQ;
Qn = Q;

% Update initial states
if isstruct(sol)
    S0 = sol.xsol(1,1);
    X0 = sol.xsol(1,:)';
else
    S0 = sol(end,2*length(c0)+1);
    X0 = sol(end,2*length(c0)+(1))';
end

if verbose && isstruct(sol)
    % Display the parameters
    disp([pad(['Qn = ' num2str(Qn/hr) '*hr;'], 21) '% negative electrode capacity (As)']);
    disp([pad(['nu = ' num2str(nu) ';'], 21)       '% negative/positive electrode capacity ratio (non-dim.)']);
    disp([pad(['miu = ' num2str(miu) ';'], 21)     '% cyclable lithium/positive electrode capacity ratio (non-dim.)']);
    
    % Display initial states
    disp([pad(['S0 = ' num2str(S0) ';'], 21)       '% initial SOC']);
end


%% Compile all parameters into the params structure
vars = setdiff(who,{'params','vars','sol'});
for i=1:length(vars), params.(vars{i}) = eval(vars{i}); end


end
