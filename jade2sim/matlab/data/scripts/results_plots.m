if show_results_plots==1
%     tic
    disp(['Plotting results...']);
    Time = 0:stoptime;
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
    
    subplot(2,2,3);
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
    end;

%     

%     
%     %% Subsystems and Bus
%     subplot(3,2,2);
%     plot(Time,simout_subs_load_P_calc,'LineWidth',2)
%     title('Subsystems Load - Power')
%     ylabel('Power (W)')
%     grid on
%     
    subplot(2,2,4);
    plot(Time,simout_Vcap,'LineWidth',2)
    title('Bus Voltage')
    ylabel('Voltage (V)')
    grid on
%     
%    subplot(3,2,6);
    subplot(2,2,2);
    plot(Time,simout_Pmotor,'LineWidth',2)
    title('Motor Power')
    ylabel('Power (W)')
    grid on 

    figure();
subplot(2,1,1);
plot(Time,simout_Pout_cap, ... 
        Time,simout_Pout_MB_DCDC1, ... 
        Time,simout_Pout_MB_DCDC2, ...
        Time,simout_Pout_SB_DCDC1, ... 
        Time,simout_Pout_SB_DCDC2, ...
        Time,simout_Pout_AB,'LineWidth',2)
    title('24V Bus Powers')
    ylabel('Power (W)')
    grid on
    legend('Capacitor Power Output', ... 
        'Motor Battery 1 DCDC Power Output', ... 
        'Motor Battery 2 DCDC Power Output', ... 
        'Secondary Battery 1 DCDC Power Output', ...
        'Secondary Battery 2 DCDC Power Output',...
        'Auxiliary Battery Power Output','Location','SouthEast');
    xlabel('Time (s)')
subplot(2,1,2);  
    plot(Time,simout_P_LD_autopilot, ... 
        Time,simout_P_LD_auxiliary, ... 
        Time,simout_P_LD_standby, 'LineWidth',2)
    title('Load')
    ylabel('Power (W)')
    grid on
    legend('Autopilot Load', ... 
        'Auxiliary', ... 
        'Standby', 'Location','SouthEast');
    xlabel('Time (s)')
    
    figure();

    plot(Time,simout_SOC_MB1, ...
Time,simout_SOC_MB2, ...
Time,simout_SOC_SB1, ...    
Time,simout_SOC_SB2,'LineWidth',2)
    title('SOC')
    ylabel('%')
    legend('Motor Battery 1', ... 
'Motor Battery 2', ... 
'Secondary Battery 1', ... 
'Secondary Battery 2')
    xlabel('Time (s)')
    grid on
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
end;
    