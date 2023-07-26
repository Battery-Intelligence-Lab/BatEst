function [pred_sol,params] = step3(Target,Model,params,j,est_sol)
% This step runs a simulation using the latest parameter estimates.

pred_sol = [];
np = [];

if strcmp(Target,{'Control'})
    % Update the protocol based on the estimation
    params.tt = est_sol.tsol;
    params.uu = est_sol.usol;
elseif strcmp(Target,'Parameter')
    % Update initial states
    params.X0 = est_sol.xsol(1,:)';
    % Update parameter values
    c_ind = params.c_ind;
    np = length(c_ind);
    par = cell(np,1);
    for i = 1:np
        spl = spline(est_sol.tsol,est_sol.psol(:,c_ind(i)));
        par{i} = @(t) ppval(spl,t);
    end
    params.c = params.update_c(par,params);
end

if any(strcmp(Target,{'Compare','Parameter','Control'}))
    % Make a prediction
    pred_sol = run_simulation(Model,params);
    pred_sol.Type = 'Prediction';
    % Save the parameter values
    if any(np)
        pred_sol.psol = 0.5*ones(length(pred_sol.tsol),length(params.c0));
        for i = 1:np
            pred_sol.psol(:,c_ind(i)) = par{i}(pred_sol.tsol);
        end
    end
    % Plot any prediction
    params = plot_sol(pred_sol,params);
    if params.verbose
        disp('Prediction complete.');
    end
end

end
