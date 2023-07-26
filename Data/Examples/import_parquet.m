function Dataset = import_parquet(filename)
% A function to import parquet files with different column names to those
% used by default in the code.

try
    % Column names from the import file (change as needed)
    column_names_from_file = {'Test_Time_s','Cycle_Index','Step_Index',...
    'Current_A','Voltage_V','Temperature_C'}; % ,'External_Temp_C'};
    
    % Import data into a table
    Dataset = parquetread(filename, ...
	    'SelectedVariableNames', column_names_from_file);
catch ME
    warning('The columns names currently written in import_parquet are:')
    disp(column_names_from_file);
    throw(ME);
end

% Adjust names to cope with replacement of special characters during import
column_names_from_file = regexprep(column_names_from_file, ...
    {'(',')'},{'_','_'});

% Column names required for analysis (don't change the spelling)
column_names_for_analysis = {'Test_Time_s','Cycle_Index','Step_Index',...
    'Current_A','Voltage_V','Temperature_C'}; % ,'External_Temp_C'};

% Rename some table headings for consistency
Dataset.Properties.VariableNames = ...
    regexprep(Dataset.Properties.VariableNames, ...
	column_names_from_file, column_names_for_analysis);

% Ensure that all values are of numeric type double
Dataset = convertvars(Dataset,column_names_for_analysis,'double');

end
