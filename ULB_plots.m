
% Close target figures if open
for i = 1:4
    try
        close(figure(i));
    catch
    end
end

% Plot the parameter trends
out = parquetread('Data/ULB/Run 6/Cell20/out_EHMT_402_11.parquet');
plot_EHM_params(out,[0,1]);
out = parquetread('Data/ULB/Run 6/Cell21/out_EHMT_435_1.parquet');
plot_EHM_params(out,2);
out = parquetread('Data/ULB/Run 6/Cell21.2/out_EHMT_467_11.parquet');
plot_EHM_params(out,2);
out = parquetread('Data/ULB/Run 6/Cell22/out_EHMT_500_11.parquet');
plot_EHM_params(out,3);
out = parquetread('Data/ULB/Run 6/Cell3/out_EHMT_70_11.parquet');
plot_EHM_params(out,4);
out = parquetread('Data/ULB/Run 6/Cell3.2/out_EHMT_105_11.parquet');
plot_EHM_params(out,4);
out = parquetread('Data/ULB/Run 6/Cell3.3/out_EHMT_143_11.parquet');
plot_EHM_params(out,4);
out = parquetread('Data/ULB/Run 6/Cell4/out_EHMT_153_11.parquet');
plot_EHM_params(out,5);
out = parquetread('Data/ULB/Run 6/Cell4.2/out_EHMT_160_4.parquet');
plot_EHM_params(out,5);
out = parquetread('Data/ULB/Run 6/Cell4.3/out_EHMT_167_11.parquet');
plot_EHM_params(out,5);
out = parquetread('Data/ULB/Run 6/Cell5/out_EHMT_175_11.parquet');
plot_EHM_params(out,6);
out = parquetread('Data/ULB/Run 6/Cell6/out_EHMT_184_11.parquet');
plot_EHM_params(out,6);
out = parquetread('Data/ULB/Run 6/Cell7/out_OCV_210_1.parquet');
plot_EHM_params(out,6);
out = parquetread('Data/ULB/Run 6/Cell8/out_EHMT_223_11.parquet');
plot_EHM_params(out,6);
out = parquetread('Data/ULB/Run 6/Cell9/out_EHMT_258_11.parquet');
plot_EHM_params(out,6);
out = parquetread('Data/ULB/Run 6/Cell9.2/out_EHMT_274_11.parquet');
plot_EHM_params(out,6);
out = parquetread('Data/ULB/Run 6/Cell10/out_EHMT_283_11.parquet');
plot_EHM_params(out,6);
out = parquetread('Data/ULB/Run 6/Cell10.2/out_EHMT_294_11.parquet');
plot_EHM_params(out,6);
out = parquetread('Data/ULB/Run 6/Cell11/out_EHMT_331_11.parquet');
plot_EHM_params(out,7);
out = parquetread('Data/ULB/Run 6/Cell11.2/out_EHMT_369_11.parquet');
plot_EHM_params(out,7);

% Add legend to one of the subplots
figure(2);
subplot(3,1,2);
legend({'1C CCCV without OCV','C/2 without OCV','C/2 without OCV', ...
        'NCCV without OCV','1C CCCV','1C CCCV','1C CCCV','2C CCCV', ...
        '2C CCCV','2C CCCV','NCCV','NCCV','NCCV','NCCV','NCCV','NCCV', ...
        'NCCV','NCCV','C/2 CCCV','C/2 CCCV'});
