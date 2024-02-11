function params = model_parameters(params,j)
% Set the values of the model parameters and store in the params structure.

% Define model type
Type = 'OCV';

% Load cell properties
[hr] = struct2array(params, {'hr'});

% Set model parameters
Qn = 3.4*hr;         % negative electrode capacity (As)
nu = 0.79;           % negative/positive electrode capacity ratio (non-dim.)
miu = 0.87;          % cyclable lithium/positive electrode capacity ratio (non-dim.)


%% Compile all parameters into the params structure
vars = setdiff(who,{'params','vars'});
for i=1:length(vars), params.(vars{i}) = eval(vars{i}); end


end
