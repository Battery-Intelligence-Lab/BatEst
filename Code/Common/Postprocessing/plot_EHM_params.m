function plot_EHM_params(out,set_numbers)
% A function to plot the model parameters for results saved in the output
% table 'out'. Use the second input set_numbers to iterate over cells.

if nargin==1
    set_numbers = [0,1];
end

% Compute capacities
Qn = out.Qn./out.hr;
Qp = Qn./out.nu;
QLi = Qp.*out.miu;

if any(set_numbers==0)
    xlimits = [0,out.Test_Number(end)];
    
    % Generate figure for capacity parameters
    fig1 = figure; hold on;
    ax11 = subplot(3,1,1); hold on; title('Positive electrode');
    % xlabel('Test number');
    ylabel('Capacity (Ah)');
    xlim(xlimits);
    ax12 = subplot(3,1,2); hold on; title('Negative electrode');
    % xlabel('Test number');
    ylabel('Capacity (Ah)');
    xlim(xlimits);
    ax13 = subplot(3,1,3); hold on; title('Cyclable lithium inventory');
    xlabel('Test number');
    ylabel('Capacity (Ah)');
    xlim(xlimits); %ylim(ylimits);
    
    % Generate figure for dynamic parameters
    fig2 = figure; hold on;
    ax21 = subplot(3,1,1); hold on; title('Diffusion in the negative electrode');
    % xlabel('Test number');
    ylabel('Timescale (s)');
    xlim(xlimits);
    ax22 = subplot(3,1,2); hold on; title('Exchange current in the negative electrode');
    % xlabel('Test number');
    ylabel('Reference current (A)');
    xlim(xlimits);
    ax23 = subplot(3,1,3); hold on; title('Film resistance')
    xlabel('Test number');
    ylabel('Resistance (Ohm)');
    xlim(xlimits);

    % Generate figure for RMSE
    fig3 = figure; hold on;
    xlabel('Test number');
    ylabel('RMSE (mV)');
    xlim(xlimits);

    % Resize figures and link axes
    linkaxes([ax11,ax12,ax13],'x');
    linkaxes([ax21,ax22,ax23],'x');
    for ax = [ax11,ax12,ax21,ax22]
        set(ax,'XTick',[]);
    end

else
    fig1 = figure(1);
    ax11 = subplot(3,1,1); hold on;
    ax12 = subplot(3,1,2); hold on;
    ax13 = subplot(3,1,3); hold on;
    fig2 = figure(2);
    ax21 = subplot(3,1,1); hold on;
    ax22 = subplot(3,1,2); hold on;
    ax23 = subplot(3,1,3); hold on;
    fig3 = figure(3); hold on;
end

if any(set_numbers==0) && length(set_numbers)==1
    return;
end

% Setup
LineSpec.LineStyle = '-';
LineSpec.LineWidth = 1;
LineSpecX.LineStyle = 'none';
LineSpecX.Marker = 'x';
LineSpecO.LineStyle = 'none';
LineSpecO.Marker = 'o';
colours = get(gca,'colororder');

% Plot each set of tests
for i = set_numbers(set_numbers>0)
    colour = colours(mod(i-1,7)+1,:);
    LineSpec.Color = colour;
    LineSpecX.Color = colour;
    LineSpecO.MarkerFaceColor = colour;
    
    % Find the performance tests
    % ind = find(strcmp(out.DataType,"OCV scan"));
    xx = out.Test_Number; %(ind);
    
    % Capacity parameters
    figure(fig1);
    subplot(ax11);
    plot(xx,Qn(ind),LineSpecO);
    add_linear_fit(xx,Qn(ind),LineSpec);
    subplot(ax12);
    plot(xx,Qp(ind),LineSpecO);
    add_linear_fit(xx,Qp(ind),LineSpec);
    subplot(ax13);
    plot(xx,QLi(ind),LineSpecO);
    add_linear_fit(xx,QLi(ind),LineSpec);

    % Find the performance tests
    % ind = find(strcmp(out.DataType,"Relaxation"));
    % xx = out.Test_Number(ind);
    
    % Dynamic parameters
    figure(fig2);
    subplot(ax21);
    plot(xx,out.tau_ref(ind),LineSpecX);
    add_linear_fit(xx,out.tau_ref(ind),LineSpec);
    
    % Find the cycling tests
    % ind = find(strcmp(out.DataType,"Cycling"));
    % xx = out.Test_Number(ind);
    
    subplot(ax22);
    plot(xx,out.In_ref(ind),LineSpecX);
    add_linear_fit(xx, out.In_ref(ind),LineSpec);
    subplot(ax23);
    plot(xx,out.Rf(ind),LineSpecX);
    add_linear_fit(xx, out.Rf(ind),LineSpec);
    
    % RMSE
    figure(fig3);
    plot(xx,out.RMSE_mV(ind),LineSpecX);
    add_linear_fit(xx, out.RMSE_mV(ind),LineSpec);

    % Add effective capacities
    figure(fig1);
    subplot(ax11);
    plot(xx,Qn(ind)./out.CE(ind),LineSpecX);
    subplot(ax12);
    plot(xx,Qp(ind)./out.CE(ind),LineSpecX);
    subplot(ax13);
    plot(xx,QLi(ind)./out.CE(ind),LineSpecX);
end

end

function add_linear_fit(xx, outvar, LineSpec)
if length(xx)>1
    % Compute linear fit
    P = polyfit(xx,outvar,1);
    fit = P(1)*xx+P(2);
    % Compute and plot uncertainty
    rmse = sqrt(mean((outvar-fit).^2));
    fill([xx; xx(end:-1:1)],[fit+rmse; fit(end:-1:1)-rmse], ...
         sqrt(LineSpec.Color), 'FaceAlpha',0.1, 'EdgeColor','none', ...
         'HandleVisibility','off');
    % Plot linear fit on top
    plot(xx,fit,LineSpec,'HandleVisibility','off');
end
end
