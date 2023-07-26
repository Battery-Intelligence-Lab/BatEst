function [dx, y] = greybox11(t, x, u, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, funs, varargin)
% For static models, dx, x and u = []. For discrete-time models, dx is the
% value of the states at the next time step x(t+Ts). For continuous-time
% models, dx is the state derivatives at time t, or dxdt. The outputs dx
% and y need to be column vectors.

% Compile parameters
c = [c1;c2;c3;c4;c5;c6;c7;c8;c9;c10;c11];

% Unpack functions
dxdt = funs{1};
yeqn = funs{2};

% State derivative
dx = dxdt(t,x,c);

% Output
y = yeqn(t,x,c);

end
