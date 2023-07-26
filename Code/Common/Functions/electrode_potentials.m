function [UnFun, UpFun] = electrode_potentials(params)
% This function creates continuous open-circuit potential (OCP) functions
% of state of charge (SOC), where the SOC is chosen to equal the negative
% electrode stoichiometry. Therefore the OCPp function is converted into
% the UpFun function of SOC, nu and miu, where the (unknown) nu and miu
% parameters relate the positive and negative stoichiometries via
% SOCp = miu - nu*SOC, by conservation of lithium. Therefore the SOCp
% range corresponding to an SOC range of [0,1] is [miu,miu-nu].

% Unpack parameters
[OCP_filename, plot_model] = ...
    struct2array(params, {'OCP_filename','plot_model'});

% Check that there are two filenames
if length(OCP_filename)<2
    error(['Two OCP functions or data files are required to define the ' ...
           'electrode potentials.']);
else
    OCPp_filename = OCP_filename{1};
    OCPn_filename = OCP_filename{2};
end

% Define the positive electrode OCP
if endsWith(OCPp_filename,'.parquet','IgnoreCase',true)
    Upp = load_OCP(OCPp_filename,'positive');
elseif endsWith(OCPp_filename,'.csv','IgnoreCase',true) ...
        || endsWith(OCPp_filename,'.mat','IgnoreCase',true)
    error(['Please convert the OCP data into the Parquet file format.' ...
           'See the DATA_PREP_GUIDE for more information.']);
else % filename is a function
    Upp = eval(OCPp_filename);
end

% Define the negative electrode OCP
if endsWith(OCPn_filename,'.parquet','IgnoreCase',true)
    UnFun = load_OCP(OCPn_filename,'negative');
elseif endsWith(OCPn_filename,'.csv','IgnoreCase',true) ...
        || endsWith(OCPn_filename,'.mat')
    error(['Please convert the OCP data into the Parquet file format.' ...
           'See the DATA_PREP_GUIDE for more information.']);
else % filename is a function
    UnFun = eval(OCPn_filename);
end

% Convert the positive electrode stoichiometry into a function of SOC
UpFun = @(SOC,nu,miu) Upp(miu-nu*SOC);

if plot_model
    % Plot electrode potentials
    figure; hold on;
    x = [0, logspace(-3,-0.3,100)];
    x = unique([x,1-x]);
    plot(x,UnFun(x),'b:+','DisplayName','Negative electrode OCP');
    plot(x,UpFun(x,1,1),'r:+','DisplayName','Positive electrode OCP');
    xlabel('State of charge');
    ylabel('Voltage (V)')
    legend('Location','best');
end

end
