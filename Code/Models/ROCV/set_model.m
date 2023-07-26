function [Model, params] = set_model(ModelName,params,j)
% This function defines the equivalent circuit model (ECM) with an OCV
% source and a resistor in series.
% A positive current (I>0) corresponds to charging.

% The model is given by:
% dSOC/dt = I/Q,
% V = OCV(SOC)+Rs*I.

% The model is scaled and written below in terms of:
% dimensionless time t/Tm,
% the input  u = [I/Um],
% the states x = [SOC],
% the output y = [(V-Vcut)/Vrng].

% Unpack parameters
[Q, nu, miu, Um, Vcut, Vrng, Rs, OCV, Tm, S0] = ...
    struct2array(params, {'Q','nu','miu',...
                          'Um','Vcut','Vrng','Rs','OCV','Tm','S0'});

% Define an initial guess and uncertainty for each unknown parameter
guess = [1/Q; Rs; nu; miu];
uncert = [0.05; 1; 0; 0];

% Set the rescaling factor and scale the initial guesses
fac = 2*guess;
c0 = guess./fac;

% Compile parameters into vector
c = {@(t) c0(1); @(t) c0(2); @(t) c0(3); @(t) c0(4); ... [1-4]
     Um; Vcut; Vrng; ... scaling [5-7]
     OCV; ... subfunctions [8]
     Tm}; % keep the timescale Tm as the last entry [9]

% Define the number of parameters (not including subfunctions or Tm)
params.nop = 7;

% Define helper function
f = @(c,i,t) feval(c{i},t)*fac(i);

% Define the state derivatives
dxdt = @(t,x,y,u,c) [f(c,1,t)*c{5}*u(1,:)]*c{9};

% Define the output equation
yeqn = @(t,x,u,c) (c{8}(x(1,:),f(c,3,t),f(c,4,t)) ...
                   +f(c,2,t)*c{5}*u(1,:)-c{6})/c{7};

% Define the mass matrix
Mass = diag([1; 0]);

% Set the initial states
params.X0 = [S0];

% Pack up the model
Model = struct('Name', ModelName, 'Mass',Mass, 'dxdt',dxdt, 'yeqn', yeqn);
params.uncert = uncert; params.fac = fac; params.c0 = c0; params.c = c;

end
