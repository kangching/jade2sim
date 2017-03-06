% FILE ID INFO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ess2_description='CE165-360 based on 6 Ah Saft Li-Ion battery'; 
    %only the limitations are real to Enerdel CE165-360
ess2_version=2003; % version of ADVISOR for which the file was generated
ess2_proprietary=0; % 0=> non-proprietary, 1=> proprietary, do not distribute
ess2_validation=2; % 0=> no validation, 1=> data agrees with source data, 
% 2=> data matches source data and data collection methods have been verified
disp(['Data loaded: ESS_CE165_360_6S2P.m - ',ess2_description])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SOC RANGE over which data is defined
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ess2_soc=[0 10 20 40 60 80 100]/100;  % (--)	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Temperature range over which data is defined
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ess2_tmp=[24.99 25];  % (C)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOSS AND EFFICIENCY parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters vary by SOC horizontally, and temperature vertically
ess2_max_ah_cap=[16.5 16.5];
	% (A*h), max. capacity at C/3 rate, indexed by ess2_tmp
% average coulombic (a.k.a. amp-hour) efficiency below, indexed by ess2_tmp
ess2_coulombic_eff=[0.99 0.99];  % (--)
% module's resistance to being discharged, indexed by ess2_soc and ess2_tmp
ess2_r_dis=[0.072 0.01515 0.00839 0.00493 0.00505 0.005524 0.005722; ... 
    0.072 0.01515 0.00839 0.00493 0.00505 0.005524 0.005722]/2; % (ohm)
% module's resistance to being charged, indexed by ess2_soc and ess2_tmp
ess2_r_chg=[0.0124 0.0068 0.005426 0.00442 0.00463 0.00583 0.00583; ... 
    0.0124 0.0068 0.005426 0.00442 0.00463 0.00583 0.00583]/2; % (ohm)
% module's open-circuit (a.k.a. no-load) voltage, indexed by ess2_soc and ess2_tmp
ess2_voc=[2.6 2.888 3.116 3.488 3.748 3.912 4.09; ... 
    2.6 2.888 3.116 3.488 3.748 3.912 4.09]; % (V)
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LIMITS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ess2_min_volts=2.5; 
ess2_max_volts=4.1; 
ess2_nominal_volts=3.6;
ess2_Ipos_max_SOC = 0.5*[0 33 33 33];% <- test values; real values -> [0 33 33 33]
ess2_Ineg_max_SOC = 0.5*[-33 -33 -33 0]; % <- test values; real values -> [-33 -33 -33 0]
ess2_SOC_for_Ilimit = [0.4 0.45 0.75 0.8]; % <- test values; real values -> [0 0.15 0.8 1];
ess2_Ipos_max_temp = 0.5*[0 33 33 0]; %<- test values; real values ->[0 33 33 0];
ess2_Ineg_max_temp = 0.5*[0 -33 -33 0]; %<- test values; real values ->[0 -33 -33 0];
ess2_temp_for_Ilimit = [0 10 35 40];% <- test values; real values -> [-25 -15 45 55]; %degC
ess2_temp_min = 0; %<- test values; real values ->-25;
ess2_temp_max = 40; %<- test values; real values ->55;
% CONFIGURATION
ess2_module_series=6;  %number of modules in series
ess2_module_parallel=2;  %number of modules in parallel