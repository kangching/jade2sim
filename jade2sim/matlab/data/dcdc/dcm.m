% This models the 
% VICOR MDCM28AP150M320A50 DCM DCDC converter x2 (parallel)

% FILE ID INFO
ess_description='2x VICOR MDCM DCDC converter';
disp(['Data loaded: ',ess_description])

% data
DCM_Vout = 12; %V
DCM_Vin_min = 16; %V
DCM_Vin_max = 50; %V
DCM_Pout_max = 320*2; %W
DCM_Iout_max = 21.4*2; %A
DCM_Pin_noload = 4*2; %W

% efficiency tables
DCM_Iout = [2.171163
	4.020336
	6.0065646
	7.8839793
	9.761275
	11.693097
	13.652092
	15.529269
	17.40615
	19.36461
	21.18667]*2;
DCM_eff_for_Iout = [82.08475
	83.546364
	84.52273
	85.43407
	86.41015
	87.354
	88.33029
	89.37112
	90.57382
	91.84148
	93.23828]/100;

DCM_Vin = [16 %@350W (Pout_max)
	19.422657
	22.85403
	26.132898
	29.56427
	33.071896
	36.427013
	39.782135
	43.21351
	46.568626
	49.923748];
DCM_eff_for_Vin = [92.60144
	92.94676
	93.0331
	93.00072
	92.94676
	92.88201
	92.83885
	92.75252
	92.655396
	92.56906
	92.417984];
DCM_eff_factor_for_Vin = DCM_eff_for_Vin/max(DCM_eff_for_Vin);