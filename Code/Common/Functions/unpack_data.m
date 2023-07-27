function sol = unpack_data(data,params,j)
% This function saves the data in the structure required by the estimation
% code. For guidance on importing data, see the DATA_PREP_GUIDE in /Data.
% The states are unknown, but estimates for the initial states may
% optionally be passed to the next step along with other parameter values
% saved within the 'sol' structure. The vectors must be column vectors.

% Unpack parameters
[Um, Vcut, Vrng, TtoK, CtoK, Trng, Tamb, X0, Q, cycle_step, DataType, ...
    verbose] = ...
    struct2array(params,{'Um','Vcut','Vrng','TtoK','CtoK','Trng','Tamb', ...
                         'X0','Q','cycle_step','DataType','verbose'});
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

% Optional down-sampling to reduce the number of datapoints
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
elseif ismember('Temperature_C', data.Properties.VariableNames)
    usol(:,2) = data.Temperature_C(tpoints); % ambient
else
    usol(:,2) = Tamb-CtoK; % assume constant ambient
end

% Make sure that the vectors are column vectors
if size(tsol,2)>1 || size(usol,1)~=size(tsol,1) || size(ysol,1)~=size(tsol,1)
    error('The vectors tsol, ysol and usol must be column vectors.');
end

% Ensure that there are no duplicate times
[tsol,it] = unique(tsol);

% Rescale and pack up vectors
sol.tsol(:,1) = tsol;
sol.ysol(:,1) = (ysol(it,1)-Vcut)/Vrng;
if size(ysol,2)==2
    sol.ysol(:,2) = (ysol(it,2)+CtoK-TtoK)/Trng;
end
sol.usol(:,1) = usol(it,1)/Um;
if size(usol,2)==2
    sol.usol(:,2) = (usol(it,2)+CtoK-TtoK)/Trng;
    sol.usol(:,3) = sol.ysol(:,1);
end
sol.xsol = NaN(length(it),length(X0));
sol.DataType = DataType;


%% Extract further information from the dataset

% Compute charge throughput
QT = trapz(data.Test_Time_s(start:finish),data.Current_A(start:finish));
if verbose
    disp(['The total charge throughput is ' num2str(QT/Q) ' Q.']);
end

% Pass on initial voltage and temperature
i = max(1,start-1);
V_init = data.Voltage_V(i);
if verbose
    disp(['Starting voltage is ' num2str(V_init) ' V.']);
end
if abs(data.Current_A(i))<0.02
    % Assume measurement starts at steady state
    [X_init, S_init] = deal(initial_SOC(params,V_init,0.5));
    if verbose
        disp(['The corresponding SOC estimate is ' num2str(X_init) '.']);
    end
else
    % Do not pass any SOC estimate
    [X_init, S_init] = deal(NaN);
end
if length(X0)==1
    sol.xsol(1,1) = X_init;
else
    sol.xsol(1,1:2) = [X_init, S_init];
end
T_init = data.Temperature_C(i);
if verbose
    disp(['And surface temperature is ' num2str(T_init) ' C.']);
end

% Pass on model parameters
if contains(DataType,'charge') && ~contains(DataType,'OCV')
    % Determine initial states from terminal voltage
    relax_end = start+find((data(start+1:end,:).Cycle_Index==cycle) ...
                        .*(data(start+1:end,:).Step_Index==step_end+1),1,'last');
    V_end = data.Voltage_V(relax_end);
    X_end = initial_SOC(params,V_end,0.9);
    X_input = X_end-X_init;
    sol.CE = X_input*Q/QT; % coulombic efficiency
    if verbose
        disp(['Coulombic efficiency of ' num2str(sol.CE)]);
    end
elseif strcmp(DataType,'Relaxation')
    % Estimate initial states from terminal voltage
    X_init = initial_SOC(params,data.Voltage_V(finish),0.1);
    S_init = initial_CSC(params,data.Voltage_V(start),X_init);
    sol.CE = 1;
    % Use the average temperature as reference
    if ismember('External_Temp_C', data.Properties.VariableNames)
        sol.Tref = mean(data.External_Temp_C(tpoints))+CtoK;
        if verbose
            disp(['Reference temperature is ' num2str(sol.Tref) ' K']);
        end
    end
end


end
