function out = tabulate_output(params,out,n,k)
% A function to sort and save the model parameters and estimation results
% in a Matlab table. The inputs n and k are optional.

if nargin>2
    params.Cell_Number = n;
    params.Test_Number = k;
end

% Remove function handles and structure arrays
params = convert_params(params,params);

% Flip column vectors to row vectors
fields = fieldnames(params);
for i = 1:length(fields)
    if isnumeric(params.(fields{i}))
        params.(fields{i}) = params.(fields{i})';
    elseif iscell(params.(fields{i}))
        if ischar(params.(fields{i}){1})
            % Keep character arrays
        elseif islogical(params.(fields{i}))
            params.(fields{i}) = double(params.(fields{i}));
        else
            params.(fields{i}) = params.(fields{i}){:};
        end
    end
end

% Convert the params structure to a table
if ~istable(out)
    out = [table(1,'VariableNames',{'RowN'}) ...
           struct2table(params,'AsArray',true)];
    out = splitvars(out);
else
    out2 = [table(1+max(out.RowN),'VariableNames',{'RowN'}) ...
            struct2table(params,'AsArray',true)];
    out2 = splitvars(out2);
    out = outerjoin(out,out2,'MergeKeys',true);
end

% Sort the table columns alphabetically
sortedNames = sort(out.Properties.VariableNames);
out = out(:,sortedNames);

% Sort the rows by cell/test number and iteration number
if nargin>2
    out = movevars(out,'Cell_Number','Before',1);
    out = movevars(out,'Test_Number','After','Cell_Number');
    out = movevars(out,'RowN','After','Test_Number');
    out = sortrows(out,{'Cell_Number','Test_Number','RowN'});
    out = sortrows(out,{'Cell_Number','Test_Number','RowN'});
else
    out = movevars(out,'RowN','Before',1);
    out = sortrows(out,{'RowN'});
end

end
