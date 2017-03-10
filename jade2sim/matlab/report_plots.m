clear all; clc; close all;
% load('JADE_sync.mat');
%     Time = 0:period;
load('jade_sync_30_2.mat');
Time = 0:stoptime;
    simout_Pmotor_jade = simout_Pmotor;
    simout_Vcap_jade = simout_Vcap;
    simout_Pout_cap_jade = simout_Pout_cap; 
    simout_Pout_MB_DCDC1_jade = simout_Pout_MB_DCDC1;
    simout_Pout_MB_DCDC2_jade = simout_Pout_MB_DCDC2;
    simout_Pout_SB_DCDC1_jade = simout_Pout_SB_DCDC1;
    simout_Pout_SB_DCDC2_jade = simout_Pout_SB_DCDC2;
    simout_Pout_MB1_jade = simout_Pout_MB1;
    simout_Pout_MB2_jade = simout_Pout_MB2;
    simout_SOC_MB1_jade = simout_SOC_MB1;
    simout_SOC_MB2_jade = simout_SOC_MB2;
    simout_SOC_SB1_jade = simout_SOC_SB1;
    simout_SOC_SB2_jade = simout_SOC_SB2;
    simout_Pout_AB_jade = simout_Pout_AB;
    Eff_Veh_jade = Eff_Veh;
% load('SimulinkOnly.mat');  
load('simulink_only_30.mat'); 
cc = [      0    0.4470    0.7410;
    0.8500    0.3250    0.0980;
    0.9290    0.6940    0.1250;
    0.4940    0.1840    0.5560;
    0.4660    0.6740    0.1880;
    0.3010    0.7450    0.9330;
    0.6350    0.0780    0.1840];
    %%
figure();
    subplot(2,2,1);
    plot(cyc_kph(:,1),cyc_kph(:,2),'Color',cc(1,:),'LineWidth',2);
    hold on;
    plot(Time,simout_vel_kph,':','Color',cc(2,:),'LineWidth',2);
    hold off;
    title('Velocity');
    xlabel('Time (s)');
    ylabel('Velocity (Km/h)');
    grid on;
    legend('Velocity command','Vehicle velocity','Location','best');
    
    subplot(2,2,3);
    plot(Time,simout_Pmotor,'Color',cc(1,:),'LineWidth',2);
    hold on;
    plot(Time,simout_Pmotor_jade,':','Color',cc(2,:),'LineWidth',2);
    hold off;
    title('Motor Power')
    ylabel('Power (W)')
        legend('Simulink','MAS','Location','best');
    grid on 
    
    subplot(2,2,4);
    plot(Time,simout_Vcap,'Color',cc(1,:),'LineWidth',2);
     hold on;
    plot(Time,simout_Vcap_jade,':','Color',cc(2,:),'LineWidth',2);
    hold off;
    title('Bus Voltage')
    ylabel('Voltage (V)')
    grid on
    legend('Simulink','MAS','Location','best');
    
    subplot(2,2,2);  
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
 

%%
figure();
subplot(2,2,1);
plot(Time,simout_Pout_cap, ... 
        Time,simout_Pout_MB_DCDC1, ... 
        Time,simout_Pout_MB_DCDC2,':', ...
        Time,simout_Pout_SB_DCDC1, ... 
        Time,simout_Pout_SB_DCDC2,':', ...
        'LineWidth',2)
    title('24V Bus Powers: Simulink')
    ylabel('Power (W)')
    grid on
    legend('Capacitor Power Output', ... 
        'MB1 DCDC Power Output', ... 
        'MB2 DCDC Power Output', ... 
        'SB1 DCDC Power Output', ...
        'SB2 DCDC Power Output','Location','b');
    xlabel('Time (s)')
    axis([0 stoptime -1000 400]);

subplot(2,2,3);  
plot(Time,simout_Pout_cap_jade, ... 
        Time,simout_Pout_MB_DCDC1_jade, ... 
        Time,simout_Pout_MB_DCDC2_jade,':', ...
        Time,simout_Pout_SB_DCDC1_jade, ... 
        Time,simout_Pout_SB_DCDC2_jade,':', ...
        'LineWidth',2)
    title('24V Bus Powers: Jade')
    ylabel('Power (W)')
    grid on
    legend('Capacitor Power Output', ... 
        'MB1 DCDC Power Output', ... 
        'MB2 DCDC Power Output', ... 
        'SB1 DCDC Power Output', ...
        'SB2 DCDC Power Output','Location','b');
    xlabel('Time (s)')
    axis([0 stoptime -1000 400]);

    subplot(2,2,2);
    plot(Time,100*simout_SOC_MB1_jade, ...
Time,100*simout_SOC_MB1,':', ...
Time,100*simout_SOC_SB1_jade, ...    
Time,100*simout_SOC_SB1,':','LineWidth',2)
    title('SOC')
    ylabel('%')
    legend('Simulink:MB1', ... 
'MAS: MB1', ... 
'Simulink:SB1', ... 
'MAS:SB1','Location','b')
    xlabel('Time (s)')
    grid on

    subplot(2,2,4);
    plot(Time,100*(simout_SOC_MB1_jade-simout_SOC_MB1), ...
Time,100*(simout_SOC_SB1_jade-simout_SOC_SB1),'LineWidth',2)
    title('SOC differences: MAS-Simulink')
    ylabel('%')
    legend('MB1','SB1','Location','b')
    xlabel('Time (s)')
    grid on

    %%
    figure();
    subplot(2,1,2);
    plot(Time,simout_Pout_cap_jade+simout_Pout_MB_DCDC1_jade+...
        simout_Pout_MB_DCDC2_jade+simout_Pout_SB_DCDC1_jade+...
        simout_Pout_SB_DCDC2_jade,...
        Time,simout_P_LD_autopilot+simout_P_LD_auxiliary+simout_P_LD_standby,...
        'LineWidth',2)
    title('24V Bus Powers: Jade')
    legend('Power output','Power_consuption')
        subplot(2,1,1);
    plot(Time,simout_Pout_cap+simout_Pout_MB_DCDC1+...
        simout_Pout_MB_DCDC2+simout_Pout_SB_DCDC1+...
        simout_Pout_SB_DCDC2,...
        Time,simout_P_LD_autopilot+simout_P_LD_auxiliary+simout_P_LD_standby,...
        'LineWidth',2)
    title('24V Bus Powers: Simulink')
    legend('Power output','Power_consuption')
    
        figure();
    subplot(2,1,2);
    plot(Time,simout_Pout_MB1_jade+...
        simout_Pout_MB2_jade,...
        Time,simout_Pmotor_jade,...
        'LineWidth',2)
    title('24V Bus Powers: Jade')
    legend('Power output','Power_consuption')
        subplot(2,1,1);
    plot(Time,simout_Pout_MB1+...
        simout_Pout_MB2,...
        Time,simout_Pmotor,...
        'LineWidth',2)
    title('24V Bus Powers: Simulink')
    legend('Power output','Power_consuption')