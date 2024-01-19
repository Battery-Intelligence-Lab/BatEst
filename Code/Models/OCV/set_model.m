function [Model, params] = set_model(ModelName,params,j)
% This function defines an equivalent circuit model with an OCV source.
% A positive current (I>0) corresponds to charging.

% The model is given by:
% dSOC/dt = I/Q,
% V = OCV(SOC).

% The model is scaled and written below in terms of:
% dimensionless time t/Tm,
% the input  u = [I/Um],
% the states x = [SOC],
% the output y = [(V-Vcut)/Vrng].

% Unpack parameters
[Qn, nu, miu, Um, Vrng, Vcut, OCV, Tm, S0, mn, fit_derivative] = ...
    struct2array(params, {'Qn','nu','miu',...
                          'Um','Vrng','Vcut','OCV','Tm','S0', ...
                          'mn','fit_derivative'});

% Define an initial guess and uncertainty for each unknown parameter
guess = [1/Qn; nu; miu];
uncert = [0.1; 0.1; 0.1];

% Set the rescaling factor and scale the initial guesses
fac = 2*guess;
c0 = guess./fac;

% Compile parameters into vector
c = {@(t) c0(1); @(t) c0(2); @(t) c0(3); ... [1-3]
     Um; Vcut; Vrng; ... scaling [4-6]
     OCV; ... subfunctions [7]
     Tm}; % keep the timescale Tm as the last entry [8]

% Define the number of parameters (not including subfunctions or Tm)
params.nop = 6;

% Define helper function
f = @(c,i,t) feval(c{i},t)*fac(i);

% Define the state derivatives
dxdt = @(t,x,y,u,c) [f(c,1,t)*c{4}*u(1,:)]*c{8};

% Set the initial states
params.X0 = [S0];

% Define the output equation
out = @(t,x,u,c) (c{7}(x(1,:),f(c,2,t),f(c,3,t))-c{5})/c{6};

% Define the mass matrix
Mass = diag([1; 0]);

if any(fit_derivative==true)
    % Add the voltage derivative as an output
    delta = 1e-4;
    dVdx = @(t,x,u,c) [(out(t,x+delta,u,c)-out(t,x-delta,u,c))/(2*delta);
                       (out(t,x,u+delta,c)-out(t,x,u-delta,c))/(2*delta)];
    yeqn = @(t,x,u,c) [out(t,x,u,c); sum(dVdx(t,x,u,c).*[dxdt(t,x,[],u,c)/c{8}; u(4,:)],1)*mn];
    Mass(end+1,end+1) = 0; % extend the mass matrix
else
    yeqn = out;
end

% Pack up the model
Model = struct('Name', ModelName, 'Mass',Mass, 'dxdt',dxdt, 'yeqn', yeqn, ...
               'y2_surface_temp',false);
params.uncert = uncert; params.fac = fac; params.c0 = c0; params.c = c;

end
