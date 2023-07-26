function params = model_parameters(params,j)
% Set the values of the model parameters and store in the params structure.

% Define model type
Type = 'Schiffer';

% Load cell properties
[hr] = struct2array(params, {'hr'});

% Set model parameters
Qnom = 20;       % nominal capacity (Ah)
CN = Qnom*hr;    % nominal capacity (As)
Vw = 17.5/1e6;   % molar volume of H20 (m3 mol-1)
Ve = 45/1e6;     % molar volume of H2SO4 (m3 mol-1)
Mw = 18e-3;      % molar mass of H20 (kg mol-1)
F = 96485;       % Faraday constant (C)
Velec = 1.43e-4; % electrolyte volume (m3)
b0 = 0.42;       % fitting parameter
b1 = 42.54;      % fitting parameter
b2 = 1;          % fitting parameter
Igas0 = 0.017;   % normalised gassing current (A)
cV = 0.183;      % voltage coefficient (V-1)
Vgas0 = 13.38;   % nominal voltage (V)
cT = 0.06;       % temperature coefficient (K-1)
Tgas0 = 298;     % nominal temperature (K)
Tc = 298;        % constant temperature (K)
cmax = 5600;     % initial acid concentration at SOC=1 (mol m-3)
cmin = 5600-CN/(F*Velec); % minimum acid concentration (mol m-3)
x0 = cmin*F*Velec/CN; % "state of charge offset"

% Update scaling parameters
Vcut = 12;       % cut-off voltage (V)
Vrng = 2.5;      % maximum voltage deviation (V)
Um = 4;          % maximum current (A)

% Define boundary values
Sc = 0.99;  % SOC in fully charged state (non-dim.)
Sd = 0.5;  % SOC in discharged state (non-dim.)

% Set lumped parameters
A = 1/CN;
B = Mw/Vw*(F*Velec/CN-Ve*x0);
C = Ve*Mw/Vw;
D = b0/CN;
E = Igas0*exp(-cV*Vgas0-cT*Tgas0);


%% Compile all parameters into the params structure
vars = setdiff(who,{'params','vars'});
for i=1:length(vars), params.(vars{i}) = eval(vars{i}); end


end
