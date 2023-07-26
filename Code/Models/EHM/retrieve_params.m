function params = retrieve_params(params,sol)
% A function to compute new parameters from the parameter estimates.

% Load constant parameters
[Qn, E_Dsn, E_kn, E_kp, Rg, Tref, Tamb, hr, fac, verbose] = ...
    struct2array(params, {'Qn','E_Dsn','E_kn','E_kp','Rg','Tref', ...
                          'Tamb','hr','fac','verbose'});

% Unpack parameter estimates
if isstruct(sol)
    c0 = mean(sol.psol)';
else
    c0 = sol(end,1:length(params.c0))';
end
p = num2cell(c0.*fac);
[rQ, rtau, rb, rIp, rIn, nu, miu, Rf] = deal(p{:});

% Update reciprocal parameters
Q = 1/rQ;
CE = Qn/Q;
tau = 1/rtau;
b = 1/rb;
Ip = 1/rIp;
In = 1/rIn;

% Update reference values
tau_ref = tau*exp(E_Dsn/Rg*(1/Tref-1/Tamb)); % diffusion time constant (s)
Ip_ref = Ip/exp(E_kp/Rg*(1/Tref-1/Tamb));    % reference exchange current (A)
In_ref = In/exp(E_kn/Rg*(1/Tref-1/Tamb));    % reference exchange current (A)

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
    disp(['Qn = ' num2str(Qn/hr) '*hr;     % negative electrode capacity (As)']);
    disp(['nu = ' num2str(nu) ';           % negative-positive electrode capacity ratio (non-dim.)']);
    disp(['miu = ' num2str(miu) ';         % cyclable lithium-positive electrode capacity ratio (non-dim.)']);
    disp(['tau_ref = ' num2str(tau_ref) '; % diffusion time constant (s)']);
    disp(['b = ' num2str(b) ';             % negative electrode surface/particle volume ratio (non-dim.)']);
    disp(['Ip_ref = ' num2str(Ip_ref) ';   % reference exchange current in the positive electrode (A)']);
    disp(['In_ref = ' num2str(In_ref) ';   % reference exchange current in the negative electrode (A)']);
    disp(['Rf = ' num2str(Rf) ';           % film resistance (Ohm)']);
    disp( ' '); disp('% Update capacity');
    disp(['CE = ' num2str(CE) ';           % coulombic efficiency (non-dim.)']);
    
    % Display initial states
    disp(['S0 = ' num2str(S0) '; % initial SOC']);
end


%% Compile all parameters into the params structure
vars = setdiff(who,{'params','vars','sol'});
for i=1:length(vars), params.(vars{i}) = eval(vars{i}); end


end
