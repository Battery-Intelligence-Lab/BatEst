function [Model, params] = set_model(ModelName,params,j)
% This function defines the equivalent hydraulic model with temperature
% (EHMT). A positive current (I>0) corresponds to charging.

% The model is given by:
% dSOC/dt = I/Q,
% dCSC/dt = (SOC-CSC)/tau(Tc)+I/(b*Q),
% dTc/dt = (V-UpFun(SOC)+UnFun(SOC))*I/Cp-(Tc-Ts)/tauT,
% dTs/dt = Cp/Cps*(Tc-Ts)/tauT-(Ts-Te)/tauA,
% V = etap(Tc,SOC,I)-etan(Tc,CSC,I)+UpFun(SOC)-UnFun(CSC)+Rf*I.

% The model is scaled and written below in terms of:
% dimensionless time t/Tm,
% the input  u = [I/Um; (Te-TtoK)/Trng],
% the states x = [SOC; CSC; (Tc-TtoK)/Trng; (Ts-TtoK)/Trng],
% the output y = [(V-Vcut)/Vrng; (Ts-TtoK)/Trng].

% Unpack parameters
[Q, tau_ref, b, Ip_ref, In_ref, nu, miu, Rf, Cp, Cps, tauT, tauA, ...
    rtau, etap, etan, UpFun, UnFun, Um, Vcut, Vrng, Trng, Tm, S0] = ...
    struct2array(params, {'Q','tau_ref','b','Ip_ref','In_ref','nu', ...
                          'miu','Rf','Cp','Cps','tauT','tauA', ...
                          'rtau','etap','etan','UpFun','UnFun', ...
                          'Um','Vcut','Vrng','Trng','Tm','S0'});

% Define an initial guess and uncertainty for each unknown parameter
guess = [1/Q; 1/tau_ref; 1/b; 1/Ip_ref; 1/In_ref; nu; miu; Rf; ...
         1/Cp; Cp/Cps; 1/tauT; 1/tauA];
uncert = [0.05; 0.1; 0.1; 0; 0.5; 0; 0; 0.5; 0; 0; 0; 0];

% Set the rescaling factor and scale the initial guesses
fac = 2*guess;
c0 = guess./fac;

% Compile parameters into vector
c = {@(t) c0(1); @(t) c0(2); @(t) c0(3); @(t) c0(4); ... [1-4]
     @(t) c0(5); @(t) c0(6); @(t) c0(7); @(t) c0(8); ... [5-8]
     @(t) c0(9); @(t) c0(10); @(t) c0(11); @(t) c0(12); ... [9-12]
     Um; Vcut; Vrng; Trng; ... scaling [13-16]
     rtau; etap; etan; UpFun; UnFun; ... subfunctions [17-21]
     Tm}; % keep the timescale Tm as the last entry [22]

% Define the number of parameters (not including subfunctions or Tm)
params.nop = 16;

% Define helper function
f = @(c,i,t) feval(c{i},t)*fac(i);

% Define the state derivatives
dxdt = @(t,x,y,u,c) [(f(c,1,t)*c{13}*u(1,:)); ...
                     (c{17}(x(3,:),f(c,2,t))*(x(1,:)-x(2,:)) ...
                         +f(c,1,t)*f(c,3,t)*c{13}*u(1,:));
                     (f(c,9,t)*(c{15}*y(1,:)+c{14} ...
                                  -c{20}(x(1,:),f(c,6,t),f(c,7,t)) ...
                                  +c{21}(x(1,:))).*(c{13}*u(1,:)) ...
                         -f(c,11,t)*(x(3,:)-x(4,:)))/c{16}; ...
                     (f(c,10,t)*f(c,11,t)*(x(3,:)-x(4,:)) ...
                         -f(c,12,t)*(x(4,:)-u(2,:)))/c{16} ...
                     ]*c{22};

% Define the output equation
yeqn = @(t,x,u,c) [(... c{18}(x(3,:),x(1,:),u(1,:),f(c,4,t),f(c,6,t),f(c,7,t)) ...
                   -c{19}(x(3,:),x(2,:),u(1,:),f(c,5,t)) ...
                   +c{20}(x(1,:),f(c,6,t),f(c,7,t))-c{21}(x(2,:)) ...
                   +f(c,8,t)*c{13}*u(1,:)-c{14})/c{15}; ...
                   x(4,:)];

% Define the mass matrix
Mass = diag([1; 1; 1; 1; 0; 0]);

% Set the initial states
params.X0 = [S0; S0; 0; 0];

% Pack up the model
Model = struct('Name', ModelName, 'Mass',Mass, 'dxdt',dxdt, 'yeqn', yeqn);
params.uncert = uncert; params.fac = fac; params.c0 = c0; params.c = c;

end
