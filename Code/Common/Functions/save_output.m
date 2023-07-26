function save_output(table,filename,overwrite)
% A function to save a table as a .parquet file. The inputs are the table,
% the desired name (and path) of the file and the option to overwrite any
% existing file.

if nargin==2
    overwrite = false;
end

if ~overwrite && isfile([filename '.parquet'])
    warning(['This file already exists, so the output has not been ' ...
             'saved. To overwrite this file, use the command: ' ...
             'save_output(filename,out,true); with your chosen filename.']);
    OK = false;
else
    OK = true;
end

if OK
    % Save output as a parquet file
    parquetwrite([filename '.parquet'],table, ...
                 'Version','1.0','VariableCompression','gzip');
end

end
