function [Model, params] = set_model(ModelName,params,j)

% This function defines the Schiffer model for a lead-acid battery from:
% doi.org/10.1016/j.jpowsour.2006.11.092.
% A positive current (I>0) corresponds to charging.

% The model is given by:
% dSOC/dt = A[I - E*exp(cV*V+cT*T)],
% V(t) = OCV(SOC/[B-C*SOC])+D*(1+b1*SOC/[1-SOC])*I.

% The model is scaled and written below in terms of:
% dimensionless time t/Tm,
% the input  u = [I/Um; (T-TtoK)*rTrng],
% the states x = [SOC],
% the output y = [(V-Vcut)/Vrng].

% Unpack parameters
[A, B, C, D, E, b1, cV, cT, Tc, Um, Vcut, Vrng, OCV, x0, Tm, S0] = ...
    struct2array(params, {'A','B','C','D','E','b1','cV','cT','Tc', ...
                          'Um','Vcut','Vrng','OCV','x0','Tm','S0'});

% Define an initial guess and uncertainty for each unknown parameter
guess = [A; B; C; D; E; b1];
uncert = 0.1*ones(size(guess));

% Set the rescaling factor and scale the initial guesses
fac = 2*guess;
c0 = guess./fac;

% Compile parameters into vector
c = {@(t) c0(1); @(t) c0(2); @(t) c0(3); @(t) c0(4); ... [1-4]
     @(t) c0(5); @(t) c0(6); ... [5-6]
     Um; Vcut; Vrng; ... limits [7-9]
     OCV; ... open-circuit voltage [10]
     Tm}; % keep the timescale Tm as the last entry [11]

% Define the number of parameters (not including subfunctions or Tm)
params.nop = 9;

% Define helper function
f = @(c,i,t) feval(c{i},t)*fac(i);

% Define the state derivatives
dxdt = @(t,x,y,u,c) f(c,1,t)*(c{7}*u(1,:)-f(c,5,t)*exp(cV*(y*c{9}+c{8})+cT*Tc))*c{11};

% Define the output equation
yeqn = @(t,x,u,c) (c{10}((x(1,:)+x0)./(f(c,2,t)-f(c,3,t)*x(1,:))) ...
                   +f(c,4,t)*(1+f(c,6,t)*x(1,:)./(1-x(1,:))).*(c{7}*u(1,:)) ...
                   -c{8})/c{9};

% Define the mass matrix
Mass = diag([1;0]);

% Set initial states
params.X0 = S0;

% Pack up the model
Model = struct('Name', ModelName, 'Mass',Mass, 'dxdt',dxdt, 'yeqn', yeqn);
params.uncert = uncert; params.fac = fac; params.c0 = c0; params.c = c;

end
