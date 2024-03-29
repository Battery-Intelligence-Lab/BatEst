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
    elseif (contains(DataType,'charge') && ~contains(DataType,'OCV')) ...
            || strcmp(DataType,'Cycling')
        uncert(1:8) = [0.05; 0; 0; 1; 1; 0; 0; 1];
                    % [1/Q; 1/tau; 1/b; 1/Ip; 1/In; nu; miu; Rf];
    end
elseif strcmp(ModelName,'RORC')
    if strcmp(DataType,'Relaxation')
        uncert(1:4) = [0; 1; 0; 0];
    elseif (contains(DataType,'charge') && ~contains(DataType,'OCV')) ...
            || strcmp(DataType,'Cycling')
        uncert(1:4) = [0.05; 0; 1; 1];
    end
end

% Update the effective capacity Q using the measured coulombic efficiency
if (contains(DataType,'charge') && ~contains(DataType,'OCV')) ...
        && isfield(true_sol,'CE') && isfield(params,'CE')
    CE = true_sol.CE;
    Q = params.Qn/CE;
    params = update(params,1,'rQ',1/Q);
end

% Update the ambient temperature
if strcmp(ModelName,'EHM') && isfield(true_sol,'Tamb')
    Tamb = true_sol.Tamb;
    % Update activated parameter values
    [tau, Ip, In, Tamb_old, E_Dsn, E_kp, E_kn, Rg] = ...
        struct2array(params, {'tau','Ip','In','Tref','E_Dsn','E_kp','E_kn','Rg'});
    tau = tau/exp(E_Dsn/Rg*(1/Tamb_old-1/Tamb)); % diffusion time constant (s)
    Ip = Ip*exp(E_kp/Rg*(1/Tamb_old-1/Tamb)); % reference exchange current (A)
    In = In*exp(E_kn/Rg*(1/Tamb_old-1/Tamb)); % reference exchange current (A)
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
