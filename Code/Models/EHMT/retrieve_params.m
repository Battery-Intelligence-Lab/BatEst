function params = retrieve_params(params,sol)
% A function to compute new parameters from the parameter estimates.

% Unpack parameters that are assumed constant
[Qn, hr, fac, verbose] = ...
    struct2array(params, {'Qn','hr','fac','verbose'});

% Unpack parameter estimates
if isstruct(sol)
    c0 = mean(sol.psol)';
else
    c0 = sol(end,1:length(params.c0))';
end
p = num2cell(c0.*fac);
[rQ, rtau_ref, rb, rIp_ref, rIn_ref, nu, miu, Rf, rCp, rCps, rtauT, rtauA] = deal(p{:});

% Update reciprocal parameters
Q = 1/rQ;
CE = Qn/Q;
Cp = 1/rCp;
Cps = Cp/rCps;
tauT = 1/rtauT;
tauA = 1/rtauA;
tau_ref = 1/rtau_ref;
b = 1/rb;
Ip_ref = 1/rIp_ref;
In_ref = 1/rIn_ref;

% Update initial states
if isstruct(sol)
    S0 = sol.xsol(1,1);
    T0 = sol.xsol(1,4);
    X0 = sol.xsol(1,:)';
else
    S0 = sol(end,2*length(c0)+1);
    T0 = sol(end,2*length(c0)+3);
    X0 = sol(end,2*length(c0)+(1:4))';
end

if verbose && isstruct(sol)
    % Display new parameters
    disp(['Qn = ' num2str(Qn/hr) '*hr;     % negative electrode capacity (As)']);
    disp(['nu = ' num2str(nu) ';           % negative-positive electrode capacity ratio (non-dim.)']);
    disp(['miu = ' num2str(miu) ';         % cyclable lithium-positive electrode capacity ratio (non-dim.)']);
    disp(['Cp = ' num2str(Cp) ';           % heat capacity of the core (J K-1)']);
    disp(['Cps = ' num2str(Cps) ';         % heat capacity of the surface (J K-1)']);
    disp(['tauT = ' num2str(tauT) ';       % internal heat transfer timescale (s)']);
    disp(['tauA = ' num2str(tauA) ';       % external heat transfer timescale (s)']);
    disp(['tau_ref = ' num2str(tau_ref) '; % diffusion time constant (s)']);   
    disp(['b = ' num2str(b) ';             % negative electrode surface/particle volume ratio (non-dim.)']);
    disp(['Ip_ref = ' num2str(Ip_ref) ';   % reference exchange current in the positive electrode (A)']);
    disp(['In_ref = ' num2str(In_ref) ';   % reference exchange current in the negative electrode (A)']);
    disp(['Rf = ' num2str(Rf) ';           % film resistance (Ohm)']);
    disp( ' '); disp('% Update capacity');
    disp(['CE = ' num2str(CE) ';           % coulombic efficiency (non-dim.)']);
    
    % Display initial states
    disp(['S0 = ' num2str(S0) '; % initial SOC']);
    disp(['T0 = ' num2str(T0) '; % initial temperature']);
end


%% Compile all parameters into the params structure
vars = setdiff(who,{'params','vars','sol'});
for i=1:length(vars), params.(vars{i}) = eval(vars{i}); end


end
