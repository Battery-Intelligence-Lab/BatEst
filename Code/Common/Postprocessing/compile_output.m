function allout = compile_output(folder,ModelName)
% A function to compile the existing output, saved as parquet files in the
% specified folder, into a single output file.

allout = [];

%% Iterations - copy (n,k) iterations from  main.m
% Load index of measurement data to access multiple files
index_name = 'Data\Examples\Test_Index.parquet';
index = parquetread(index_name);

% Set the cell number(s)
cell_num = [3];
for n = cell_num

% Select files from the index
file_index = find(index.Cell_Number==n & index.Performance_Test);
filenames = index.File_Name(file_index(:));
for k = 1:length(filenames)


%% Compilation
% Load all files corresponding to the same model in the specified folder
allout = parquetread([folder '\out_' ModelName '_' num2str(n) '_' num2str(k) '.parquet']);

% Compile output tables
if ~istable(allout)
    allout = allout;
else
    allout = outerjoin(allout,allout,'MergeKeys',true);
end

end
end

% Sort by index columns
allout = movevars(allout,'Cell_Number','Before',1);
allout = movevars(allout,'Test_Number','After','Cell_Number');
allout = movevars(allout,'RowN','After','Test_Number');
allout = sortrows(allout,{'Cell_Number','Test_Number','RowN'});

% Save compiled output
save_output(allout,[folder '\allout_' ModelName],true);


end
