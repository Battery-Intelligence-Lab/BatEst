function params = step4(Target,params,true_sol,pred_sol)
% This step is for analysis of the prediction compared to the data.

% Compute difference between data and simulation
if any(strcmp(Target,{'Compare','Parameter'}))
    params = compute_RMSE(params,true_sol,pred_sol);
end

end
