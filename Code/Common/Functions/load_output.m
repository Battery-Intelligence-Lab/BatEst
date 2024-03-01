function params = load_output(out,j)
% Load the parameter values from a previous run. The input is a table
% containing a column variable for each parameter, with the last row
% corresponding to the most recent run.

% Extract the j-th or last row
if nargin==2
    out = out(j,:);
else
    out = out(end,:);
end

% Sort the table columns alphabetically
sortedNames = sort(out.Properties.VariableNames);
out = out(:,sortedNames);

% Get the variable names
par_names = out.Properties.VariableNames;

% Find and merge split variables
found_split = '';
for i = 1:length(par_names)
    if endsWith(par_names{i},'_1')
        found_split = par_names{i}(1:end-2);
        if ~isnumeric(out.(par_names{i})) || ~isnan(out.(par_names{i}))
            out.(found_split) = out.(par_names{i});
        end
        out = removevars(out,par_names{i});
    elseif ~isempty(found_split) && startsWith(par_names{i},[found_split '_'])
        if ~isnumeric(out.(par_names{i})) || ~isnan(out.(par_names{i}))
            out.(found_split) = [out.(found_split), out.(par_names{i})];
        end
        out = removevars(out,par_names{i});
    else
        found_split = '';
    end
end

% Update the variable names
par_names = out.Properties.VariableNames;

% Unpack the parameters
for i = 1:length(par_names)
    if any(strncmp(par_names{i},{'RowN','RMSE'},4))
        % Do not load these values
    elseif isempty(par_names{i})
        % This was a split variable
    else
        params.(par_names{i}) = out.(par_names{i});
    end
end

end
