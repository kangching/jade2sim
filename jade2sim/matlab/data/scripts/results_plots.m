if show_results_plots==1
    
%     tic
    disp(['Plotting results...']);
    Time = 0:stoptime;
    a = 0;
    b = 2000;
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
    axis([a b 0 50]);
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
    axis([a b 0 25]);
    grid on
%     
%    subplot(3,2,6);
    subplot(2,2,2);
    plot(Time,simout_Pmotor,'LineWidth',2)
    title('Motor Power')
    ylabel('Power (W)')
    axis([a b 0 3000]);
    grid on 

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
    figure();

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
'Auxiliary Battery')
    xlabel('Time (s)')
    axis([a b 0.4 1]);
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
    