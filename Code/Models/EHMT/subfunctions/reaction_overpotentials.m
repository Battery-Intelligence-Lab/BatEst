function [etan, etap] = reaction_overpotentials(params)
% A function to define the reaction overpotentials in the EHMT.
% Note that positive electrode dynamics are assumed fast such that
% CSCp = SOCp = miu - nu*SOC by conservation of lithium.

% Unpack parameters
[alph, rIp, rIn, Ip_ref, In_ref, nu, miu, TtoK, Trng, Um, Rg, Faraday, ...
    plot_model] = ...
    struct2array(params, {'alph','rIp','rIn','Ip_ref','In_ref','nu', ...
                          'miu','TtoK','Trng','Um','Rg','Faraday', ...
                          'plot_model'});

% Invert parameters
rIp_ref = 1/Ip_ref; rIn_ref = 1/In_ref;

% Define inverse sinh function with cut-off
ash = @(rI,S,I) asinh((rI.*I./(2*max((1-S).*S,1e-6)).^alph));

% Define reaction overpotentials
etap = @(Tc,SOC,I,rp,n,m) 2*Rg/Faraday*Tc.*ash(rIp(Tc,rp),m-n*SOC,I);
etan = @(Tc,CSC,I,rn) 2*Rg/Faraday*Tc.*ash(rIn(Tc,rn),CSC,-I);

% Plot functions
if plot_model
    figure; hold on;
    sgtitle('Top: positive electrode, bottom: negative electrode');
    LineSpec.LineStyle = 'none';
    N = 100;
    T = Trng*linspace(0,1,N)'+TtoK;
    S = linspace(0,1,N)';
    U = Um*linspace(-1,1,N)';
    for i = [1,N]
        subplot(2,3,1); hold on; view(3);
        surf(T,S,etap(T',S,U(i),rIp_ref,nu,miu),LineSpec);
        xlabel('Temperature (K)');
        ylabel('State of charge');
        zlabel('Reaction overpotential (V)');
        subplot(2,3,2); hold on; view(3);
        surf(S,U,etap(T(i),S',U,rIp_ref,nu,miu),LineSpec);
        xlabel('State of charge');
        ylabel('Current (A)');
        zlabel('Reaction overpotential (V)');
        subplot(2,3,4); hold on; view(3);
        surf(T,S,etan(T',S,U(i),rIn_ref),LineSpec);
        xlabel('Temperature (K)');
        ylabel('State of charge');
        zlabel('Reaction overpotential (V)');
        subplot(2,3,5); hold on; view(3);
        surf(S,U,etan(T(i),S',U,rIn_ref),LineSpec);
        xlabel('State of charge');
        ylabel('Current (A)');
        zlabel('Reaction overpotential (V)');
    end
    for i = [2,N/2]
        subplot(2,3,3); hold on; view(3);
        surf(U,T,etap(T,S(i),U',rIp_ref,nu,miu),LineSpec);
        xlabel('Current (A)');
        ylabel('Temperature (K)');
        zlabel('Reaction overpotential (V)');
        subplot(2,3,6); hold on; view(3);
        surf(U,T,etan(T,S(i),U',rIn_ref),LineSpec);
        xlabel('Current (A)');
        ylabel('Temperature (K)');
        zlabel('Reaction overpotential (V)');
    end
end

% Rescale for dimensionless inputs
etan = @(Tc,CSC,u,rn) etan(Trng*Tc+TtoK,CSC,Um*u,rn);
etap = @(Tc,SOC,u,rp,n,m) etap(Trng*Tc+TtoK,SOC,Um*u,rp,n,m);

end
