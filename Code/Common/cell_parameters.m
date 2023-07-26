function params = cell_parameters(j)
% Set the parameter values for the cell (which are not model-specific) and
% store them in a structure.

% Set the nominal capacity and rate parameters
Qnom = 2.9;       % nominal capacity (Ah)
% Note that Qnom can be different from the theoretical capacity and is only
% used to determine the nominal C-rate (=Qnom).
Crate = Qnom;     % nominal 1C current density (A)

% Total time
mn = 60;          % one minute (s)
hr = 3600;        % one hour (s)

% Define SOC limits
Sd = 0.1;         % SOC in discharged state (non-dim.)
Sc = 0.9;         % SOC in fully charged state (non-dim.)
S0 = Sd;          % initial SOC (non-dim.)

% Temperatures
CtoK = 273.15;    % Celsius to Kelvin conversion (K)
Tamb = 25+CtoK;   % ambient temperature (K)
Tref = 25+CtoK;   % reference temperature (K)

% Safety limits
Um = 3*Crate;     % maximum current amplitude (A)
Vmax = 4.2;       % upper voltage limit (V)
Vcut = 2.5;       % lower voltage limit (V)
Vrng = Vmax-Vcut; % voltage range (V)
Tmax = 40;        % upper temperature limit (deg. C)
Tmin = 25;        % lower temperature limit (deg. C)
Trng = Tmax-Tmin; % temperature range (K)
TtoK = Tmin+CtoK; % temperature conversion factor (K)


%% Open-circuit potential
% Select either two electrode potentials or one OCV function: stored either
% as a Matlab function or as a data file using the name of the file(s)
% including the file format. For example,
% OCP_filename = {'Positive.parquet','Negative.parquet'};
% in this order, or
% OCP_filename = {'Example_OCV.parquet'};

% Set OCP filename(s)
OCP_filename = {'Raj2020_NCA.parquet','Raj2020_Graphite.parquet'};
% OCP_filename = {'LGM50_NMC811','LGM50_GraphiteSiOx'};
% OCP_filename = {'Hu2012_LiNMC'};


%% Data selection
% Select which part of the Dataset using 'step_cycle' to reference the
% Cycle_Index and Step_Index of the relevant rows in the Dataset and name
% the type of protocol using 'DataType'. These parameters are optional and
% can be left empty, in which case all data will be used. Otherwise, set
% the first entry of 'cycle_step' equal to the Cycle_Index and the second
% equal to the Step_Index. To include a sequence of steps, add a third
% entry to 'cycle_step' equal to the last Step_Index in the sequence.

% Create empty properties
cycle_step = [];
DataType = '';

% Select subset of data
% if j==1
%     cycle_step = [0;10];
%     DataType = 'Pseudo-OCV charge';
% elseif j==2
%     cycle_step = [0;5];
%     DataType = 'Relaxation';
% elseif j>2
%     cycle_step = [0;6];
%     DataType = 'CCCV charge';
% end


%% Compile all parameters into the params structure
vars = setdiff(who,{'params','vars'});
for i=1:length(vars), params.(vars{i}) = eval(vars{i}); end


end
