function [tt, uu] = cell_protocol(params)
% A function to manually define or generate a protocol from data. This
% function is called by set_protocol.m. The outputs are the vector of time
% points tt and corresponding input values uu. There may be up to 3 inputs:
% current (A), temperature (deg. C) and measured voltage (V) in that order.

% Load parameters
[mn, hr, Crate, CtoK] = struct2array(params, {'mn','hr','Crate','CtoK'});

% Define the protocol
t_end = 30*mn; % time period (s)
u1 = @(t) 0.5*Crate; % current (A)
u2 = @(t) 25; % temperature (deg. C)
u3 = @(t) 3.5+0.5*t/t_end; % voltage (V)

% Compute the discrete time protocol
nt = 100;
tt(1:nt,1) = linspace(0,t_end,nt)';
uu(1:nt,1) = u1(tt);
uu(1:nt,2) = u2(tt);
uu(1:nt,3) = u3(tt);

% Or, load the protocol from file
%     load('Data/Examples/drive_cycle.parquet','time','current');
%     tt = time;
%     uu = current;

end
