function [etan, etap] = reaction_overpotentials(params)
% A function to define the reaction overpotentials in the EHM.
% Note that positive electrode dynamics are assumed fast such that
% CSCp = SOCp = miu - nu*SOC by conservation of lithium.

% Unpack parameters
[alph, Ip, In, Tamb, nu, miu, Um, Rg, Faraday, plot_model] = ...
    struct2array(params, {'alph','Ip','In','Tamb','nu','miu','Um','Rg', ...
                          'Faraday','plot_model'});

% Invert parameters
rIp = 1/Ip; rIn = 1/In;

% Define inverse sinh function with cut-off
ash = @(rI,S,I) asinh((rI.*I./(2*max((1-S).*S,1e-6)).^alph));

% Define reaction overpotentials
etap = @(T,SOC,I,rIp,n,m) 2*Rg/Faraday*T.*ash(rIp,m-n*SOC,I);
etan = @(T,CSC,I,rIn) 2*Rg/Faraday*T.*ash(rIn,CSC,-I);

% Plot functions
if plot_model
    figure; hold on;
    sgtitle('Top: positive electrode, bottom: negative electrode');
    LineSpec.LineStyle = 'none';
    N = 100;
    S = linspace(0,1,N)';
    U = Um*linspace(-1,1,N)';
    subplot(2,1,1); hold on; view(3);
    surf(S,U,etap(Tamb,S',U,rIp,nu,miu),LineSpec);
    xlabel('State of charge');
    ylabel('Normalised current');
    zlabel('Reaction overpotential (V)');
    subplot(2,1,2); hold on; view(3);
    surf(S,U,etan(Tamb,S',U,rIn),LineSpec);
    xlabel('State of charge');
    ylabel('Normalised current');
    zlabel('Reaction overpotential (V)');
end

% Rescale for dimensionless inputs
etan = @(CSC,u,rn) etan(Tamb,CSC,Um*u,rn);
etap = @(SOC,u,rp,n,m) etap(Tamb,SOC,Um*u,rp,n,m);

end
