function [Model, params] = set_model(ModelName,params,j)
% This function defines the equivalent circuit model (ECM) with an OCV
% source and a resistor in series, in combination with a hysteresis model.
% The hysteresis model is taken from: doi.org/10.1016/j.est.2022.105016.
% A positive current (I>0) corresponds to charging.

% The model is given by:
% dSOC/dt = I/Q,
% dh/dt = K*I*[(Cr(SOC)/Q)^x]*(1-sign(I)*h),
% V = OCV(SOC)+H(SOC)*h+Rs*I.

% The model is scaled and written below in terms of:
% dimensionless time t/Tm,
% the input  u = [I/Um],
% the states x = [SOC; h],
% the output y = [(V-Vcut)/Vrng].

% Unpack parameters
[Q, K, x, Rs, nu, miu, Um, Vcut, Vrng, OCV, Cr, H, Tm, S0] = ...
    struct2array(params, {'Q','K','x','Rs','nu','miu',...
                          'Um','Vcut','Vrng','OCV','Cr','H','Tm','S0'});

% Define an initial guess and uncertainty for each unknown parameter
guess = [1/Q; K; x; Rs; nu; miu];
uncert = [0.05; 1; 1; 1; 0; 0];

% Set the rescaling factor and scale the initial guesses
fac = 2*guess;
c0 = guess./fac;

% Compile parameters into vector
c = {@(t) c0(1); @(t) c0(2); @(t) c0(3); ... [1-3]
     @(t) c0(4); @(t) c0(5); @(t) c0(5); ... [4-6]
     Um; Vcut; Vrng; ... limits [7-9]
     OCV; Cr; H; ... open-circuit voltage, hysteresis functions [10-12]
     Tm}; % keep the timescale Tm as the last entry [13]

% Define the number of parameters (not including subfunctions or Tm)
params.nop = 9;

% Define helper function
f = @(c,i,t) feval(c{i},t)*fac(i);

% Define the state derivatives
dxdt = @(t,x,y,u,c) [f(c,1,t)*c{7}*u(1,:); ...
                     f(c,2,t)*c{7}*u(1,:)*(f(c,1,t)*c{11}(x(1,:)))^f(c,3,t) ...
                        *(1-sign(u(1,:))*x(2,:))]*c{13};

% Define the output equation
yeqn = @(t,x,u,c) (c{10}(x(1,:),f(c,5,t),f(c,6,t)) ...
                   +c{12}(x(1,:))*x(2,:) ... hysteresis term
                   +f(c,4,t)*c{7}*u(1,:)-c{8})/c{9};

% Define the mass matrix
Mass = diag([1;1;0]);

% Set initial states
params.X0 = [S0; 0];

% Pack up the model
Model = struct('Name', ModelName, 'Mass',Mass, 'dxdt',dxdt, 'yeqn', yeqn);
params.uncert = uncert; params.fac = fac; params.c0 = c0; params.c = c;

end
