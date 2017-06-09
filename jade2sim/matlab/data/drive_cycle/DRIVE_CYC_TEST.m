cyc_description='development test cycle';
cyc_version=2003; % version of ADVISOR for which the file was generated
cyc_proprietary=0; % 0=> non-proprietary, 1=> proprietary, do not distribute
cyc_validation=0; % 0=> no validation, 1=> data agrees with source data, 
% 2=> data matches source data and data collection methods have been verified
disp(['Data loaded: CYC_CONSTANT - ',cyc_description])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPEED AND KEY POSITION vs. time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cyc_kph=[0 0
   30 0
   100 45
   120 45
   121 0
   160 0
   200 45
   220 45
   221 0
   240 0
   300 45
   320 45
   321 0
   340 0
   400 45
   420 45
   421 0
   425 0];
cyc_key = ... 
  [0 2
  425 2]; % 0 for off, 1 for accessories, 2 for motor

cyc_avg_time_samples=100;  % (s)
cyc_grade=0;	%no grade associated with this cycle

if size(cyc_grade,1)<2
   % convert cyc_grade to a two column matrix, grade vs. dist
   cyc_grade=[0 cyc_grade; 1 cyc_grade]; % use this for a constant roadway grade
end

cyc_key_ts = timeseries(cyc_key(:,2),cyc_key(:,1));
cyc_kph_ts = timeseries(cyc_kph(:,2),cyc_kph(:,1));
cyc_grade_ts = timeseries(cyc_grade(:,2),cyc_grade(:,1));
period = cyc_key(size(cyc_key,1),1);

cyc_acc = [0 0; 1 0];
cyc_acc_ts = cyc_acc;
cyc_brk = [0 0; 1 0];
cyc_brk_ts = cyc_brk;