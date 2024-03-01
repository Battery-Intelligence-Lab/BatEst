function params = default_plotting(sol,params)
% The default plotting script.

% Unpack parameters and solution
[tsol, xsol, ysol, usol, Type, bts, bis] = ...
    struct2array(sol, {'tsol','xsol','ysol','usol','Type','bts','bis'});
[Um, Vcut, Vrng, Trng, TtoK, CtoK, mn, Crate, fs, OCV, UnFun, UpFun, ...
    nu, miu, Rf, Rs, y2_surface_temp, fit_derivative] = ...
    struct2array(params, {'Um','Vcut','Vrng','Trng','TtoK','CtoK', ...
                          'mn','Crate','fs','OCV','UnFun','UpFun', ...
                          'nu','miu','Rf','Rs','y2_surface_temp', ...
                          'fit_derivative'});
y2_surface_temp = any(y2_surface_temp); fit_derivative = any(fit_derivative);

% Rescale the variables
time = tsol/mn; % time period (min)
bts = bts/mn; % breakpoint times (min)
usol(:,1) = usol(:,1)*Um; % current (A)
usol(:,2) = usol(:,2)*Trng+TtoK-CtoK; % external temperature (deg. C)
usol(:,3) = usol(:,3)*Vrng+Vcut; % voltage (V)
ysol(:,1) = ysol(:,1)*Vrng+Vcut; % voltage (V)
if y2_surface_temp
    ysol(:,2) = ysol(:,2)*Trng+TtoK-CtoK; % surface temperature (deg. C)
else
    ysol = [ysol(:,1), NaN(size(ysol(:,1))), ysol(:,2:end)];
end
if fit_derivative
    ysol(:,3) = ysol(:,3)*Vrng; % voltage derivative (V/min)
    usol(:,4) = usol(:,4)*Um; % current derivative (A/s)
    usol(:,5) = usol(:,5)*Trng; % external temperature derivative (K/s)
end
if size(xsol,2)>3
    xsol(:,3) = xsol(:,3)*Trng+TtoK-CtoK; % core temperature (deg. C)
end

% Set axis limits
tlim = [0, max(time)];
Xlim = [0,1];
ulim = [-any(usol(:,1)<0), 1]*Um;
Vlim = [0,1.1]*Vrng+Vcut;
Tlim = [-0.1,1.1]*Trng+TtoK-CtoK;

% Generate or select figure
if any(fs)
    figure(fs);
else
    fig_states = figure;
    params.fs = fig_states.Number;

    % Setup axes
    subplot(2,2,1); hold on;
    xlim(tlim); xlabel('Time (min)');
    ylim(ulim); ylabel('Current (A)');
    subplot(2,2,2); hold on;
    xlim(tlim); xlabel('Time (min)');
    ylim(Vlim); ylabel('Voltage (V)');
    subplot(2,2,3); hold on;
    xlim(tlim); xlabel('Time (min)');
    ylim(Xlim);
    if y2_surface_temp
        subplot(2,2,4); hold on;
        xlim(tlim); xlabel('Time (min)');
        ylim(Tlim);
    end

    % Add C-rate markers
    subplot(2,2,1); hold on;
    iter = 1; maxiter = 10; CC = Crate;
    while CC < Um && iter<maxiter
        plot(tlim,CC*[1,1],'k:',LineWidth=0.5);
        CC = CC+CC;
        iter = iter+1;
    end
end

% Set plotting options
LineSpec.LineStyle = '-';
LineSpec.LineWidth = 1;
colours = get(gca,'colororder');
if strcmp(Type,'True')
    LineSpec.DisplayName = 'Ground truth';
    if any(bis), LineSpec.Marker = '+'; end
    [LineSpec1, LineSpec2, LineSpec3, LineSpecB] = deal(LineSpec);
    LineSpec1.Color = 'k';          % black
    LineSpec2.Color = colours(1,:); % blue
    LineSpec3.Color = colours(6,:); % light blue
elseif strcmp(Type,'Control')
    LineSpec.DisplayName = Type;
    [LineSpec1, LineSpec2, LineSpec3, LineSpecB] = deal(LineSpec);
    LineSpec1.Color = colours(3,:)/10; % dark green
    LineSpec2.Color = colours(5,:);    % green
    LineSpec3.Color = colours(3,:);    % yellow
elseif strcmp(Type,'Prediction')
    LineSpec.DisplayName = Type;
    if any(fs)
        LineSpec.LineStyle = '--';
    end
    [LineSpec1, LineSpec2, LineSpec3, LineSpecB] = deal(LineSpec);
    LineSpec1.Color = colours(7,:); % dark red
    LineSpec2.Color = 'r';          % red
    LineSpec3.Color = colours(2,:); % orange
else
    [LineSpec1, LineSpec2, LineSpec3, LineSpecB] = deal(LineSpec);
end
if any(bis)
    LineSpecB.Color = 'k';
    LineSpecB.Marker = '+';
    LineSpecB.LineStyle = 'none';
    LineSpecB.DisplayName = 'Breakpoints';
end

% Compile the plotting parameters into the params structure
vars = {'tlim','Xlim','ulim','Vlim','Tlim', ...
        'LineSpec1','LineSpec2','LineSpec3','LineSpecB'};
for i=1:length(vars), params.plotting.(vars{i}) = eval(vars{i}); end

% Plot the control
subplot(2,2,1); hold on;
plot(time,usol(:,1),LineSpec1);
plot(bts,usol(bis,1),LineSpecB);

% Plot the output
subplot(2,2,2); hold on;
plot(time,ysol(:,1),LineSpec1);
plot(bts,ysol(bis,1),LineSpecB);

% Compute and plot the voltage contributions
if any(strcmp(Type,{'Prediction','True'})) && sum(isnan(xsol),'all')==0
    % From the open-circuit voltage
    if isa(OCV,'function_handle')
        OCVx = OCV(xsol(:,1),nu,miu);
    else
        OCVx = UpFun(xsol(:,1),nu,miu)-UnFun(xsol(:,2));
    end
    % From the series resistance
    if any(Rs) && size(xsol,2)>1
        plot(time,OCVx+Rs*usol(:,1),LineSpec3,DisplayName=[Type ' OCV+RsI']);
    elseif any(Rf)
        plot(time,OCVx+Rf*usol(:,1),LineSpec3,DisplayName=[Type ' OCV+RfI']);
    end
    if size(xsol,2)>1
        plot(time,OCVx,LineSpec2,DisplayName=[Type ' OCV']);
    end
end

% Add legend
legend(Location='Best');

% Plot the states of charge
subplot(2,2,3); hold on;
plot(time,xsol(:,1),LineSpec1,DisplayName=[Type ' SOC']);
plot(bts,xsol(bis,1),LineSpecB);
if isa(OCV,'function_handle')
    ylabel('SOC');
else
    plot(time,xsol(:,2),LineSpec2,DisplayName=[Type ' CSC']);
    plot(bts,xsol(bis,2),LineSpecB);
    ylabel('SOC, CSC');
end

% Plot the temperature
if size(usol,2)>1 && strcmp(Type,'True')
    subplot(2,2,4); hold on;
    plot(time,usol(:,2),LineSpec1,DisplayName=[Type ' Te']);
    plot(bts,usol(bis,2),LineSpecB);
    ylim(Tlim); ylabel('Te (deg C)');
    legend(Location='Best');
end
if y2_surface_temp
    subplot(2,2,4); hold on;
    plot(time,ysol(:,2),LineSpec2,DisplayName=[Type ' Ts']);
    plot(bts,ysol(bis,2),LineSpecB);
    ylabel('Te, Ts (deg C)');
end
if size(xsol,2)>3 && sum(~isnan(xsol(:,3)))>0
    subplot(2,2,4); hold on;
    plot(time,xsol(:,3),LineSpec3,DisplayName=[Type ' Tc']);
    plot(bts,xsol(bis,3),LineSpecB);
    ylabel('Te, Ts, Tc (deg C)');
end

drawnow;
end
