function [Model, params] = set_model(ModelName,params,j)
% This function defines a heat resistor model for the temperature
% dynamics based on the difference between the voltage and the OCV.
% A positive current (I>0) corresponds to charging.

% The model is given by:
% dSOC/dt = I/Q,
% dTc/dt = (V-OCV(SOC))*I/Cp-(Tc-Ts)/tauT,
% dTs/dt = Cp/Cps*(Tc-Ts)/tauT-(Ts-Te)/tauA,
% V = V_data,

% The model is scaled and written below in terms of:
% dimensionless time t/Tm,
% the input  u = [I/Um; (Te-TtoK)/Trng; (V-Vcut)/Vrng],
% the states x = [SOC; (Tc-TtoK)/Trng; (Ts-TtoK)/Trng],
% the output y = [(V-Vcut)/Vrng; (Ts-TtoK)/Trng].

% Unpack parameters
[Q, nu, miu, Cp, Cps, tauT, tauA, Um, Vcut, Vrng, Trng, ...
    OCV, Tm, S0, fit_derivative] = ...
    struct2array(params, {'Q','nu','miu','Cp','Cps','tauT','tauA' ...
                          'Um','Vcut','Vrng','Trng', ...
                          'OCV','Tm','S0' ...
                          'fit_derivative'});

% Define an initial guess and uncertainty for each unknown parameter
guess = [1/Q; nu; miu; 1/Cp; Cp/Cps; 1/tauT; 1/tauA];
uncert = [0; 0; 0; 0; 0; 1; 1];

% Set the rescaling factor and scale the initial guesses
fac = 2*guess;
c0 = guess./fac;

% Compile parameters into vector
c = {@(t) c0(1); @(t) c0(2); @(t) c0(3); ... [1-3]
     @(t) c0(4); @(t) c0(5); @(t) c0(6); @(t) c0(7); ... [4-7]
     Um; Vcut; Vrng; Trng; ... scaling [8-11]
     OCV; ... subfunctions [12]
     Tm}; % keep the timescale Tm as the last entry [13]

% Define the number of parameters (not including subfunctions or Tm)
params.nop = 11;

% Define helper function
f = @(c,i,t) feval(c{i},t)*fac(i);

% Define the state derivatives
dxdt = @(t,x,y,u,c) [(f(c,1,t)*c{8}*u(1,:)); ...
                     (f(c,4,t)*(c{10}*y(1,:)+c{9} ...
                                  -c{12}(x(1,:),f(c,2,t),f(c,3,t)) ...
                                  ).*(c{8}*u(1,:)) ...
                         -f(c,6,t)*(x(2,:)-x(3,:)))/c{11}; ...
                     (f(c,5,t)*f(c,6,t)*(x(2,:)-x(3,:)) ...
                         -f(c,7,t)*(x(3,:)-u(2,:)))/c{11} ...
                     ]*c{13};

% Set the initial states
params.X0 = [S0; 0; 0];

% Define the output equation
out = @(t,x,u,c) [u(3,:); x(3,:)];

% Define the mass matrix
Mass = diag([1; 1; 1; 0; 0]);

if any(fit_derivative==true)
    warning('The OCVT cannot fit the derivative: the voltage is an input.')
    params.fit_derivative = false;
    yeqn = out;
else
    yeqn = out;
end

% Pack up the model
Model = struct('Name', ModelName, 'Mass',Mass, 'dxdt',dxdt, 'yeqn', yeqn, ...
               'y2_surface_temp',true);
params.uncert = uncert; params.fac = fac; params.c0 = c0; params.c = c;

end
