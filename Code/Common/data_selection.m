function [cycle_step, DataType] = data_selection(j)
% Select which part of the Dataset using 'step_cycle' to reference the
% Cycle_Index and Step_Index of the relevant rows in the Dataset and name
% the type of protocol using 'DataType'. These parameters are optional and
% can be left empty, in which case all data will be used. Otherwise, set
% the first entry of 'cycle_step' equal to the Cycle_Index and the second
% equal to the Step_Index. To include a sequence of steps, add a third
% entry to 'cycle_step' equal to the last Step_Index in the sequence.

% Select subset of data
% cycle_step = [1;5];
if j(2)==3
    cycle_step = j;
    DataType = 'Pseudo-OCV charge';
elseif any(j(2)==[9,10,11])
    cycle_step = j;
    DataType = 'Relaxation';
else
    cycle_step = j;
    DataType = 'CCCV charge';
end
% [j;6] for Campaign 003, [j;7;8] for Campaign 009,
% [j,16,22], j=1:3, for pulse data, [1;11] for C/2 CCCV charge,
% [1,3,4] for pseudo-OCV charge and discharge, [1;10] for relaxation

end
