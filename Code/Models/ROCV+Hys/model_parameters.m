function params = model_parameters(params,j)
% Set the values of the model parameters and store in the params structure.

% Define model type
Type = 'ROCV+Hys';

% Load cell properties
[hr] = struct2array(params, {'hr'});

% Set model parameters
Qn = 3.3*hr;         % negative electrode capacity (As)
nu = 1;              % negative/positive electrode capacity ratio (non-dim.)
miu = 1;             % cyclable lithium/positive electrode capacity ratio (non-dim.)
Rs = 0.01;           % series resistance (Ohm)
K = 50;              % hysteresis parameter (non-dim.)
x = 1;               % fitting parameter (non-dim.)

% Update capacity
CE = 1;              % coulombic efficiency (non-dim.)
Q = Qn/CE;           % effective negative electrode capacity (As)


%% Compile all parameters into the params structure
vars = setdiff(who,{'params','vars'});
for i=1:length(vars), params.(vars{i}) = eval(vars{i}); end


end
