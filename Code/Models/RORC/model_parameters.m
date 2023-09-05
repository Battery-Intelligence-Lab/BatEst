function params = model_parameters(params,j)
% Set the values of the model parameters and store in the params structure.

% Define model type
Type = 'RORC';

% Load cell properties
[hr] = struct2array(params, {'hr'});

% Set model parameters
Qn = 3.4*hr;         % negative electrode capacity (As)
nu = 0.79;           % negative/positive electrode capacity ratio (non-dim.)
miu = 0.87;          % cyclable lithium/positive electrode capacity ratio (non-dim.)
Rs = 0.01;           % series resistance (Ohm)
tau1 = 20;           % time constant of the RC pair [= R1*C1] (s)
C1 = 400;            % capacitance of the RC pair (F)

% Update capacity
CE = 1;              % coulombic efficiency (non-dim.)
Q = Qn/CE;           % effective negative electrode capacity (As)


%% Compile all parameters into the params structure
vars = setdiff(who,{'params','vars'});
for i=1:length(vars), params.(vars{i}) = eval(vars{i}); end


end
