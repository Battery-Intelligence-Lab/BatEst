function params = convert_params(params,new_params)
% A function to take new parameter values from the second input and
% overwrite the corresponding entries in the first input.

% Get list of fieldnames
fields = fieldnames(params);
new_fields = fieldnames(new_params);

% Remove function handles
for i = 1:length(fields)
    if isa(params.(fields{i}),'function_handle')
        params = rmfield(params,fields{i});
    end
end
for i = 1:length(new_fields)
    if isa(new_params.(new_fields{i}),'function_handle')
        new_params = rmfield(new_params,new_fields{i});
    end
end

% Update the list of fieldnames
fields = fieldnames(params);
new_fields = fieldnames(new_params);

% Remove the estimation-specific fields
clear_fields = {'c','nop','c_ind','fac','uncert','lb','ub','p','pdim', ...
                'j','tt','uu','yy','fs','RMSE_mV','RMSE_Ts'};
params = rmfield(params,intersect(clear_fields,fields));
new_params = rmfield(new_params,intersect(clear_fields,new_fields));

% Keep the type of model, data selection and corresponding variables
keep_fields = {'Type','cycle_step','DataType'};
if ~strcmp(params.Type,new_params.Type)
    keep_fields = [keep_fields,{'X0','c0'}];
end

% Update the remaining fields
new_fields = setdiff(new_fields,[clear_fields,keep_fields]);
for i = 1:length(new_fields)
    params.(new_fields{i}) = new_params.(new_fields{i});
end

end
