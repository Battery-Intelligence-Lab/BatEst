function [Model, params] = set_model(ModelName,params,j)
% This function defines an equivalent circuit model with an OCV source, one
% RC pair and a resistor in series.
% A positive current (I>0) corresponds to charging.

% The model is given by:
% dSOC/dt = I/Q,
% dVrc/dt = Vrc/tau1+I/C1.
% V = OCV(SOC)+Vrc+Rs*I.

% The model is scaled and written below in terms of:
% dimensionless time t/Tm,
% the input  u = [I/Um],
% the states x = [SOC; Vrc/Vrng],
% the output y = [(V-cutV)/Vrng].

% Unpack parameters
[Q, tau1, C1, nu, miu, Um, Vcut, Vrng, Rs, OCV, Tm, S0, mn, fit_derivative] = ...
    struct2array(params, {'Q','tau1','C1','nu','miu',...
                          'Um','Vcut','Vrng','Rs','OCV','Tm','S0', ...
                          'mn','fit_derivative'});

% Define an initial guess and uncertainty for each unknown parameter
guess = [1/Q; 1/tau1; 1/(C1*Vrng); Rs; nu; miu];
uncert = [0.05; 0.5; 0.5; 1; 0; 0];

% Set the rescaling factor and scale the initial guesses
fac = 2*guess;
c0 = guess./fac;

% Compile parameters into vector
c = {@(t) c0(1); @(t) c0(2); @(t) c0(3); @(t) c0(4); ... [1-4]
     @(t) c0(5); @(t) c0(6); ... [5-6]
     Um; Vcut; Vrng; ... scaling [7-9]
     OCV; ... subfunctions [10]
     Tm}; % keep the timescale Tm as the last entry [11]

% Define the number of parameters (not including subfunctions or Tm)
params.nop = 9;

% Define helper function
f = @(c,i,t) feval(c{i},t)*fac(i);

% Define the state derivatives
dxdt = @(t,x,y,u,c) [f(c,1,t)*c{7}*u(1,:); ...
                     -f(c,2,t)*x(2,:)+f(c,3,t)*c{7}*u(1,:)]*c{11};

% Set the initial states
params.X0 = [S0; 0];

% Define the output equation
out = @(t,x,u,c) (c{10}(x(1,:),f(c,5,t),f(c,6,t))+c{9}*x(2,:) ...
                   +f(c,4,t)*c{7}*u(1,:)-c{8})/c{9};

% Define the mass matrix
Mass = diag([1; 1; 0]);

if any(fit_derivative==true)
    % Add the voltage derivative as an output
    delta = 1e-4;
    dVdx = @(t,x,u,c) [(out(t,x+[delta;0],u,c)-out(t,x-[delta;0],u,c))/(2*delta);
                       (out(t,x+[0;delta],u,c)-out(t,x-[0;delta],u,c))/(2*delta)];
    yeqn = @(t,x,u,c) [out(t,x,u,c); sum(dVdx(t,x,u,c).*dxdt(t,x,[],u,c),1)*mn/c{11}];
    Mass(end+1,end+1) = 0; % extend the mass matrix
else
    yeqn = out;
end

% Pack up the model
Model = struct('Name', ModelName, 'Mass',Mass, 'dxdt',dxdt, 'yeqn', yeqn);
params.uncert = uncert; params.fac = fac; params.c0 = c0; params.c = c;

end
