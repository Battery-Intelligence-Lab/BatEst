function plot_EHMT_params(out)
% A function to plot the model parameters and error measures for all
% results saved in the output table 'out'. Use compile_output.m to create
% a table with the results for multiple cells and/or tests.

% Compute capacities
Qn = out.Qn./out.hr;
Qp = Qn./out.nu;
QLi = Qp.*out.miu;

% Generate figures
fig1 = figure; hold on; sgtitle('Capacities');
xlimits = [0,25];
ylimits = [3.25,4.45];
subplot(1,3,1); hold on;
xlabel('Cell number');
ylabel('Negative electrode capacity (Ah)');
xlim(xlimits); ylim(ylimits);
subplot(1,3,2); hold on;
xlabel('Cell number');
ylabel('Positive electrode capacity (Ah)');
xlim(xlimits); ylim(ylimits);
subplot(1,3,3); hold on;
xlabel('Cell number');
ylabel('Cyclable lithium inventory (Ah)');
xlim(xlimits); ylim(ylimits);

fig2 = figure; hold on; sgtitle('RMSEs');
xlimits = [0,25];
subplot(1,2,1); hold on;
xlabel('Cell number');
ylabel('Voltage RMSE (mV)');
xlim(xlimits);
subplot(1,2,2); hold on;
xlabel('Cell number');
ylabel('Temperature RMSE (K)');
xlim(xlimits);

fig3 = figure; hold on; sgtitle('Thermal and diffusion');
xlimits = [0,25];
subplot(1,3,1); hold on;
xlabel('Cell number');
ylabel('Internal heat transfer timescale (s)');
xlim(xlimits); ylim([0,20]);
subplot(1,3,2); hold on;
xlabel('Cell number');
ylabel('External heat transfer timescale (s)');
xlim(xlimits); ylim([0,4]);
subplot(1,3,3); hold on;
xlabel('Cell number');
ylabel('Diffusion timescale (s)');
xlim(xlimits); %ylim(ylimits);

fig4 = figure; hold on; sgtitle('Dynamics');
xlimits = [0,25];
subplot(1,3,1); hold on;
xlabel('Cell number');
ylabel('Anode surface-particle volume ratio (non-dim.)');
xlim(xlimits); %ylim(ylimits);
subplot(1,3,2); hold on;
xlabel('Cell number');
ylabel('Reference exchange current in the negative electrode (A)');
xlim(xlimits); %ylim(ylimits);
subplot(1,3,3); hold on;
xlabel('Cell number');
ylabel('Film resistance (Ohm)');
xlim(xlimits); %ylim(ylimits);

% Setup
% set_plotting_defaults
LineSpec.LineStyle = '-';
LineSpecX.LineStyle = 'none';
LineSpecX.Marker = 'x';
colours = get(gca,'colororder');

% Plot each set of tests
for i = 1:4
    LineSpec.Color = colours(i,:);
    LineSpecX.Color = colours(i,:);
    
    % Find the final estimation results
    ind = find(out.Test_Number==i & out.RowN==max(out.RowN));
    xx = out.Cell_Number(ind);
    
    % Step 1 parameters
    figure(fig1);
    subplot(1,3,1); hold on;
    plot(xx,Qn(ind),LineSpecX);
    plot(xlimits,mean(Qn(ind),'omitmissing')*[1,1],LineSpec);
    subplot(1,3,2); hold on;
    plot(xx,Qp(ind),LineSpecX);
    plot(xlimits,mean(Qp(ind),'omitmissing')*[1,1],LineSpec);
    subplot(1,3,3); hold on;
    plot(xx,QLi(ind),LineSpecX);
    plot(xlimits,mean(QLi(ind),'omitmissing')*[1,1],LineSpec);
    
    % RMSE
    figure(fig2);
    subplot(1,2,1); hold on;
    plot(xx,out.RMSE_mV(ind),LineSpecX);
    subplot(1,2,2); hold on;
    plot(xx,out.RMSE_Ts(ind),LineSpecX);
    
    % Find OCVT results for the temperature parameters with  good fit
    ind = find(out.Test_Number==i & out.RowN==2 & out.tauT<50);
    xx = out.Cell_Number(ind);
    
    % Step 2 parameters
    figure(fig3);
    subplot(1,3,1); hold on;
    plot(xx,out.tauT(ind),LineSpecX);
    plot(xlimits,mean(out.tauT(ind),'omitmissing')*[1,1],LineSpec);
    subplot(1,3,2); hold on;
    plot(xx,out.tauA(ind),LineSpecX);
    plot(xlimits,mean(out.tauA(ind),'omitmissing')*[1,1],LineSpec);
    
    % Find final results
    ind = find(out.Test_Number==i & out.RowN==max(out.RowN));
    xx = out.Cell_Number(ind);
    
    % Step 3 parameters
    figure(fig3);
    subplot(1,3,3); hold on;
    plot(xx,out.tau_ref(ind),LineSpecX);
    plot(xlimits,mean(out.tau_ref(ind),'omitmissing')*[1,1],LineSpec);
    
    % Find final results with a good voltage fit
    % ind = find(out.Test_Number==i & out.RowN==max(out.RowN) & out.RMSE_mV<8);
    % xx = out.Cell_Number(ind);
    
    % Step 4 parameters
    figure(fig4);
    subplot(1,3,1); hold on;
    plot(xx,out.b(ind),LineSpecX);
    plot(xlimits,mean(out.b(ind),'omitmissing')*[1,1],LineSpec);
    subplot(1,3,2); hold on;
    plot(xx,out.In_ref(ind),LineSpecX);
    plot(xlimits,mean(out.In_ref(ind),'omitmissing')*[1,1],LineSpec);
    subplot(1,3,3); hold on;
    plot(xx,out.Rf(ind),LineSpecX);
    plot(xlimits,mean(out.Rf(ind),'omitmissing')*[1,1],LineSpec);
    
end

% Save figures
% saveplot(fig1,['Capacities_' type]);
% saveplot(fig2,['Thermal_Diffusion_' type]);
% saveplot(fig3,['Dynamics_' type]);

end
