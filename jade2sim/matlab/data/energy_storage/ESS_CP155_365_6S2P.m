% FILE ID INFO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ess_description='CE155-365 based on 6 Ah Saft Li-Ion battery'; 
    %only the limitations are real to Enerdel CE165-360
ess_version=2003; % version of ADVISOR for which the file was generated
ess_proprietary=0; % 0=> non-proprietary, 1=> proprietary, do not distribute
ess_validation=2; % 0=> no validation, 1=> data agrees with source data, 
% 2=> data matches source data and data collection methods have been verified
disp(['Data loaded: ESS_CP155_365_6S2P.m - ',ess_description])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SOC RANGE over which data is defined
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ess_soc=[0 10 20 40 60 80 100]/100;  % (--)	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Temperature range over which data is defined
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ess_tmp=[24.99 25];  % (C)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOSS AND EFFICIENCY parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters vary by SOC horizontally, and temperature vertically
ess_max_ah_cap=[15.5 15.5];
	% (A*h), max. capacity at C/3 rate, indexed by ess_tmp
% average coulombic (a.k.a. amp-hour) efficiency below, indexed by ess_tmp
ess_coulombic_eff=[0.99 0.99];  % (--)
% module's resistance to being discharged, indexed by ess_soc and ess_tmp
ess_r_dis=[0.072 0.01515 0.00839 0.00493 0.00505 0.005524 0.005722; ... 
    0.072 0.01515 0.00839 0.00493 0.00505 0.005524 0.005722]/2; % (ohm)
% module's resistance to being charged, indexed by ess_soc and ess_tmp
ess_r_chg=[0.0124 0.0068 0.005426 0.00442 0.00463 0.00583 0.00583; ... 
    0.0124 0.0068 0.005426 0.00442 0.00463 0.00583 0.00583]/2; % (ohm)
% module's open-circuit (a.k.a. no-load) voltage, indexed by ess_soc and ess_tmp
ess_voc=[2.6191 2.8 3.05 3.41 3.6826 3.88 4.072; ... 
    2.6191 2.8 3.05 3.41 3.6826 3.88 4.072]; % (V)
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LIMITS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ess_min_volts=2.5; 
ess_max_volts=4.1; 
ess_nominal_volts=3.6;
ess_Ipos_max_SOC = 0.5*[0 77.5 77.5 77.5]; % <- test values; real values -> [0 77.5 77.5 77.5]
ess_Ineg_max_SOC = 0.5*[-77.5 -77.5 -77.5 0]; % <- test values; real values -> [-77.5 -77.5 -77.5 0]
ess_SOC_for_Ilimit = [0.4 0.45 0.75 0.8]; % <- test values; real values -> [0 0.15 0.8 1];
ess_Ipos_max_temp = 0.5*[0 77.5 77.5 0]; % <- test values; real values -> [0 77.5 77.5 0]
ess_Ineg_max_temp = 0.5*[0 -77.5 -77.5 0]; % <- test values; real values -> [0 -77.5 -77.5 0]
ess_temp_for_Ilimit = [0 10 35 40];% <- test values; real values -> [-25 -15 45 55]; %degC
ess_temp_min = 0; %<- test values; real values ->-25;
ess_temp_max = 40; %<- test values; real values ->55;
% CONFIGURATION
ess_module_series=6;  %number of modules in series
ess_module_parallel=2;  %number of modules in parallel