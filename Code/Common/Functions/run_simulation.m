function sol = run_simulation(Model,params)
% This function runs a forward simulation of the Model with given params,
% using dimensionless time between [0,1].

% Unpack inputs
[Mass, dxdt, yeqn] = struct2array(Model, {'Mass','dxdt','yeqn'});
[X0, tt, uu, c] = struct2array(params,{'X0','tt','uu','c'});

% Set the total time
Tm = tt(end);
c{end} = Tm;

% Generate input control
spl = spline(tt,uu'); % produces a piecewise polynomial for use by PPVAL - can use spline, pchip or makima
U   = @(t) ppval(spl,t);

% Compute consistent ICs
Y0 = [X0; yeqn(0,X0,U(0),c)];

% Check array sizes
if length(Mass)~=length(Y0)
    if ~any(length(Y0))
        error('There is no initial value for the output equation.')
    else
        error(['The length of the initial conditions vector does not ' ...
            'match the size of the Mass matrix.']);
    end
end

% Compile RHS
RHS = @(t,x,y,u,c) [dxdt(t,x,y,u,c); yeqn(t,x,u,c)-y];

% Make prediction by running the forward model
options = odeset('RelTol',1e-4,'AbsTol',1e-8,'Mass',Mass);
                    % ,'MaxStep',tt(2)-tt(1));
[tsol,Y] = ode15s(@(t,Y) RHS(t,Y(1:length(X0),:),Y(length(X0)+1:end,:),U(t*Tm),c), ...
                  tt/Tm,Y0,options);

% Pack up solution
sol.tsol = tsol*Tm;
sol.xsol = Y(:,1:length(X0));
sol.ysol = Y(:,length(X0)+1:end);
sol.usol = uu(1:length(tsol),:);

% Update whether the output includes surface temperature
if size(sol.ysol,2)>1+sum((params.fit_derivative))
    params.y2_surface_temp = true;
end

end
