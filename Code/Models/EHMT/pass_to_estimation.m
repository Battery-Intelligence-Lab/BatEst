function [Mass,est_dxdt,est_yeqn,params] = ...
            pass_to_estimation(Mass,est_dxdt,est_yeqn,params)
% Set the parameter estimation options and pass the subfunctions and data
% to the estimation step by applying them directly to the model definition.

% Unpack parameters
[yy, rtau, etap, etan, UpFun, UnFun, DataType, c_ind] = ...
    struct2array(params, {'yy','rtau','etap','etan','UpFun','UnFun', ...
                          'DataType','c_ind'});

% Consider only voltage
if max(c_ind)<9
    % No thermal parameters are being estimated so use only voltage data
    params.yy = yy(:,1);
    select = [1,0];
else
    % Use both voltage and surface temperature data
    select = 1;
end

% Define the RHS
Tm = 1;
f = {rtau; etap; etan; UpFun; UnFun; Tm};
est_dxdt = @(t,x,u) est_dxdt(t,x,est_yeqn(t,x,u,f),u,f);
est_yeqn = @(t,x,u) select*est_yeqn(t,x,u,f);


%% Estimation options

% Set whether initial states are fixed or not
if strcmp(DataType,'Relaxation')
    params.fiX = {false,false,true,true};
else
    params.fiX = {true,true,true,true};
end


end
