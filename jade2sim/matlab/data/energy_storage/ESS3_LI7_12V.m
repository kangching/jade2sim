% FILE ID INFO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ess3_description='6 Ah Saft Li-Ion battery adjusted to 12V'; 
ess3_version=2003; % version of ADVISOR for which the file was generated
ess3_proprietary=0; % 0=> non-proprietary, 1=> proprietary, do not distribute
ess3_validation=2; % 0=> no validation, 1=> data agrees with source data, 
% 2=> data matches source data and data collection methods have been verified
disp(['Data loaded: ess3_LI7.m - ',ess3_description])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SOC RANGE over which data is defined
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ess3_soc=[0 10 20 40 60 80 100]/100;  % (--)	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Temperature range over which data is defined
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ess3_tmp=[0 25 41];  % (C)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOSS AND EFFICIENCY parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters vary by SOC horizontally, and temperature vertically
ess3_max_ah_cap=[5.943 7.035 7.405];
	% (A*h), max. capacity at C/3 rate, indexed by ess3_tmp
% average coulombic (a.k.a. amp-hour) efficiency below, indexed by ess_tmp
ess3_coulombic_eff=[0.968 0.99 0.992];  % (--)
% module's resistance to being discharged, indexed by ess_soc and ess_tmp
ess3_r_dis=[0.0419 0.0288 0.0221 0.014 0.0145 0.0145 0.0162;
0.072 0.01515 0.00839 0.00493 0.00505 0.005524 0.005722;
0.0535 0.0133 0.0082 0.0059 0.0059 0.006 0.0063]*3; % (ohm)
% module's resistance to being charged, indexed by ess_soc and ess_tmp
ess3_r_chg=[0.021 0.018 0.0177 0.0157 0.0138 0.0138 0.015;
0.0124 0.0068 0.005426 0.00442 0.00463 0.00583 0.00583;
0.0104 0.0079 0.0072 0.0064 0.0059 0.0058 0.006]*3; % (ohm)
% module's open-circuit (a.k.a. no-load) voltage, indexed by ess_soc and ess_tmp
ess3_voc=[3.44 3.473 3.496 3.568 3.637 3.757 3.896;
3.124 3.349 3.433 3.518 3.616 3.752 3.898;
3.128 3.36 3.44 3.528 3.623 3.761 3.899]*3*1.025; % (V) %1.025 is an adjustment
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LIMITS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ess3_min_volts=7.2;
ess3_max_volts=14;
ess3_nominal_volts=12; %guess
ess3_nominal_power = 12*100*(1/3);
ess3_Ipos_max_SOC = [0 0 100 100 100]*2;
ess3_Ineg_max_SOC = [-50 -50 -50 -50 0];
ess3_SOC_for_Ilimit = [0 0.1 0.4 0.9 1];
ess3_Ipos_max_temp = [0 100 100 0];
ess3_Ineg_max_temp = [0 -100 -100 0];
ess3_temp_for_Ilimit = [-20 0 25 50]; %degC
ess3_temp_min = -20;
ess3_temp_max = 50;
% CONFIGURATION
ess3_module_series=1;  %number of modules in series
ess3_module_parallel=1;  %number of modules in parallel