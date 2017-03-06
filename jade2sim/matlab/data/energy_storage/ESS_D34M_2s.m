% This models the 
% OPTIMA® Batteries 8016-103 D34M BLUETOP® Marine Boat Deep-Cycle
% sealed lead-acid battery

% FILE ID INFO
ess_description='OPTIMA D34M BLUETOP Marine Boat Deep-Cycle';
disp(['Data loaded: ESS_D34M'])
% SOC RANGE over which data is defined
ess_soc = [0 9.99 19.98 30.07 40.06 50.05 60.04 70.03 80.02 90.01 100]/100;
% Temperature range over which data is defined
ess_tmp=[0 22 40];  % (C)
% LOSS AND EFFICIENCY parameters
% Parameters vary by SOC horizontally, and temperature vertically
ess_max_ah_cap=[
% 160108_55 to 5.5
   55*0.1
   55*0.1
   55*0.1
];	% (A*h), max. capacity at C/5 rate, indexed by ess_tmp 
% (estimated, used C/20 rate and multiplied by 0.4 using the ratio of areas
% under discharge rate varying curves for typical lead acid batteries)
% average coulombic (a.k.a. amp-hour) efficiency below, indexed by ess_tmp
ess_coulombic_eff=[
   .9
   .9
   .9
];  % (--);
% module's resistance to being discharged, indexed by ess_soc and ess_tmp
ess_r_dis=[
   4.57 2.686 2.226 1.970 1.843 1.747 1.711 1.685 1.697 1.756 1.769
   4.57 2.686 2.226 1.970 1.843 1.747 1.711 1.685 1.697 1.756 1.769
   4.57 2.686 2.226 1.970 1.843 1.747 1.711 1.685 1.697 1.756 1.769
]/1000; % (ohm)
% module's resistance to being charged, indexed by ess_soc and ess_tmp
ess_r_chg=ess_r_dis; % (ohm), no other data available
% module's open-circuit (no-load) voltage, indexed by ess_soc and ess_tmp
ess_voc=[
   11.387 11.648 11.845 12.042 12.197 12.345 12.5 12.648 12.803 12.951 13.106
   11.387 11.648 11.845 12.042 12.197 12.345 12.5 12.648 12.803 12.951 13.106
   11.387 11.648 11.845 12.042 12.197 12.345 12.5 12.648 12.803 12.951 13.106
]; % (V)
% LIMITS
ess_min_volts=9.5;
ess_max_volts=15.6; %real value
ess_nominal_volts=12;
%ess_nominal_power = 12*100*(1/5);
ess_Ipos_max_SOC = [0 0 100 100 100];
ess_Ineg_max_SOC = [-50 -50 -50 -50 0];
ess_SOC_for_Ilimit = [0 0.1 0.4 0.9 1];
ess_Ipos_max_temp = [0 100 100 0];
ess_Ineg_max_temp = [0 -50 -50 0];
ess_temp_for_Ilimit = [-20 0 25 50]; %degC
ess_temp_min = -20;
ess_temp_max = 50;
% CONFIGURATION
ess_module_series=2;  %number of modules in series
ess_module_parallel=1;  %number of modules in parallel
