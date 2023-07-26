function [Mass,est_dxdt,est_yeqn,params] = ...
            pass_to_estimation(Mass,est_dxdt,est_yeqn,params)
% Set the parameter estimation options and pass the subfunctions and data
% to the estimation step by applying them directly to the model definition.

% Unpack parameters
[OCV, yy] = struct2array(params, {'OCV','yy'});

% Consider only voltage
params.yy = yy(:,1);

% Define the RHS
Tm = 1;
f = {OCV; Tm};
est_dxdt = @(t,x,c) est_dxdt(t,x,est_yeqn(t,x,c,f),c,f);
est_yeqn = @(t,x,c) est_yeqn(t,x,c,f);


%% Estimation options

% Set whether initial states are fixed or not
params.fiX = {false};


end
