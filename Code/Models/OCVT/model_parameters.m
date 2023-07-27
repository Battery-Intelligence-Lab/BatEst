function params = model_parameters(params,j)
% Set the values of the model parameters and store in the params structure.

% Define model type
Type = 'OCVT';

% Load cell properties
[hr] = struct2array(params, {'hr'});

% Set model parameters
Qn = 3.4*hr;         % negative electrode capacity (As)
nu = 0.79;           % negative/positive electrode capacity ratio (non-dim.)
miu = 0.87;          % cyclable lithium/positive electrode capacity ratio (non-dim.)
Cp = 40;             % heat capacity of the core (J K-1)
Cps = 4;             % heat capacity of the surface (J K-1)
tauT = 20;           % internal heat transfer timescale (s)
tauA = 2;            % external heat transfer timescale (s)

% Update capacity
CE = 1;              % coulombic efficiency (non-dim.)
Q = Qn/CE;           % effective negative electrode capacity (As)


%% Compile all parameters into the params structure
vars = setdiff(who,{'params','vars'});
for i=1:length(vars), params.(vars{i}) = eval(vars{i}); end


end

