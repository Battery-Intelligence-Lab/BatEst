function J = cost_function(c,tt,yn,RHS,yeqn,X0,options)
% Compute the root mean square residual between the data and simulation.
% The inputs are the unknown parameter estimate(s) c, the time points tt,
% the data yn, the model derivatives RHS, the output equation yeqn, the
% initial states X0 and the simulation options. The output is the scalar
% cost J.

% Compute consistent initial conditions and length of time vector
Y0 = [X0; yeqn(0,X0,c)];
lt = length(tt);

% Make prediction by running the forward model
try
    [~,Y] = ode15s(@(t,Y) RHS(t,Y(1:length(X0),:),Y(length(X0)+1:end,:),c), ...
                    tt,Y0,options);
    unsolved = lt-size(Y,1);
catch
    unsolved = lt-1;
    Y = Y0';
end

% Ensure the output is the same length as the time vector
Y = [Y(:,length(X0)+1:end); Y(end,length(X0)+1:end).*ones(unsolved,1)];

% Define a weighting between different outputs
weighting = ones(1,size(yn,2));

% Compute the root mean square residual between the data and simulation
J = 0;
for i = 1:size(yn,2)
    J = J+weighting(i)*sqrt(sum((yn(:,i)-Y(:,i)).^2));
end

end
