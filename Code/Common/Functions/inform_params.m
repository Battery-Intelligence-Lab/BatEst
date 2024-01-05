function params = inform_params(params,ModelName,true_sol)
% A function to update the parameters according to values obtained from the
% dataset. To do this, the dimensional parameter value must be updated
% along with the corresponding entries in the c0 and c arrays (see the
% relevant set_model function for their definitions). The scaling factors
% in the fac vector are kept the same. This function is called before
% set_unknown.m.

% Add the type of data and load the uncertainties
DataType = true_sol.DataType;
y2_surface_temp = true_sol.y2_surface_temp;
uncert = params.uncert;

% Update the uncertainties
if any(strcmp(ModelName,{'EHM','EHMT'}))
    if strcmp(DataType,'Relaxation')
        uncert(1:8) = [0; 1; 0; 0; 0; 0; 0; 0];
    elseif contains(DataType,'charge') && ~contains(DataType,'OCV')
        uncert(1:8) = [0; 0; 0.2; 1; 1; 0; 0; 1];
    elseif strcmp(DataType,'Cycling')
        uncert(1:8) = [0.03; 0; 0.03; 0.03; 0.03; 0.03; 0.03; 0.03];
    end
elseif strcmp(ModelName,'RORC')
    if strcmp(DataType,'Relaxation')
        uncert(1:4) = [0; 1; 0; 0];
    elseif contains(DataType,'charge') && ~contains(DataType,'OCV')
        uncert(1:4) = [0; 0; 1; 1];
    elseif strcmp(DataType,'Cycling')
        uncert(1:4) = [0.03; 0; 0.03; 0.03];
    end
end

% Update the effective capacity Q using the measured coulombic efficiency
if isfield(true_sol,'CE') && isfield(params,'CE')
    CE = true_sol.CE;
    Q = params.Qn/CE;
    params = update(params,1,'rQ',1/Q);
    % Fix the negative electrode capacity Qn
    uncert(1) = 0;
end

% Update the reference temperature
if isfield(true_sol,'Tref')
    if isfield(true_sol,'tau')
        % Update activated parameter values
        [tau, Ip, In, E_Dsn, E_kp, E_kn, Rg] = ...
            struct2array(params, {'tau','Ip','In','E_Dsn','E_kp','E_kn','Rg'});
        tau = tau/exp(E_Dsn/Rg*(1/true_sol.Tref-1/params.Tref)); % diffusion time constant (s)
        Ip = Ip*exp(E_kp/Rg*(1/true_sol.Tref-1/params.Tref)); % maximum exchange current (A)
        In = In*exp(E_kn/Rg*(1/true_sol.Tref-1/params.Tref)); % maximum exchange current (A)
    end
    Tref = true_sol.Tref;
end

% Update the negative electrode surface/particle volume ratio
if isfield(true_sol,'b') && isfield(params,'b')
    b = true_sol.b;
    params = update(params,3,'rb',1/b);
end

% Update the reference exchange current in the negative electrode
if isfield(true_sol,'In_ref')
    In_ref = true_sol.In_ref;
end


%% Compile all parameters into the params structure
vars = setdiff(who,{'params','vars','ModelName','true_sol'});
for i=1:length(vars), params.(vars{i}) = eval(vars{i}); end


end

% A function to update the unknown parameter estimate as well as the value
function params = update(params,ind,name,new_value)
params.(name) = new_value;
params.c0(ind) = params.(name)/params.fac(ind);
params.c{ind} = @(t) params.c0(ind);
end
