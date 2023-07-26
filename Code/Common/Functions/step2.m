function [est_sol,params] = step2(Target,Model,params,j)
% This step runs the estimation to obtain control or parameter estimates.

est_sol = [];

if strcmp(Target,{'Parameter'})
    % Add upper and lower bounds to the parameter estimates
    params = add_bounds(params);
end

if any(strcmp(Target,{'Simulate','Plot','Compare'}))
    % Nothing to estimate
else
    % Select unknown or set cost function
    [Mass, est_dxdt, est_yeqn, params] = ...
        set_unknown(Target,Model,params);
    
    % Perform estimation
    est_sol = estimation(Mass,est_dxdt,est_yeqn,params);
    est_sol.Type = Target;
    
    if strcmp(Target,{'Parameter'})
        % Overwrite parameters with estimates
        params = retrieve_params(params,est_sol);
    end
    
    % Plot any estimated solution
    if isfield(est_sol,'ysol')
        params = plot_sol(est_sol,params);
    end
    if params.verbose
        disp('Estimation complete.');
    end
end
    
end
