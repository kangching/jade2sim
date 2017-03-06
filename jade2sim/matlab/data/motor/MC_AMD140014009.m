% clear; clc; close all;
%% parameters 
% source: Electric Vehicle Technology Explained By James Larminie, John Lowry
motor_dcdc_eff = 0.9; %DC-DC converter efficiency
Tmax = 70; %rated torque [Nm], estimate
Wmax = 5500*0.104719755; %rated speed [rpm->rad/s], estimate
Pout_max = 3100; %[W] (continuous maximum output for one hour)
Pout_max_peak = 12676.9; %[W] peak maximum output
mc_max_crrnt = 200; % (A), maximum current allowed by the controller and motor
    %the motor has 350 but the controller has 200A
mc_min_volts = 24; % (V), minimum voltage allowed by the controller and motor
mc_inertia = 0.01;  % (kg*m^2), rotor inertia, estimate
% typical values for an electric scooter:
k_c = 0.8; %copper losses
k_i = 0.1;
k_w = 10^-5; %windage losses
C = 20;

%% calculate and display map
NPoints = 100;
T_vector = linspace(0,Tmax,NPoints);
w_vector = linspace(0,Wmax,NPoints);
[w,T] = meshgrid(w_vector+0.001,T_vector+0.001);
Pout = T.*w;
eff = (T.*w)./(T.*w+k_c.*(T.^2)+k_i.*w+k_w.*(w.^3)+C);
eff = eff*motor_dcdc_eff; %account for the DC-DC transformer efficiency
% [c,h] = contour(w_vector,T_vector,eff,[0.25 0.60 0.75 0.8 0.85 0.90],'k');
% clabel(c,h);
% xlabel('Speed [rad/s]');
% ylabel('Torque [Nm]'); 
% title('DC motor efficiency & output power [kW]');
% hold on
% [c,h] = contour(w_vector,T_vector,Pout/1000,[5 8 11 12.67],'r');
% clabel(c,h);
% hold off

%% convert map to the format needed
mc_map_trq = [(-1)*fliplr(T_vector)];
mc_map_trq(size(T_vector,2)) = [];
mc_map_trq = [mc_map_trq T_vector];
mc_map_spd = w_vector;
mc_eff_map = fliplr(eff);
mc_eff_map(:,size(mc_eff_map,2)) = [];
mc_eff_map = [mc_eff_map eff];

%% %% use ADVISOR standard code for further formatting
%% CONVERT EFFICIENCY MAP TO INPUT POWER MAP
% find indices of well-defined efficiencies (where speed and torque > 0)
pos_trqs=find(mc_map_trq>0);
pos_spds=find(mc_map_spd>0);

%% compute losses in well-defined efficiency area
[T1,w1]=meshgrid(mc_map_trq(pos_trqs),mc_map_spd(pos_spds));
mc_outpwr1_map=T1.*w1;
mc_losspwr_map=(1./mc_eff_map(pos_spds,pos_trqs)-1).*mc_outpwr1_map;

% to compute losses in entire operating range
% ASSUME that losses are symmetric about zero-torque axis, and
% ASSUME that losses at zero torque are the same as those at the lowest positive
% torque, and that losses at zero speed are the same as those at the lowest positive speed
mc_losspwr_map=[fliplr(mc_losspwr_map) mc_losspwr_map(:,1) mc_losspwr_map];
mc_losspwr_map=[mc_losspwr_map(1,:);mc_losspwr_map];

%% compute input power (power req'd at electrical side of motor/inverter set)
[T,w]=meshgrid(mc_map_trq,mc_map_spd);
mc_outpwr_map=T.*w;
mc_inpwr_map=mc_outpwr_map+mc_losspwr_map;

%% LIMITS 
% use custom code to calculate based on max output power
tempA = Pout;
tempA(tempA(:,:)>Pout_max)=0;
[M,I] = max(tempA);

% Nm, maximum continuous torque corresponding to speeds in mc_map_spd
mc_max_trq = T_vector(I);
mc_max_gen_trq=-1*mc_max_trq; % estimate

% DEFAULT SCALING
% (--), used to scale mc_map_spd to simulate a faster or slower running motor 
mc_spd_scale=1.0;
% (--), used to scale mc_map_trq to simulate a higher or lower torque motor
mc_trq_scale=1.0;

clear T w mc_outpwr_map mc_outpwr1_map mc_losspwr_map T1 w1 pos_spds pos_trqs
clear c C eff h I k_c k_i k_w M NPoints Pout Pout_max T_vector tempA Tmax w_vector Wmax 
disp(['Data loaded: MC_AMD140-01-4009']);