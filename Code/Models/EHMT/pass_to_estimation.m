function [Mass,est_dxdt,est_yeqn,params] = ...
            pass_to_estimation(Mass,est_dxdt,est_yeqn,params)
% Set the parameter estimation options and pass the subfunctions and data
% to the estimation step by applying them directly to the model definition.

% Unpack parameters
[yy, rtau, etap, etan, UpFun, UnFun, c_ind, fit_derivative] = ...
    struct2array(params, {'yy','rtau','etap','etan','UpFun','UnFun', ...
                          'c_ind','fit_derivative'});

% Select output data
if strcmp(params.DataType,'Relaxation') || max(c_ind)>8
    fit_thermal = true;
else
    fit_thermal = false;
end
if any(fit_derivative==true) && ~fit_thermal
    % No thermal parameters, consider voltage and voltage derivative
    params.yy = yy(:,[1,end]);
    params.y2_surface_temp = false;
    select = @(func) [[1,0,0]*func; [0,0,1]*func];
elseif any(fit_derivative==true)
    % Consider voltage, surface temperature and voltage derivative
    weighting = 1;
    params.yy(:,2) = weighting*yy(:,2);
    select = @(func) [[1,0,0]*func; [0,weighting,0]*func; [0,0,1]*func];
elseif ~fit_thermal
    % No thermal parameters, consider voltage only
    params.yy = yy(:,1);
    params.y2_surface_temp = false;
    select = @(func) [1,0]*func;
else
    % Consider voltage and surface temperature data
    params.yy = yy(:,1:end-1);
    select = @(func) func;
end

% Define the RHS
Tm = 1;
f = {rtau; etap; etan; UpFun; UnFun; Tm};
est_dxdt = @(t,x,u) est_dxdt(t,x,est_yeqn(t,x,u,f),u,f);
est_yeqn = @(t,x,u) select(est_yeqn(t,x,u,f));


%% Estimation options

% Set whether initial states are fixed or not
if fit_thermal
    params.fiX = {true,true,false,true};
else
    params.fiX = {true,true,true,true};
end

end
