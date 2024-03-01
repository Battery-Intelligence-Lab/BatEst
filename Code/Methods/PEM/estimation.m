function sol = estimation(Mass,dxdt,yeqn,params)
% Perform state/parameter estimation using PEM.

% Unpack parameters
[X0, tt, U, yn, c0, c_ind, lb, ub, fiX, verbose] = ...
    struct2array(params, {'X0','tt','U','yy','c0','c_ind','lb','ub', ...
                          'fiX','verbose'});

if ~any(yn)
    error('PEM is only able to estimate parameters from data.');
end
if isempty(c_ind)
    error(['At least one parameter must be unknown. Please check the ' ...
           'value of the uncertainties in set_model.m or inform_params.m.']);
end

% Set bounds
lb = lb(c_ind);
ub = ub(c_ind);
lgap = c0(c_ind)-lb;
ugap = ub-c0(c_ind);
flexible_bounds = true; % true or false

% PEM requires equidistant time steps
equitt = linspace(tt(1),tt(end),length(tt))';
equiyn = interp1(tt,yn,equitt);

% Create iddata object to store output, input and sample rate
timestep = equitt(2)-equitt(1);
data = iddata(equiyn,[],timestep);
data.Tstart = equitt(1);
data.TimeUnit = '';

% Define an initial guess for the parameters
for i = 1:length(c_ind)
    parameters(i).Name = ['p' num2str(i)];
    parameters(i).Unit = '';
    parameters(i).Value = c0(c_ind(i));
    parameters(i).Minimum = lb(i);
    parameters(i).Maximum = ub(i);
    parameters(i).Fixed = false;
end

% PEM options
[SimOpts, EstOpts] = DefaultPEMOpts;
if ~verbose
    EstOpts.Display = 'off';
end

% Configure the nonlinear grey-box model
file_name = ['greybox' num2str(length(c_ind))];
order = [size(equiyn,2) 0 length(X0)]; % number of outputs, inputs and states
initial_states = X0; % warm start
Ts = 0; % sample time of discrete model or 0 for a continuous time model
init_sys = idnlgrey(file_name,order,parameters,initial_states,Ts, ...
                    'FileArgument',{dxdt,yeqn},'SimulationOptions',SimOpts);
init_sys.TimeUnit = '';

% Set whether the initial states are fixed or free estimation parameters
setinit(init_sys,'Fixed',fiX);

% Set up successful estimation conditions
NearBound = Inf;
MaxSteps = 5; step = 0;
while NearBound>0 && step<MaxSteps

% Estimate the model parameters and initial states
runtic = tic;
sys = pem(data,init_sys,EstOpts);
X0 = sys.Report.Parameters.X0; %findstates(sys,data);
toc(runtic);

% Analyze the estimation result
% figure; compare(data,sys,init_sys);

% Extract the parameter estimates
ce = sys.Report.Parameters.ParVector;

if ~flexible_bounds
    break;
end

% Check bounds
[mlb, ib(1)] = min(ce-lb);
[mub, ib(2)] = min(ub-ce);
[mb, i] = min([mlb,mub]);
if mb < 0.05*(lgap+ugap)
    NearBound = ib(i);
    if verbose
        warning(['At least one estimated parameter is very near or ' ...
                 'equal to one of its bounds. The closest value is the ' ...
                 'parameter in position ' num2str(c_ind(NearBound)) '.']);
    end
else
    NearBound = 0;
    continue;
end

% Widen the bounds
if lb(NearBound)==0
    if verbose
        warning('The lower bound for this parameter cannot be further reduced.');
    end
    NearBound = 0;
else
    lb(NearBound) = max(0,ce(NearBound)-lgap(NearBound));
    ub(NearBound) = ce(NearBound)+ugap(NearBound);
    init_sys = setpar(init_sys,'Value',  num2cell(ce));
    init_sys = setpar(init_sys,'Minimum',num2cell(lb));
    init_sys = setpar(init_sys,'Maximum',num2cell(ub));
end

% Update the initial states
init_sys = setinit(init_sys,'Value',num2cell(X0));

% Update the step count
step = step+1;
end

% Update the parameters
c0(c_ind) = ce;

% Pack up solution
sol.tsol = equitt;
sol.xsol = X0';
sol.usol = U(equitt);
sol.psol = ones(length(equitt),1)*c0';

end
