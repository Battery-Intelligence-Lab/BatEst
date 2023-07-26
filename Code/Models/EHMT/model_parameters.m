function params = model_parameters(params,j)
% Set the values of the model parameters and store in the params structure.

% Define model type
Type = 'EHMT';

% Load cell properties
[hr] = struct2array(params, {'hr'});

% Set model parameters
Qn = 3.3*hr;         % negative electrode capacity (As)
nu = 1;              % negative/positive electrode capacity ratio (non-dim.)
miu = 1;             % cyclable lithium/positive electrode capacity ratio (non-dim.)
Cp = 40;             % heat capacity of the core (J K-1)
Cps = 4;             % heat capacity of the surface (J K-1)
tauT = 20;           % internal heat transfer timescale (s)
tauA = 2;            % external heat transfer timescale (s)
tau_ref = 200;       % diffusion time constant (s)
b = 0.3;             % negative electrode surface/particle volume ratio (non-dim.)
Ip_ref = 2;          % reference exchange current in the positive electrode (A)
In_ref = 2;          % reference exchange current in the negative electrode (A)
Rf = 0.01;           % film resistance (Ohm)

% Update capacity
CE = 1;              % coulombic efficiency (non-dim.)
Q = Qn/CE;           % effective negative electrode capacity (As)

% Constants
alph = 0.5;          % charge transfer coefficients (non-dim.)
Faraday = 96487;     % Faraday's constant (C mol-1)
Rg = 8.314472;       % gas constant (J mol-1 K-1)


%% Temperature dependence
% Activation energies (J mol-1)
E_Dsn = 42770; % for solid-state diffusion in the negative electrode
E_kn  = 37480; % for the reaction in the negative electrode
E_kp  = 39570; % for the reaction in the positive electrode


%% Compile all parameters into the params structure
vars = setdiff(who,{'params','vars'});
for i=1:length(vars), params.(vars{i}) = eval(vars{i}); end


end

