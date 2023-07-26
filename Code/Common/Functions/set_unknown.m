function [Mass,est_dxdt,est_yeqn,params] = set_unknown(Target,Model,params)
% This function determines which elements of the model are unknown and
% are to be estimated. Any number of parameters can be estimated together
% or the control u(t). For the purpose of parameter estimation, refer to
% the 'Model/set_model.m' function for the definition of the parameter
% vector. First the vector of indices c_ind for the unknown parameters is
% set. Next, in 'c_vec' below, each unknown parameter is set equal to an
% element of k, i.e. @(t) k(i,:), if it is unknown. If it is known, set the
% element of 'c_vec' equal to the corresponding value of 'c', i.e. c(i).
% Then the function 'update_c' is determined in an analogous way, with
% par(i) for unknown elements and params.c(i) for known elements.

% Unpack inputs
[Mass, dxdt, yeqn] = struct2array(Model, {'Mass','dxdt','yeqn'});
[c, nop, uncert, polyapprox] = struct2array(params, {'c','nop','uncert','polyapprox'});

if strcmp(Target,'Parameter')
    % Select which parameters are unknown via their indices
    params.c_ind = find(uncert~=0);
    
    % Create a vector replacing unknown parameters with placeholder
    % functions and a function to update c with new parameter estimates
    c_vec = @(k,f) [];
    update_c = @(par,params) [];
    j = 1;
    for i = 1:nop
        if ismember(i,params.c_ind)
            c_vec = @(k,f) [c_vec(k,f); {@(t) k(j,:)}];
            update_c = @(par,params) [update_c(par,params); par(j)];
            j = j+1;
        else
            c_vec = @(k,f) [c_vec(k,f); c(i)];
            update_c = @(par,params) [update_c(par,params); params.c(i)];
        end
    end
    c_vec = @(k,f) [c_vec(k,f); f];
    update_c = @(par,params) [update_c(par,params); params.c(nop+1:end)];
    params.update_c = @(par,params) update_c(par,params);
    
    % Load protocol
    [tt, uu] = struct2array(params,{'tt','uu'});
    
    % Define a continuous function for the protocol
    if any(polyapprox)
        % Generate an n-th order polynomial input control
        pol = @(t,c) c(:,1)+c(:,2).*t+c(:,3).*t.^2; %+c(:,4).*t.^3;
        for i = 1:size(uu,2)
            fit(i,:) = fliplr(polyfit(tt,uu(:,i),2));
        end
        U = @(t) pol(t',fit);
    else
        spl = spline(tt,uu'); % produces a piecewise polynomial for use by PPVAL - can use spline, pchip or makima
        U = @(t) ppval(spl,t);
    end
    params.U = U;
    
    % Fix the known parameters and control input
    est_dxdt = @(t,x,y,k,f) dxdt(t,x,y,U(t),c_vec(k,f));
    est_yeqn = @(t,x,k,f) yeqn(t,x,U(t),c_vec(k,f));

    % Pass model options and data to the estimation step
    [Mass,est_dxdt,est_yeqn,params] = ...
        pass_to_estimation(Mass,est_dxdt,est_yeqn,params);
    
elseif strcmp(Target,'Control')
    c_vec = @(f) [c(1:nop);f];
    est_dxdt = @(t,x,y,u,f) dxdt(t,x,y,u,c_vec(f));
    est_yeqn = @(t,x,u,f) yeqn(t,x,u,c_vec(f));
    params.c0 = [];
end

end
