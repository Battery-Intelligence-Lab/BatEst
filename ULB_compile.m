function ULB_compile(ModelName)
% A function to comile the saved output from ULB_main.

allout = [];

%% Iterations
% Load index of measurement data to access multiple files
% index_filename = 'Data/test_index.parquet';
folder = '../../../Data from Brussels/Final Dataset/';
index_filename = 'Test_Index.parquet';
index = parquetread([folder index_filename]);

% Set the cell number(s)
cell_num = [3,3.2,3.3,4,4.2,4.3,5,6,7,8,9,9.2,10,10.2,11,11.2,20,21,21.2,22];
for n = cell_num

OCV_index = find(index.Cell_Number==single(n) & index.OCV_Test);
Performance_index = find(index.Cell_Number==single(n) & index.Performance_Test);
% Select only Performance tests that occur alongside an OCV test
Performance_index = Performance_index([1,7:5:end]);
file_index = [OCV_index, Performance_index(1:length(OCV_index))]';
filenames = index.File_Name(file_index(:));
for k = 1:length(filenames)/2

% Load
out = parquetread(['Data/Brussels/out_' ModelName '_' num2str(n) '_' num2str(k) '.parquet']);

% Compile
if ~istable(allout)
    allout = out;
else
    allout = outerjoin(allout,out,'MergeKeys',true);
end

end
end

% Sort by index columns
allout = movevars(allout,'Cell_Number','Before',1);
allout = movevars(allout,'Test_Number','After','Cell_Number');
allout = movevars(allout,'RowN','After','Test_Number');
allout = sortrows(allout,{'Cell_Number','Test_Number','RowN'});

% Save compiled output
save_output(allout,['Data/Brussels/allout_' ModelName],true);

end

