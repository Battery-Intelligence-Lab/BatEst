function [cycle_step, DataType] = data_selection(j)
% Select which part of the Dataset using 'step_cycle' to reference the
% Cycle_Index and Step_Index of the relevant rows in the Dataset and name
% the type of protocol using 'DataType'. These parameters are optional and
% can be left empty, in which case all data will be used. Otherwise, set
% the first entry of 'cycle_step' equal to the Cycle_Index and the second
% equal to the Step_Index. To include a sequence of steps, add a third
% entry to 'cycle_step' equal to the last Step_Index in the sequence.

% Select subset of data
if j==1
    cycle_step = [0;10];
    DataType = 'Pseudo-OCV charge';
elseif j==2
    cycle_step = [0;5];
    DataType = 'Relaxation';
elseif j>2
    cycle_step = [0;6];
    DataType = 'CCCV charge';
end

end
