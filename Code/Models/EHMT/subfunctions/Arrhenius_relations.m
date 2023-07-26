function [rtau, rIn, rIp] = Arrhenius_relations(params)
% A function to define the Arrhenius temperature dependence in the EHMT.

% Unpack parameters
[tau_ref, In_ref, Ip_ref, E_Dsn, Rg, Tref, E_kn, E_kp, Trng, TtoK, ...
    plot_model] ...
    = struct2array(params, {'tau_ref','In_ref','Ip_ref','E_Dsn','Rg', ...
                            'Tref','E_kn','E_kp','Trng','TtoK', ...
                            'plot_model'});

% Define temperature dependence
rtau = @(T,rtau_ref) rtau_ref*exp(E_Dsn/Rg*(1/Tref-1./T));
rIn = @(T,rIn_ref) rIn_ref./exp(E_kn/Rg*(1/Tref-1./T));
rIp = @(T,rIp_ref) rIp_ref./exp(E_kp/Rg*(1/Tref-1./T));

% Plot functions
if plot_model
    figure; hold on;
    LineSpec = 'b+';
    N = 100;
    T = Trng*linspace(0,1,N)+TtoK;
    subplot(1,3,1); hold on;
    plot(T,1./rtau(T,1/tau_ref),LineSpec);
    xlabel('Temperature (K)');
    ylabel('Diffusion timescale (s)');
    subplot(1,3,2); hold on;
    plot(T,1./rIn(T,1/In_ref),LineSpec);
    xlabel('Temperature (K)');
    ylabel('Reference exchange current in the negative electrode (A)');
    subplot(1,3,3); hold on;
    plot(T,1./rIp(T,1/Ip_ref),LineSpec);
    xlabel('Temperature (K)');
    ylabel('Reference exchange current in the positive electrode (A)');
end

% Rescale for dimensionless inputs
rtau = @(T,gr) rtau(Trng*T+TtoK,gr);

end
