function plot_OCV_params(out)
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
    ind = find(out.Test_Number==i);
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
    
end

% Save figures
% saveplot(fig1,['Capacities_' type]);

end
