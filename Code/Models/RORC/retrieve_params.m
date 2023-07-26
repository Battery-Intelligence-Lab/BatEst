function params = retrieve_params(params,sol)
% A function to compute new parameters from the parameter estimates.

% Load constant parameters
[Qn, hr, Vrng, fac, verbose] = ...
    struct2array(params, {'Qn','hr','Vrng','fac','verbose'});

% Unpack parameter estimates
if isstruct(sol)
    c0 = mean(sol.psol)';
else
    c0 = sol(end,1:length(params.c0))';
end
p = num2cell(c0.*fac);
[rQ, rtau, rCV, Rs, nu, miu] = deal(p{:});

% Update reciprocal parameters
Q = 1/rQ;
CE = Qn/Q;
tau1 = 1/rtau;
C1 = 1/(rCV*Vrng);

% Update initial states
if isstruct(sol)
    S0 = sol.xsol(1,1);
    X0 = sol.xsol(1,:)';
else
    S0 = sol(end,2*length(c0)+1);
    X0 = sol(end,2*length(c0)+(1:2))';
end

if verbose && isstruct(sol)
    % Display the parameters
    disp(['Qn = ' num2str(Qn/hr) '*hr; % negative electrode capacity (As)']);
    disp(['nu = ' num2str(nu) ';       % negative-positive electrode capacity ratio (non-dim.)']);
    disp(['miu = ' num2str(miu) ';     % cyclable lithium-positive electrode capacity ratio (non-dim.)']);
    disp(['Rs = ' num2str(Rs) ';       % series resistance (Ohm)']);
    disp(['tau = ' num2str(tau1) ';    % time constant of the RC pair [= R1*C1] (s)']);
    disp(['C1 = ' num2str(C1) ';       % capacitance of the RC pair (F)']);
    disp( ' '); disp('% Update capacity');
    disp(['CE = ' num2str(CE) ';       % coulombic efficiency (non-dim.)']);
    
    % Display initial states
    disp(['S0 = ' num2str(S0) ';']);
end


%% Compile all parameters into the params structure
vars = setdiff(who,{'params','vars','sol'});
for i=1:length(vars), params.(vars{i}) = eval(vars{i}); end


end
