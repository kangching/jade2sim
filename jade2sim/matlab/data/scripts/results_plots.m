if show_results_plots==1
    
%     tic
    disp(['Plotting results...']);
    Time = 0:stoptime;
    a = 0;
    b = stoptime;
%     %% Battery Current Limiter
%     figure();
if use_drive_cycle == 0
    subplot(2,2,1);
    plot(cyc_acc(:,1),cyc_acc(:,2), ... 
        cyc_brk(:,1),cyc_brk(:,2),'LineWidth',2)
    title('Pedal Cycle')
    ylabel('%')
    grid on
    legend('Acceleration','Braking','Location','NorthWest')

    subplot(2,2,2);
    plot(Time,simout_vel_kph,'LineWidth',2)    
    title('Velocity')
    ylabel('Velocity (km/h)')    
    grid on

end;
    
if use_drive_cycle == 1
    subplot(2,2,1);
    plot(cyc_kph(:,1),cyc_kph(:,2), ... 
        Time,simout_vel_kph,'LineWidth',2);
    title('Velocity');
    xlabel('Time (s)');
    ylabel('Velocity (Km/h)');
    grid on;
    legend('Velocity command','Vehicle velocity','Location','best');
    axis([a b 0 50]);
    
    subplot(2,2,2);
    plot(Time,simout_SOC_MB1, ...
    Time,simout_SOC_MB2, ...
    Time,simout_SOC_SB1, ...    
    Time,simout_SOC_AB,...
    'LineWidth',2)
    title('SOC')
    ylabel('%')
    legend('Motor Battery 1', ... 
        'Motor Battery 2', ... 
        'Secondary Battery 1', ... 
        'Auxiliary Battery', 'Location','best')
    xlabel('Time (s)')
    axis([a b 0.4 1]);
    grid on


end;
      
    subplot(2,2,4);
    plot(Time,simout_Vcap,'LineWidth',2)
    title('Bus Voltage')
    ylabel('Voltage (V)')
    axis([a b 0 25]);
    grid on

    subplot(2,2,3);
    plot(Time,simout_Pmotor,'LineWidth',2)
    title('Motor Power')
    ylabel('Power (W)')
    axis([a b 0 3000]);
    grid on 
%%
figure();
    subplot(3,2,1);
    plot(Time,simout_Vcap,'LineWidth',2)
    title('Bus Voltage')
    ylabel('Voltage (V)')
    axis([a b 0 25]);
    xlabel('Time (s)')
    grid on

    subplot(3,2,3);
    plot(Time,bus_range_index,'LineWidth',2)
    title(['Bus Voltage = [',num2str(busVlower),',',num2str(busVupper),']']);
    
    ylabel('% of Time')
    axis([a b 0.5 1]);
    xlabel('Time (s)')
    grid on
    
    subplot(3,2,5);
    plot(Time,bus_std,'LineWidth',2)
    title('Bus Voltage Std');
    ylabel('std')
    axis([a b 0 1.5]);
    xlabel('Time (s)')
    grid on

    subplot(3,2,2);
    plot(Time,simout_MB_SlopAdj.*50,'LineWidth',2)
    title('MB DCDC Slope')
    ylabel('Voltage (V)')
    axis([a b 50 60]);
    xlabel('Time (s)')
    grid on

    subplot(3,2,4);
    plot(Time,simout_price,'LineWidth',2)
    title('Price');
    axis([a b 0 1]);
    grid on;
    xlabel('Time (s)')
%%

figure();
subplot(2,1,1);
plot(Time,simout_Pout_MB_DCDC1, ... 
        Time,simout_Pout_MB_DCDC2, ...
        Time,simout_Pout_SB_DCDC1, ... 
        Time,simout_Pout_AB,...
        Time,simout_Pout_cap,'LineWidth',1);
    title('24V Bus Powers')
    ylabel('Power (W)')
    grid on
    legend('Motor Battery 1 DCDC Power Output', ... 
        'Motor Battery 2 DCDC Power Output', ... 
        'Secondary Battery 1 DCDC Power Output', ...
        'Auxiliary Battery Power Output',...
    'Capacitor Power Output', ... 
        'Location','SouthEast');
    xlabel('Time (s)')
    axis([a b -500 300]);
subplot(2,1,2);  
    plot(Time,simout_P_LD_autopilot, ...
        Time,simout_P_LD_ac,...
        Time,simout_P_LD_auxiliary, ...
        Time,simout_P_LD_USB,...
        Time,simout_P_LD_standby, 'LineWidth',1)
    title('Load')
    ylabel('Power (W)')
    grid on
    legend('Autopilot Load', ...
        'A/C Load',...
        'Auxiliary (lights)', ... 
        'Auxiliary (USB)', ...
        'Standby', 'Location','SouthEast');
    xlabel('Time (s)')
    axis([a b 0 250]);
    %%
figure();
subplot(2,2,3);
plot(Time,simout_Pmax_MB(:,1), ...
        Time,simout_Pout_MB(:,1),...
        Time,simout_Pmin_MB(:,1), ...
        'LineWidth',1)
    title('MB DCDC Controll Output')
    ylabel('Power (W)')
    grid on
    legend('Pmax', ...
        'Pout',...
        'Pmin', ... 
        'Location','Best');
    xlabel('Time (s)')
    axis([a b 0 300]);

subplot(2,2,2);  
    plot(Time,simout_Pmax_LD, ...
        Time,simout_Preq_LD_AC,...
        Time,simout_Preq_LD_autopilot, 'LineWidth',1)
    title('Load')
    ylabel('Power (W)')
    grid on
    legend('Max Load limit',...
        'Autopilot Load Input', ...
        'A/C Load Input','Location','SouthEast');
    xlabel('Time (s)')
    axis([a b 0 260]);    
    
% subplot(2,2,2);
% plot(Time,simout_MB_var(:,1), ...
%     Time,simout_MB_var(:,2), ...
%     Time,simout_MB_var(:,3), ...
%     Time,simout_MB_var(:,4), ...
%         'LineWidth',1)
%     title('MB DCDC Controll Variables')
%     ylabel('Power (W)')
%     grid on
%     legend('MB1_V0_adj', ...
%         'MB2_V0_adj',...
%         'MB1_slope_adj', ... 
%         'MB2_slope_adj', ...
%         'Location','Best');
%     xlabel('Time (s)')
%     axis([a b -2 2]);
    %%
subplot(2,2,1);

    plot(Time,simout_SOC_MB1,'LineWidth',2)
    title('MB1 SOC')
    ylabel('SOC (%)')
    axis([a b 0.8 1]);
    xlabel('Time (s)')
    grid on
    
% plot(Time,simout_Iout_cap, 'LineWidth',1)
%     title('Capacitor Current')
%     ylabel('Current(A)')
%     grid on
%     xlabel('Time (s)')
%     axis([a b -30 10]);
%%    
subplot(2,2,4);
area(Time,[simout_P_LD_standby, simout_P_LD_USB, simout_P_LD_auxiliary, simout_P_LD_autopilot,simout_P_LD_ac],...
    'LineStyle', 'none')
    title('Total Load')
    ylabel('Power(W)')
    grid on
    xlabel('Time (s)')
     legend('Auxiliary (ECU/sencors)',...
         'Auxiliary (USB)', ...
         'Auxiliary (lights)', ...
         'Autopilot Load', ...
        'A/C Load', 'Location','southoutside','Orientation','horizontal');
    axis([a b 0 600]);

%% Driving cycle 
% figure();
% plot(cyc_kph(:,1),cyc_kph(:,2), ... 
%         Time,simout_vel_kph,'LineWidth',2);
%     title('Velocity');
%     xlabel('Time (s)');
%     ylabel('Velocity (Km/h)');
%     grid on;
%     legend('Velocity command','Performance','Location','NorthWest');

%      toc

%%
figure(); 
subplot(2,3,1)
    plot(Time,performance_avg,'LineWidth',1);
    title('Average Load Performance');
    ylabel('Performance')
    grid on
    xlabel('Time (s)')
    axis([a b 0 1]);
    
    subplot(2,3,2)
    plot(Time,simout_Level_autopilot,'LineWidth',1)
    title('Autopilot');
    ylabel('Level')
    grid on
    xlabel('Time (s)')
    axis([a b 0 1]);
    
    subplot(2,3,4)
    plot(Time,simout_Level_ac,'LineWidth',1)
    title('A/C');
    ylabel('Level')
    grid on
    xlabel('Time (s)')
    axis([a b 0 1]);
    subplot(2,3,5)
    plot(Time,simout_Level_lights,'LineWidth',1)
    title('Lights');
    ylabel('Level')
    grid on
    xlabel('Time (s)')
    axis([a b 0 1]);
    subplot(2,3,6)
    plot(Time,simout_Level_usb,'LineWidth',1)
    title('USB');
    ylabel('Level')
    grid on
    xlabel('Time (s)')
    axis([a b 0 1]);

% figure();
%     plot(Time,1-(1-simout_Level_ac.*0.25).^3,...
%     Time,1-((1-simout_Level_lights.*0.25)/0.5).^2,...
%         Time,1-(1-simout_Level_usb.*0.25).^1,'LineWidth',1);
%     title('Load Performance');
%     ylabel('Performance')
%     grid on
%     xlabel('Time (s)')
%      legend('A/C','Lights','USB', 'Location','best');
%     axis([a b 0 1]);
%     
%     figure();
%     plot(Time,(1-(1-simout_Level_ac.*0.25).^3+1-((1-simout_Level_lights.*0.25)/0.5).^2+1-(1-simout_Level_usb.*0.25).^1)/3,'LineWidth',1);
%     title('Average Load Performance');
%     ylabel('Performance')
%     grid on
%     xlabel('Time (s)')
%     axis([a b 0 1]);
%     
%%


end;
    