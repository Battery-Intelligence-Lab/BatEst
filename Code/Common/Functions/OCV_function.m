function OCV = OCV_function(params)
% This function defines the open-circuit voltage (V) as a continuous
% function of state of charge.

% Unpack parameters
[OCP_filename, plot_model] = ...
    struct2array(params, {'OCP_filename','plot_model'});

if length(OCP_filename)==1
    OCV_filename = OCP_filename{1};

    % Define the open-circuit voltage
    if endsWith(OCV_filename,'.parquet','IgnoreCase',true)
        OCV = load_OCP(OCV_filename);
    elseif endsWith(OCV_filename,'.csv','IgnoreCase',true) ...
            || endsWith(OCV_filename,'.mat','IgnoreCase',true)
        error(['Please convert the OCP data into the Parquet file format.' ...
               'See the DATA_PREP_GUIDE for more information.']);
    else % filename is a function
        OCV = eval(OCV_filename);
    end
    
    if plot_model
        % Plot open-circuit voltage
        x = [0, logspace(-3,-0.3,100)];
        x = unique([x,1-x]);
        figure; hold on;
        plot(x,OCV(x),'b:+');
        xlabel('State of charge');
        ylabel('Voltage (V)')
    end
    
elseif length(OCP_filename)==2
    
    % Define the OCV as the difference between the electrode OCPs
    [UnFun, UpFun] = electrode_potentials(params);
    OCV =  @(soc,nu,miu) UpFun(soc,nu,miu)-UnFun(soc);
    
else
    error('Unexpectd OCP_filename.')
end

end
