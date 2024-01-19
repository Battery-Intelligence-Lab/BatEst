function sol = unpack_data(data,params,j)
% This function saves the data in the structure required by the estimation
% code. For guidance on importing data, see the DATA_PREP_GUIDE in /Data.
% The states are unknown, but estimates for the initial states may
% optionally be passed to the next step along with other parameter values
% saved within the 'sol' structure. The vectors must be column vectors.

% Unpack parameters
[mn, Um, Vcut, Vrng, TtoK, CtoK, Trng, Tamb, X0, Qn, cycle_step, DataType, ...
    verbose] = ...
    struct2array(params,{'mn','Um','Vcut','Vrng','TtoK','CtoK','Trng','Tamb', ...
                         'X0','Qn','cycle_step','DataType','verbose'});
if ~any(Trng)
    [TtoK, CtoK, Trng] = deal(1); % no scaling
end

% Ensure that time series data is of type double
column_names = data.Properties.VariableNames;
for i = 1:length(column_names)
    if isa(data.(column_names{i}),'single')
        data = convertvars(data,column_names{i},'double');
    end
end

% Locate time points
if any(cycle_step)
    cycle = cycle_step(1);
    step = cycle_step(2);
    step_end = cycle_step(end);
    start = find((data.Cycle_Index==cycle).*(data.Step_Index==step),1,'first');
    finish = start+find((data(start+1:end,:).Cycle_Index==cycle) ...
                        .*(data(start+1:end,:).Step_Index==step_end),1,'last');
    if ~any(finish) || finish<start
        error(['There are no points in the specified section, please ' ...
               'check the cycle and step numbers.']);
    end
else
    start = 1;
    finish = length(data.Test_Time_s);
end
tpoints = start:finish;

% Check length of dataset
if tpoints(end)-tpoints(1) > 50*3600
    error(['This dataset is over 50 hours long, please consider fitting ' ...
           'a smaller subset of the data by updating the data selection ' ...
           'parameters in cell_parameters.m, or simply comment out this ' ...
           'error in unpack_data.m if you would like to continue.']);
end


%% Compute initial values and throughtput

% Preallocate initial states
X_init = []; S_init = []; T_init = [];

% Extract initial voltage and temperature
i = max([1,find(data.Current_A(1:start-1)==0,1,'last')]);
V_init = data.Voltage_V(i);
if verbose
    disp(['Starting voltage is ' num2str(V_init) ' V.']);
end
if ismember('Temperature_C', data.Properties.VariableNames)
    T_init = data.Temperature_C(i);
    if verbose
        disp(['And surface temperature is ' num2str(T_init) ' C.']);
    end
end

% Estimate initial states
if strcmp(DataType,'Relaxation')
    % Assume zero current and determine from terminal voltage
    X_init = initial_SOC(params,data.Voltage_V(finish),0.1);
    S_init = initial_CSC(params,data.Voltage_V(start),X_init);
elseif abs(data.Current_A(i))<0.05
    % Assume measurement starts at steady state
    [X_init, S_init] = deal(initial_SOC(params,V_init,0.5));
end
if verbose && any(X_init)
    disp(['The corresponding SOC estimate is ' num2str(X_init) '.']);
end

% Compute charge throughput
QT = trapz(data.Test_Time_s(i:finish),data.Current_A(i:finish));
if verbose
    disp(['The total charge throughput is ' num2str(QT/Qn) ' Qn.']);
end


%% Unpack sample data into solution structure

% Optional down-sampling to reduce number of datapoints to target length
target = 900;
ds = max(floor(length(tpoints)/target),1);
tpoints = tpoints(1:ds:end);

% Unpack data from table
tsol(:,1) = data.Test_Time_s(tpoints)-data.Test_Time_s(tpoints(1));
ysol(:,1) = data.Voltage_V(tpoints);
usol(:,1) = data.Current_A(tpoints);
if ismember('External_Temp_C', data.Properties.VariableNames) ...
    && ismember('Temperature_C', data.Properties.VariableNames)
    usol(:,2) = data.External_Temp_C(tpoints); % ambient
    ysol(:,2) = data.Temperature_C(tpoints); % surface
    y2_surface_temp = true; % there is surface temperature data
elseif ismember('Temperature_C', data.Properties.VariableNames)
    usol(:,2) = data.Temperature_C(tpoints); % ambient
    y2_surface_temp = false; % no surface temperature data
else
    usol(:,2) = Tamb-CtoK; % assume constant ambient
    y2_surface_temp = false; % no surface temperature data
end

% Make sure that the vectors are column vectors
if size(tsol,2)>1 || size(usol,1)~=size(tsol,1) || size(ysol,1)~=size(tsol,1)
    error('The vectors tsol, ysol and usol must be column vectors.');
end

% Compute dVdt capped by maximum expected gradient, dIdt and dTdt
ind = find(([tsol(2:end); tsol(end)+1]-[-1; tsol(1:end-1)]) > 1e-7);
tdiff = @(t,y) (y(ind+2,1)-y(ind,1))./(t(ind+2,1)-t(ind,1));
y3 = 2+y2_surface_temp;
ysol(ind,y3) = tdiff([-1; tsol; tsol(end)+1],[ysol(1,1); ysol(:,1); ysol(end,1)]);
ysol(:,y3) = sign(ysol(:,y3)).*min(0.005,abs(ysol(:,y3)))*mn; % V/min
usol(ind,4) = tdiff([-1; tsol; tsol(end)+1],[0; usol(:,1); 0]); % A/s
usol(ind,5) = tdiff([-1; tsol; tsol(end)+1],[ysol(1,2); ysol(:,2); ysol(end,2)]); % K/s

% Ensure that there are no duplicate times
[tsol,it] = unique(tsol);

% Rescale and pack up vectors
sol.tsol(:,1) = tsol;
sol.ysol(:,1) = (ysol(it,1)-Vcut)/Vrng;
sol.y2_surface_temp = y2_surface_temp;
if y2_surface_temp
    sol.ysol(:,2) = (ysol(it,2)+CtoK-TtoK)/Trng;
end
sol.ysol(:,y3) = ysol(it,y3)/Vrng;
sol.usol(:,1) = usol(it,1)/Um;
sol.usol(:,2) = (usol(it,2)+CtoK-TtoK)/Trng;
sol.usol(:,3) = sol.ysol(:,1);
sol.usol(:,4) = usol(it,4)/Um;
sol.usol(:,5) = usol(it,5)/Trng;
sol.xsol = NaN(length(it),length(X0));
sol.DataType = DataType;


%% Extract further information from the dataset

% Estimate the "coulombic efficiency" (CE)
sol.CE = 1;
if (contains(DataType,'CV charge') && ~contains(DataType,'OCV') ...
        || contains(DataType,'Cycling')) && any(X_init) && abs(QT/Qn)>0.01
    % Include any relaxation period after subset of data
    trailing_current = [data.Current_A(finish+1:end); 1];
    relax_end = finish+find(trailing_current~=0,1,'first')-1;
    V_end = data.Voltage_V(relax_end);
    X_end = initial_SOC(params,V_end,0.9);
    % Determine CE from change between equilibrium states
    X_input = X_end-X_init;
    CE = X_input*Qn/QT;
    if verbose
        disp(['Coulombic efficiency of ' num2str(CE)]);
    end
    if CE < 0.95
        disp('Coulombic efficiency < 95% ... discarding ...')
    elseif CE > 1
        disp('Coulombic efficiency > 100% ... discarding ...')
    else
        sol.CE = CE;
    end
end

% Use the average temperature as reference
if strcmp(DataType,'Relaxation') ...
        && ismember('External_Temp_C', data.Properties.VariableNames)
    sol.Tref = mean(data.External_Temp_C(tpoints))+CtoK;
    if verbose
        disp(['Reference temperature is ' num2str(sol.Tref) ' K']);
    end
end

% Rescale and pass on initial state estimates
if any(X_init), sol.init.X = X_init; end
if any(S_init), sol.init.S = S_init; end
if any(T_init), sol.init.T = (T_init+CtoK-TtoK)/Trng; end


end
