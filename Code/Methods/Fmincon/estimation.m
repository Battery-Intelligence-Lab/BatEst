function sol = estimation(Mass,dxdt,yeqn,params)
% Perform parameter estimation using Fmincon.

% Unpack parameters
[X0, tt, U, yn, c0, c_ind, lb, ub, fiX, verbose] = ...
    struct2array(params, {'X0','tt','U','yy','c0','c_ind','lb','ub', ...
                          'fiX','verbose'});

if ~any(yn)
    error('Fmincon is only able to estimate parameters from data.');
elseif iscell(fiX) && any(~[fiX{:}])
    if verbose
        warning(['Fmincon is not designed to estimate initial states. ' ...
                 'Continuing with fiX==true.']);
    end
end
if isempty(c_ind)
    error(['At least one parameter must be unknown. Please check the ' ...
           'value of the uncertainties in set_model.m or inform_params.m.']);
end

% Set bounds
A = [];
b = [];
Aeq = [];
beq = [];
lb = lb(c_ind);
ub = ub(c_ind);
nonlcon = [];
lgap = c0(c_ind)-lb;
ugap = ub-c0(c_ind);

% Set options
tol = 1e-6;
options = optimoptions('fmincon','Algorithm','sqp','Display','iter', ...
                       'FunctionTolerance',tol,'StepTolerance',tol);
ode15opts = odeset('Mass',Mass,'RelTol',tol*100,'AbsTol',tol);
warning('off','MATLAB:ode15s:IntegrationTolNotMet');

% Compile RHS
RHS = @(t,x,y,c) [dxdt(t,x,c); yeqn(t,x,c)-y];

% Run optimisation of the cost function
runtic = tic;
% [c,fval,exitflag,output] = fmincon(...
ce = fmincon(@(ce) cost_function(ce,tt,yn,RHS,yeqn,X0,ode15opts), ...
             c0(c_ind), A, b, Aeq, beq, lb, ub, nonlcon, options);
toc(runtic);

% Reset warning
warning('on','MATLAB:ode15s:IntegrationTolNotMet');

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
end

% Update the parameters
c0(c_ind) = ce;

% Pack up solution
sol.tsol = tt;
sol.xsol = X0';
sol.usol = U(tt);
sol.psol = ones(length(tt),1)*c0';

end
