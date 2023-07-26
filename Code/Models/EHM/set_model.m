function [Model, params] = set_model(ModelName,params,j)
% This function defines the equivalent hydraulic model (EHM) with constant
% temperature. A positive current (I>0) corresponds to charging.

% The model is given by:
% dSOC/dt = I/Q,
% dCSC/dt = (SOC-CSC)/tau+I/(b*Q),
% V = etap(SOC,I)-etan(CSC,I)+UpFun(SOC)-UnFun(CSC)+Rf*I.

% The model is scaled and written below in terms of:
% dimensionless time t/Tm,
% the input  u = [I/Um],
% the states x = [SOC; CSC],
% the output y = [(V-Vcut)/Vrng].

% Unpack parameters
[Q, tau, b, Ip, In, nu, miu, Rf, etap, etan, UpFun, UnFun, ...
    Um, Vrng, Vcut, Tm, S0] = ...
    struct2array(params, {'Q','tau','b','Ip','In','nu','miu','Rf', ...
                          'etap','etan','UpFun','UnFun', ...
                          'Um','Vrng','Vcut','Tm','S0'});

% Define an initial guess and uncertainty for each unknown parameter
guess = [1/Q; 1/tau; 1/b; 1/Ip; 1/In; nu; miu; Rf];
uncert = [0.05; 0.1; 0.1; 0; 0.5; 0; 0; 0.5];

% Set the rescaling factor and scale the initial guesses
fac = 2*guess;
c0 = guess./fac;

% Compile parameters into vector
c = {@(t) c0(1); @(t) c0(2); @(t) c0(3); @(t) c0(4); ... [1-4]
     @(t) c0(5); @(t) c0(6); @(t) c0(7); @(t) c0(8); ... [5-8]
     Um; Vcut; Vrng; ... scaling [9-11]
     etap; etan; UpFun; UnFun; ... subfunctions [12-15]
     Tm}; % keep the timescale Tm as the last entry [16]

% Define the number of parameters (not including subfunctions or Tm)
params.nop = 11;

% Define helper function
f = @(c,i,t) feval(c{i},t)*fac(i);

% Define the state derivatives
dxdt = @(t,x,y,u,c) [(f(c,1,t)*c{9}*u(1,:)); ...
                     (f(c,2,t)*(x(1,:)-x(2,:))+f(c,1,t)*f(c,3,t)*c{9}*u(1,:)) ...
                     ]*c{16};

% Define the output equation
yeqn = @(t,x,u,c) (c{12}(x(1,:),u(1,:),f(c,4,t),f(c,6,t),f(c,7,t)) ...
                  -c{13}(x(2,:),u(1,:),f(c,5,t)) ...
                  +c{14}(x(1,:),f(c,6,t),f(c,7,t))-c{15}(x(2,:)) ...
                  +f(c,8,t)*c{9}*u(1,:)-c{10})/c{11};

% Define the mass matrix
Mass = diag([1; 1; 0]);

% Set the initial states
params.X0 = [S0; S0];

% Pack up the model
Model = struct('Name', ModelName, 'Mass',Mass, 'dxdt',dxdt, 'yeqn', yeqn);
params.uncert = uncert; params.fac = fac; params.c0 = c0; params.c = c;

end
