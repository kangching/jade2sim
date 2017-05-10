
clc;
clear all;
close all;





%% simulation settings

disp(['Loading...']);

%sim
JADE_on = 0;
cyc_repeat = 1; %repeat drive/pedal cycle or stop at the end
cyc_repeat_times = 5;
sample_time = 0.01; %[s]
stop_option = 0; %stop on: 0 SOC, 1 both, 2 Vbatt, 3 none
%IO
use_drive_cycle = 1; %0 for pedal cycle, 1 for drive cycle
use_real_subs_loads = 1; %uses real-vehicle subsystem loads power time-series
lockSOCs = 0; %locks battery SOCs to initial value for testing purposes
%scripts
write_csv = 0;
show_energy_plots = 1;
show_results_plots = 1;

%% vehicle/cycle setup

% Command cycle
run('data/scripts/choose_cycle.m')
% Scale the driving cycle to match limited max speed of the vehicle
if use_drive_cycle == 1
speed_max = max(cyc_kph(:,2));
speed_max_limit = 45;
if speed_max>=speed_max_limit
    cyc_kph = [cyc_kph(:,1), cyc_kph(:,2)*speed_max_limit/speed_max];
    cyc_kph_ts = timeseries(cyc_kph(:,2),cyc_kph(:,1));
end
end
% Main Batteries
run('data/energy_storage/ESS_CP155_365_6S2P.m');
ess1_init_soc = 1;%0.7;
ess2_init_soc = 1;%0.7;
ess1_soh = 1;
ess2_soh = 1;

% Secondary Batteries
run('data/energy_storage/ESS_CE165_360_6S2P.m');
ess3_init_soc = 1;%0.7;
ess4_init_soc = 1;%0.7;
ess3_soh = 1;
ess4_soh = 1;

% Auxiliary Battery (10V nominal) for LV (12V) grid
run('data/energy_storage/ESS3_LI7_12V.m');
ess5_init_soc = 1;%0.6;
ess5_soh = 1;
AB_diode_dV = 0.9; %[V]

% DC-DC converters
%   MagCap
run('data/dcdc/MC.m');
params.MB_DCDC_slope = 50;
params.MB_DCDC_V0 = 24;
params.MB1_DCDC_slope = params.MB_DCDC_slope;%50; %abs value
params.MB2_DCDC_slope = 50;%50; %abs value
params.MB1_DCDC_V0 = 24;%24; %intercept
params.MB2_DCDC_V0 = 24;%24; %intercept
params.SB_DCDC_slope = params.MB_DCDC_slope;
params.SB_DCDC_V0 = params.MB_DCDC_V0;
params.MC_Imax = MC_Imax;

%   DCM DCDC (AB DCDC) for auxiliaries / LV grid / 12V bus
run('data/dcdc/dcm.m'); %2 in parallel

% 24V Bus
vbus_min = 17; %V
vbus_max = 25; %V
vbus_threshold = 20; %V threshold for startup
vbus_safety_threshold = 2; %V beyond min/max for which system shuts off
bus_load_Pmax_abs = 260; %500%W
bus_ac_Pmax_abs = 240; 
bus_charger_Pmax = 1000; %W


% EDLC (capacitor)
run('data/energy_storage/ESS_DXE400F.m');
capInitSoC = 0.33;  % initial capacitor SoC
capInitVolt = capVmax*sqrt(capInitSoC);% initial capacitor voltage

% Motor/controller
run('data/motor/MC_AMD140014009.m');

% Drivetrain
gear_ratio = 6;
wh_inertia = 0.0556; % wheel moment of inertia [kg m^2]
no_wheels = 3;
wh_radius = 0.508/2;% wheel radius [m]
wh_1st_rrc = 0.02; % wheel 1st coefficient of rolling resistance
wh_bearing_frc = 0.0015; %wheel bearing viscous friction coefficient [Nm/(rad/s)]
max_brk_torque = 300; %maximum brake torque, total [Nm]

% Vehicle: BugE
veh_mass = 190; % [kg]
veh_CD = 0.35;
veh_FA = 1.543; %frontal area [m^2]
air_density = 1.225; %kg/m^3
veh_gravity = 9.81*veh_mass; %g [m/s^2]

% PV panel module
PV_Pmax = 100; %W

% Subsystems loads (medium voltage bus "loads" module)
rawcsv = csvread('data\MI_Prius_power_measurements.csv');
loadtime = rawcsv(:,1);
loadpower = rawcsv(:,2);
period2 = max(loadtime);


%% Controller settings
startup_seq_step_delay = 0.2; %seconds between the steps of the startup sequence, now high for HIL testing
fault_seq_step_delay = 0.1; %seconds between the steps of the fault sequences, now high for HIL testing

%% Load simulatin and set handles for simulation data

sys = 'BugE_v0_40_MAS_loads';
load_system(sys);

if JADE_on == 1

Vbus_handle = getSimulinkBlockHandle([sys,...
    '/Energy Storage (New Grid)/Capacitor/Switch1']);
MB_slope_adj_handle = getSimulinkBlockHandle([sys,...
    '/Master Controller/Secondary Objectives/MB SOC balancing/MB balancing through load distribution/[1,10]']);
MB_V0_adj_handle = getSimulinkBlockHandle([sys,...
    '/Master Controller/Secondary Objectives/Switch']);
MB1_Vin_handle = getSimulinkBlockHandle([sys,...
    '/Energy Storage (New Grid)/MB1/Compute current (nolimit)/Voc-I*R ']);
MB2_Vin_handle = getSimulinkBlockHandle([sys,...
    '/Energy Storage (New Grid)/MB2/Compute current (nolimit)/Voc-I*R ']);
MB_Imin_handle = getSimulinkBlockHandle([sys,...
    '/Master Controller/System Health/MB current limits/Imin']);
MB_Imax_handle = getSimulinkBlockHandle([sys,...
    '/Master Controller/System Health/MB current limits/Imax']);
SB_slope_adj_handle = getSimulinkBlockHandle([sys,...
    '/Master Controller/Secondary Objectives/Source prioritization/Bias']);
SB_V0_adj_handle = getSimulinkBlockHandle([sys,...
    '/Master Controller/Secondary Objectives/Source prioritization/Gain']);
SB1_Vin_handle = getSimulinkBlockHandle([sys,...
    '/Energy Storage (New Grid)/SB1/Compute current (nolimit)/Voc-I*R ']);
SB2_Vin_handle = getSimulinkBlockHandle([sys,...
    '/Energy Storage (New Grid)/SB2/Compute current (nolimit)/Voc-I*R ']);
SB_Imin_handle = getSimulinkBlockHandle([sys,...
    '/Master Controller/System Health/SB current limits/Imin']);
SB_Imax_handle = getSimulinkBlockHandle([sys,...
    '/Master Controller/System Health/SB current limits/Imax']);
Imotor_handle = getSimulinkBlockHandle([sys,...
    '/Energy Storage (New Grid)/I_motor']);
Jade_handle.MB1 = getSimulinkBlockHandle([sys,...
    '/Master Controller/DCDC Calculators/(MB) MB//SB Class  DCDC Voltage => Power Droop/jade_MB1']);
Jade_handle.MB2 = getSimulinkBlockHandle([sys,...
    '/Master Controller/DCDC Calculators/(MB) MB//SB Class  DCDC Voltage => Power Droop/jade_MB2']);
Jade_handle.SB1 = getSimulinkBlockHandle([sys,...
    '/Master Controller/DCDC Calculators/(SB) MB//SB Class  DCDC Voltage => Power Droop1/jade_SB1']);
Jade_handle.SB2 = getSimulinkBlockHandle([sys,...
    '/Master Controller/DCDC Calculators/(SB) MB//SB Class  DCDC Voltage => Power Droop1/jade_SB2']);

MB_on_handle = getSimulinkBlockHandle([sys,...
    '/Master Controller/Secondary Objectives/MB SOC balancing/and']);
% MB2_on_handle = getSimulinkBlockHandle(...
% 'BugE_v0_40_MAS/Inputs Hardware to Controller/Device detection & identification/ON_MB2');
SB1_on_handle = getSimulinkBlockHandle([sys,...
    '/Inputs Hardware to Controller/Device detection & identification/ON_SB1']);
SB2_on_handle = getSimulinkBlockHandle([sys,...
    '/Inputs Hardware to Controller/Device detection & identification/ON_SB2']);

MB1_Iout_handle = getSimulinkBlockHandle([sys,...
    '/Energy Storage (New Grid)/MB1 DCDC/Current limiter/avoid 0 div3']);
MB2_Iout_handle = getSimulinkBlockHandle([sys,...
    '/Energy Storage (New Grid)/MB2 DCDC/Current limiter/avoid 0 div3']);
MB1_SOC_handle = getSimulinkBlockHandle([sys,...
    '/Inputs Hardware to Controller/Sensors and readings/Unit Delay']);
MB2_SOC_handle = getSimulinkBlockHandle([sys,...
    '/Inputs Hardware to Controller/Sensors and readings/Unit Delay1']);
SB1_SOC_handle = getSimulinkBlockHandle([sys,...
    '/Inputs Hardware to Controller/Sensors and readings/Unit Delay2']);
SB2_SOC_handle = getSimulinkBlockHandle([sys,...
    '/Inputs Hardware to Controller/Sensors and readings/Unit Delay3']);

LD_AC_handle = getSimulinkBlockHandle([sys,...
    '/Inputs Simulation Only/AC load/Switch']);
LD_Autopilot_handle = getSimulinkBlockHandle([sys,...
    '/Inputs Simulation Only/Autopilot load/Switch']);
LD_Lights_handle = getSimulinkBlockHandle([sys,...
    '/Inputs Simulation Only/Auxiliaries power/Switch']);
LD_USB_handle = getSimulinkBlockHandle([sys,...
    '/Inputs Simulation Only/USB power/Switch']);

Jade_handle.LD_AC = getSimulinkBlockHandle([sys,...
    '/Energy Storage (New Grid)/AC/Jade_LD_AC']);
Jade_handle.LD_Autopilot = getSimulinkBlockHandle([sys,...
    '/Energy Storage (New Grid)/AutoPilot/Jade_LD_Autopilot']);
Jade_handle.LD_Lights = getSimulinkBlockHandle([sys,...
    '/Auxiliaries (LV Grid)/Auxiliary load (lights)/Jade_LD_Lights']);
Jade_handle.LD_USB = getSimulinkBlockHandle([sys,...
    '/Auxiliaries (LV Grid)/Auxiliary load (USB ports)/Jade_LD_USB']);
Jade_handle.Obj = getSimulinkBlockHandle([sys,...
    '/Outputs Simulation only/Jade_Obj']);


set_param(Jade_handle.MB1,'Value', '[0.0,0.0,0.0]');
set_param(Jade_handle.MB2,'Value', '[0.0,0.0,0.0]');
set_param(Jade_handle.SB1,'Value', '[0.0,0.0,0.0]');
set_param(Jade_handle.SB2,'Value', '[0.0,0.0,0.0]');

set_param(Jade_handle.LD_AC,'Value', '[0.0,0.0,0.0]');
set_param(Jade_handle.LD_Autopilot,'Value', '[0.0,0.0,0.0]');
set_param(Jade_handle.LD_Lights,'Value', '[0.0,0.0,0.0]');
set_param(Jade_handle.LD_USB,'Value', '[0.0,0.0,0.0]');
set_param(Jade_handle.Obj,'Value', '[0.0,0.0,0.0]');


agents = {'MB1','MB2','SB1','SB2','LD_AC','LD_Autopilot','LD_Lights','LD_USB','Obj'};

%% INITIALIZE CONNECTION

% Create TCP/IP object 't'. Specify server machine and port number.
% Open the connection with the server
t = tcpip('localhost', 1234);
set(t, 'InputBufferSize', 30000);
set(t, 'OutputBufferSize', 30000);
pause(0.1);
fopen(t);

disp('Connection with JADE established');
%%
disp('Exchanging data...') 


while(exist('t'))
    
    clear action;
    clear param1;
    clear output;
    clear val;
    clear ack;
    clear msg;
    
    %% GET MESSAGE FROM JADE
    
    % Receive a message from JADE
    val = tcp_receive_function(t);
    % disp(val)
    
    % Check if the message is valid
    if(~strcmp(val,''))
        
        % Extract the message content
        msg = val{1}{3};
        
        % Split the message content
        contentArray = regexp(msg,',','split');
        action = contentArray{1};
        if(length(contentArray)>1)
            param1 = contentArray{2};
        end
        
        disp('-------------------------')
        disp('Request from JADE:')
        disp(msg)
        tt = 1;
        
        %% TAKE ACTIONS BASED ON THE MESSAGE CONTENT
        
        % If this is to get the parameters of some elements
%         if(strcmp(action,'get-parameters-multiple'))
%             request = msg;
%             contentArray = regexp(request,',','split');
%             paramsArray = contentArray(2:end); 
%             nbparams = length(paramsArray);
% %             output = ['1,',num2str(nbparams)];
%             output = [];
%             for i = 1:nbparams
%                 output = [output,',',num2str(params.(paramsArray{i}))];
%             end
%             output(1) = [];
%             disp('GetParameters succesful');
%             %output = get_parameters_multiple(msg);
%             tcp_send_function(t,output);
%         end
 
        % If this is to change the parameters of one element
%         if(strcmp(action,'change-parameters-single'))
%             request = msg;
%             contentArray = regexp(request,',','split');
%             type = contentArray{2};
%             nbFields = str2double(contentArray{3});
%             fieldArray = contentArray(4:4+nbFields-1);
%             valueArray = contentArray(4+nbFields:length(contentArray));
%             output = [num2str(size(type,1)),',',num2str(nbFields)];
%             for i = 1:nbFields
%                 param{i} = [type,'_',fieldArray{i}];
%                 params.(param{i}) = str2double(valueArray{i});
%                 disp(['Changed Parameters: ' param{i} '=' num2str(params.(param{i}))]);
%                 output = [output,',',num2str(params.(param{i}))];
%             end
%             %output = change_parameters_single(msg);
%             tcp_send_function(t,[]);
%         end
        
% If this is to run a simulation
        if(strcmp(action,'run-simulink'))
            disp(['Simulating with JADE...']);
            tic;
            if cyc_repeat ==1
                stoptime = period*cyc_repeat_times;
                set_param(sys, 'StopTime', num2str(stoptime));
            end
            set_param(sys,'SimulationCommand','start');
            tcp_send_function(t,[]);
            while ~strcmp(get_param(sys,'SimulationStatus'),'stopped')              
                receive_output = tcp_receive_function(t);
                % Check if the message is valid
                if(~strcmp(receive_output,''))

                    % Extract the message content
                    msg = receive_output{1}{3};

                    % Split the message content
                    contentArray = regexp(msg,',','split');
                    action = contentArray{1};

% If it is to read data from simulink
                    if(strcmp(action,'read-input'))
                        rto_Vbus = get_param(Vbus_handle,'RuntimeObject');
                        rto_Imotor = get_param(Imotor_handle,'RuntimeObject');

                        rto_MB1_Vin = get_param(MB1_Vin_handle,'RuntimeObject');
                        rto_MB2_Vin = get_param(MB2_Vin_handle,'RuntimeObject');

                        rto_SB1_Vin = get_param(SB1_Vin_handle,'RuntimeObject');
                        rto_SB2_Vin = get_param(SB2_Vin_handle,'RuntimeObject');

                        rto_MB_slope_adj = get_param(MB_slope_adj_handle,'RuntimeObject');
                        rto_MB_V0_adj = get_param(MB_V0_adj_handle,'RuntimeObject');
                        rto_MB_Imin = get_param(MB_Imin_handle,'RuntimeObject');
                        rto_MB_Imax= get_param(MB_Imax_handle,'RuntimeObject');

                        rto_SB_slope_adj = get_param(SB_slope_adj_handle,'RuntimeObject');
                        rto_SB_V0_adj = get_param(SB_V0_adj_handle,'RuntimeObject');
                        rto_SB_Imin = get_param(SB_Imin_handle,'RuntimeObject');
                        rto_SB_Imax= get_param(SB_Imax_handle,'RuntimeObject');
                        
                        rto_MB_on= get_param(MB_on_handle,'RuntimeObject');
                        rto_SB1_on= get_param(SB1_on_handle,'RuntimeObject');
                        rto_SB2_on= get_param(SB2_on_handle,'RuntimeObject');
                        
                        rto_MB1_Iout= get_param(MB1_Iout_handle,'RuntimeObject');
                        rto_MB2_Iout= get_param(MB2_Iout_handle,'RuntimeObject');
                        rto_MB1_SOC= get_param(MB1_SOC_handle,'RuntimeObject');
                        rto_MB2_SOC= get_param(MB2_SOC_handle,'RuntimeObject');
                        rto_SB1_SOC= get_param(SB1_SOC_handle,'RuntimeObject');
                        rto_SB2_SOC= get_param(SB2_SOC_handle,'RuntimeObject');
                        
                        rto_LD_AC= get_param(LD_AC_handle,'RuntimeObject');
                        rto_LD_Autopilot= get_param(LD_Autopilot_handle,'RuntimeObject');
                        rto_LD_Lights= get_param(LD_Lights_handle,'RuntimeObject');
                        rto_LD_USB= get_param(LD_USB_handle,'RuntimeObject');
                        
                        rto_simtime= get_param(sys,'SimulationTime');
                        
                        
                        read.simtime = rto_simtime;%0
                        read.Vbus = rto_Vbus.OutputPort(1).Data;%1
                        read.Imotor = rto_Imotor.OutputPort(1).Data;%2
                        read.MB1_Vin = rto_MB1_Vin.OutputPort(1).Data;%3
                        read.MB2_Vin = rto_MB2_Vin.OutputPort(1).Data;%4
                        read.SB1_Vin = rto_SB1_Vin.OutputPort(1).Data;%5
                        read.SB2_Vin = rto_SB2_Vin.OutputPort(1).Data;%6
                        read.MB1_slope_adj = rto_MB_slope_adj.OutputPort(1).Data(1);%7
                        read.MB2_slope_adj = rto_MB_slope_adj.OutputPort(1).Data(2);%8
                        read.MB1_V0_adj = rto_MB_V0_adj.OutputPort(1).Data(1);%9
                        read.MB2_V0_adj = rto_MB_V0_adj.OutputPort(1).Data(2);%10
                        read.MB1_Imin = rto_MB_Imin.OutputPort(1).Data(1);%11
                        read.MB2_Imin = rto_MB_Imin.OutputPort(1).Data(2);%12
                        read.MB1_Imax = rto_MB_Imax.OutputPort(1).Data(1);%13
                        read.MB2_Imax = rto_MB_Imax.OutputPort(1).Data(2);%14
                        read.SB1_slope_adj = rto_SB_slope_adj.OutputPort(1).Data(1);%15
                        read.SB2_slope_adj = rto_SB_slope_adj.OutputPort(1).Data(2);%16
                        read.SB1_V0_adj = rto_SB_V0_adj.OutputPort(1).Data(1);%17
                        read.SB2_V0_adj = rto_SB_V0_adj.OutputPort(1).Data(2);%18
                        read.SB1_Imin = rto_SB_Imin.OutputPort(1).Data(1);%19
                        read.SB2_Imin = rto_SB_Imin.OutputPort(1).Data(2);%20
                        read.SB1_Imax = rto_SB_Imax.OutputPort(1).Data(1);%21
                        read.SB2_Imax = rto_SB_Imax.OutputPort(1).Data(2);%22
                        read.MB1_on = rto_MB_on.OutputPort(1).Data(1);%23
                        read.MB2_on = rto_MB_on.OutputPort(1).Data(2);%24
                        read.SB1_on = rto_SB1_on.OutputPort(1).Data;%25
                        read.SB2_on = rto_SB2_on.OutputPort(1).Data;%26
                        read.MB1_Iout = rto_MB1_Iout.OutputPort(1).Data;%27
                        read.MB2_Iout = rto_MB2_Iout.OutputPort(1).Data;%28
                        read.MB1_SOC = rto_MB1_SOC.OutputPort(1).Data;%29
                        read.MB2_SOC = rto_MB2_SOC.OutputPort(1).Data;%30
                        read.SB1_SOC = rto_SB1_SOC.OutputPort(1).Data;%31
                        read.SB2_SOC = rto_SB2_SOC.OutputPort(1).Data;%32
                        
                        read.LD_AC = rto_LD_AC.OutputPort(1).Data;%33
                        read.LD_Autopilot = rto_LD_Autopilot.OutputPort(1).Data;%34
                        read.LD_Lights = rto_LD_Lights.OutputPort(1).Data;%35
                        read.LD_USB = rto_LD_USB.OutputPort(1).Data;%36
                        
                        read_fields_str = strjoin(fieldnames(read),',');
                        read_values = struct2array(read);
                        read_values_str = sprintf(',%.5f',read_values);
                        read_output = read_values_str(2:end);

                        tcp_send_function(t,read_output);                                       
                    end
% If it is to update output to Simulink

%                     if(strcmp(action,'send-output'))
%                         request = msg;
%                         contentArray = regexp(request,',','split');
%                         type = contentArray{2};
%                         nbFields = (length(contentArray)-2)/2;
%                         fieldArray = contentArray(3:3+nbFields-1);
%                         valueArray = contentArray(3+nbFields:length(contentArray));
%                         jade_send.(type) = '[';
%                         for i = 1:nbFields-1
%                             jade_send.(type) = [jade_send.(type),valueArray{i},','];
%                         end
%                         jade_send.(type)(end) = ']';
%                         if(strcmp(type,'SB2'))
%                             for i = 1:4
%                             set_param(Jade_handle.(agents{i}),'Value', jade_send.(agents{i}));
% 
%                             end
%                             output_time(tt,:) = {type,str2double(valueArray{end}),get_param(sys,'SimulationTime')};
%                             tt = tt+1;
%                         end
%                     end
                    
                    if(strcmp(action,'send-output-all'))
                        request = msg;
                        contentArray = regexp(request,',','split');
                        nbFields = (length(contentArray)-(1+length(agents)))...
                            /(2*length(agents));
                        for i = 1:length(agents)
                            type{i} = contentArray{(2*nbFields+1)*(i-1)+2};
                            fieldArray{i} = contentArray((3+(2*nbFields+1)*...
                                (i-1)):(2+nbFields+(2*nbFields+1)*(i-1)));
                            valueArray{i} = contentArray((3+nbFields+...
                                (2*nbFields+1)*(i-1)):(2+2*nbFields+...
                                (2*nbFields+1)*(i-1)));
                            jade_send.(type{i}) = '[';
                            for j = 1:nbFields-1
                                jade_send.(type{i}) = [jade_send.(type{i}),...
                                    cell2mat(valueArray{1,i}(j)),','];
                            end
                            jade_send.(type{i})(end) = ']';
                        end
                        
                        for i = 1:length(agents)
                            set_param(Jade_handle.(agents{i}),'Value',...
                                jade_send.(agents{i}));

                        end
                        output_time(tt,:) = [str2double(valueArray{1}(end)),...
                            get_param(sys,'SimulationTime')];
                        tt = tt+1;
                        tcp_send_function(t,[]);
                     end
                    
                end
                pause(0.01) %Allows matlab to pause and get data from Simulink, t = 0.01 or smaller
            end
            toc
            tcp_send_function(t,'Done');
            set_param(sys,'SimulationCommand','stop');
            close_system(sys,0);
            
            clear reseive_output;
            clear msg;
            
            disp('Ending connection...')
            % Disconnect and clean up the TCP connection.
            fclose(t);
            delete(t);
            clear t

        end
        
% Disconnect and clean up the TCP connection.

        if(strcmp(action,'end-connection'))
            disp('Ending connection...')
            % Disconnect and clean up the TCP connection.
            fclose(t);
            delete(t);
            clear t
        end
        
    end 
    
end

%% Read time and update interval
update_time = output_time;
for i = 1:size(update_time,1)-1
    time_interval(i,:) = [update_time(i,1),...
        update_time(i+1,1)-update_time(i,1)];
end

figure();
subplot(2,1,1)
plot(update_time(:,1),update_time(:,2)-update_time(:,1));
title('Update Delays');
xlabel('Time (s)');
ylabel('Delay (s)');

subplot(2,1,2)
plot(time_interval(:,1),time_interval(:,2));
title('Read Interval');
xlabel('Time (s)');
ylabel('Interval (s)');



interval_avg = mean(time_interval(:,2))
gap_max = max(update_time(:,2)-update_time(:,1))
gap_avg = mean(update_time(:,2)-update_time(:,1))

end

if JADE_on == 0
    tic
    disp(['Simulating in Simulink...']);
    if cyc_repeat == 1
    stoptime = period*cyc_repeat_times;
    set_param(sys, 'StopTime', num2str(stoptime));
    else
        stoptime = period;
    end
    % period = period*5;
    % set_param(sys,'StopTime',num2str(period));
    sim(sys)%, 'SrcWorkspace' , 'current')
    toc
%simout_Level_autopilot = min(simout_P_LD_autopilot./simout_Preq_LD_autopilot,ones(size(simout_P_LD_autopilot)));    
simout_Level_autopilot = simout_Level_autopilot_sim;
simout_Level_ac = simout_P_LD_ac./simout_Preq_LD_AC;
simout_Level_lights = simout_P_LD_auxiliary./simout_Preq_LD_lights;
simout_Level_usb = simout_P_LD_USB./simout_Preq_LD_USB;
end
%%
disp(['Loading...']);

 %% first enable/uncomment blocks
%run('data/scripts/write_output.m'); %% first enable/uncomment Misc/Data Logging

%% 

cyc_input = nan(size(simout_vel_kph));
cyc_input(int16(cyc_kph(2:end,1))+1) = cyc_kph(2:end,2);
cyc_diff = (simout_vel_kph-cyc_input);
cyc_violation = 0;
if max(abs(cyc_diff))>=2
   cyc_violation = 1;
   disp(['!!!Driving cycle violaiton!!!']);
end

travel_distance = sum(simout_vel_kph)/3600;
Eff_Veh = P_Electrical_Storage/travel_distance*100;

if JADE_on == 1
%% Read time and update interval
update_time = output_time;
for i = 1:size(update_time,1)-1
    time_interval(i,:) = [update_time(i,1),...
        update_time(i+1,1)-update_time(i,1)];
end

figure();
subplot(2,1,1)
plot(update_time(:,1),update_time(:,2)-update_time(:,1));
title('Update Delays');
xlabel('Time (s)');
ylabel('Delay (s)');

subplot(2,1,2)
plot(time_interval(:,1),time_interval(:,2));
title('Read Interval');
xlabel('Time (s)');
ylabel('Interval (s)');



interval_avg = mean(time_interval(:,2));
gap_max = max(update_time(:,2)-update_time(:,1));
gap_avg = mean(update_time(:,2)-update_time(:,1));
end

%%
busVlower = 19;
busVupper = 25;
bus_range_index = NaN(size(simout_Vcap));
bus_std = NaN(size(simout_Vcap));

bus_range_int = find(simout_Vcap>=busVlower,1);
bus_range = (simout_Vcap>=busVlower & simout_Vcap<=busVupper);

for i = 1:length(bus_range)
    bus_range_index(i,1) = sum(bus_range(1:i,1))/(i);
end

for i = 60*5:length(bus_range)
    bus_std(i,1) = std(simout_Vcap(i-60*5+1:i,1));
end


%%
simout_Level_autopilot(simout_Preq_LD_autopilot==0)=NaN;
performance_autopilot = max(1-((1-simout_Level_autopilot)./(1-0)).^(1/3),zeros(size(simout_Level_autopilot)));
performance_autopilot(simout_Preq_LD_autopilot==0)=NaN;

simout_Level_ac(simout_Preq_LD_AC==0)=NaN;
performance_ac = max(1-((1-simout_Level_ac)./(1-0)).^3,zeros(size(simout_Level_ac)));
performance_ac(simout_Preq_LD_AC==0)=NaN;

simout_Level_lights(simout_Preq_LD_lights==0)=NaN;
performance_lights = max(1-((1-simout_Level_lights)./(1-0.5)).^2,zeros(size(simout_Level_lights)));
performance_lights(simout_Preq_LD_lights==0)=NaN;

simout_Level_usb(simout_Preq_LD_USB==0)=NaN;
performance_usb = max(1-((1-simout_Level_usb)./(1-0)).^1,zeros(size(simout_Level_usb)));
performance_usb(simout_Preq_LD_USB==0)=NaN;

performance_avg = mean([performance_autopilot,performance_ac,performance_lights,performance_usb],2,'omitnan');

mean(performance_avg)
performance_count = performance_avg<1;
sum(performance_count)/length(performance_avg)
%%
run('data/scripts/results_plots.m');
run('data/scripts/energy_plots.m');
%%
%save('05042017_c5_ac350_2usb1300_JADE_PmaxAdj_usbCoe1.1.mat');
save('05092017_c5_ac60_2usb60_sim_autopilotLevel.mat');

%%
bus_range_time_final = bus_range_index(end,1)
bus_std_avg = mean(bus_std,'omitnan')
mean(performance_avg)
1-sum(performance_count)/length(performance_avg)
