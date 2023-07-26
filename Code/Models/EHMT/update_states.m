function X0 = update_states(X0,SOC,Y0)
% A function to update the initial states. The inputs are the existing
% estimate X0, the initial state of charge and the initial output data Y0.

% State of charge
if any(SOC)
    X0(1:2) = SOC(1:2);
end

%  Temperature
if size(Y0,2)>1
    X0(3:4) = max(Y0(end),0);
end

end
