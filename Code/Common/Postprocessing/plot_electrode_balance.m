function plot_electrode_balance(params)
% A function to plot the electrode balance from an estimated parameter set.

% Load electrode potentials
[UnFun, UpFun] = electrode_potentials(params);

% Unpack parameters
[nu, miu, Vcut, Vmax] = struct2array(params, {'nu','miu','Vcut','Vmax'});

% Plot options
linwid = 1;
green = [0.47, 0.67, 0.19];
sky_blue = [0.3, 0.75, 0.93];

% Plot electrode potentials
figure; hold on;
x = [0, logspace(-3,-0.3,100)];
x = unique([x,1-x]);
plot(x,UpFun(x,1,1),'r-','LineWidth',linwid, 'DisplayName','Positive electrode OCP');
plot(x,UnFun(x),'b-','LineWidth',linwid, 'DisplayName','Negative electrode OCP');
xlabel('Electrode state of charge');
ylabel('Voltage (V)')
legend('Location','best');

% Connect full charge and discharge points
% SOC_min = max(0,(miu-1)/nu);
% SOC_max = min(1, miu/nu);
opts = optimoptions('fsolve','Algorithm','Levenberg-Marquardt','Display','off');
SOC_min = fsolve(@(x) UpFun(x,nu,miu)-UnFun(x)-Vcut,0.1,opts);
SOC_max = fsolve(@(x) UpFun(x,nu,miu)-UnFun(x)-Vmax,0.9,opts);
plot([SOC_max, miu-nu*SOC_max], [UnFun(SOC_max), UpFun(miu-nu*SOC_max,1,1)], ...
    'o--','LineWidth',linwid, 'Color',green, 'DisplayName','Charge limit');
plot([SOC_min, miu-nu*SOC_min], [UnFun(SOC_min), UpFun(miu-nu*SOC_min,1,1)], ...
    'o--','LineWidth',linwid, 'Color',sky_blue, 'DisplayName','Discharge limit');

end
