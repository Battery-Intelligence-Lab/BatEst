function [Mass,est_dxdt,est_yeqn,params] = ...
            pass_to_estimation(Mass,est_dxdt,est_yeqn,params)
% Set the parameter estimation options and pass the subfunctions and data
% to the estimation step by applying them directly to the model definition.

% Unpack parameters
[yy, OCV] = struct2array(params, {'yy','OCV'});

% Determine whether there is surface temperature data
if size(yy,2)==1
    error('This model requires surface temperature data.')
end

% Select output data
params.yy = yy(:,1:2);

% Define the RHS
Tm = 1;
f = {OCV; Tm};
est_dxdt = @(t,x,c) est_dxdt(t,x,est_yeqn(t,x,c,f),c,f);
est_yeqn = @(t,x,c) est_yeqn(t,x,c,f);


%% Estimation options

% Set whether initial states are fixed or not
params.fiX = {true,true,true};


end
