function [Mass,est_dxdt,est_yeqn,params] = ...
            pass_to_estimation(Mass,est_dxdt,est_yeqn,params)
% Set the parameter estimation options and pass the subfunctions and data
% to the estimation step by applying them directly to the model definition.

% Unpack parameters
[yy, etap, etan, UpFun, UnFun, DataType] = ...
    struct2array(params, {'yy','etap','etan','UpFun','UnFun','DataType'});

% Consider only voltage
params.yy = yy(:,1);

% Define the RHS
Tm = 1;
f = {etap; etan; UpFun; UnFun; Tm};
est_dxdt = @(t,x,c) est_dxdt(t,x,est_yeqn(t,x,c,f),c,f);
est_yeqn = @(t,x,c) est_yeqn(t,x,c,f);


%% Estimation options

% Set whether initial states are fixed or not
if strcmp(DataType,'Relaxation')
    params.fiX = {false,false};
else
    params.fiX = {true,true};
end


end
