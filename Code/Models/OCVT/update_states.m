function X0 = update_states(X0,init)
% A function to update the initial states. The inputs are the existing
% estimate X0 and a structure containing the informed values.

% State of charge
X0(1) = init.X;

% Temperature
X0(2:3) = deal(init.T);

end
