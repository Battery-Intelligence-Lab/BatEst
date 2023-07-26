function OCP = load_OCP(OCP_filename,electrode)
% A function to load pseudo-open-circuit potential (OCP) data for a
% half-cell or a full-cell and use it to generate a continuous function of
% stoichiometry. The 'OCP_filename' file is expected to be a parquet file
% with three columns labelled Test_Time_s, Current_A and Voltage_V.
% A positive current is assumed to correspond to charging.

% Load the dataset
T = parquetread(OCP_filename);

% Ensure that all values are of numeric type double
T = convertvars(T,T.Properties.VariableNames,'double');

if nargin==2 && strcmp(electrode,'positive')
    flip = -1;
else
    flip = 1;
end

% Define starting stoichiometry value
if flip*mean(T.Current_A)<0
    % Discharge
    Start = 1;
else
    % Charge
    Start = 0;
end

% Compute the capacity and stoichiometry/SOC by integration
S = cumtrapz(T.Test_Time_s,T.Current_A);
S = Start+(-1)^Start*S/S(end);

% Optional down-sampling to reduce the number of datapoints
lt = 900;
ds = max(floor(length(S)/lt),1);
S = S(1:ds:end);
V = T.Voltage_V(1:ds:end);

% Define the OCP/OCV function
spl = spline(S,V); % produces a piecewise polynomial for use by PPVAL - can use spline, pchip or makima
OCP = @(S) ppval(spl,S);

end
