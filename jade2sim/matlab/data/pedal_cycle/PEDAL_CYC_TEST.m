cyc_description='development, 2200s complex cycle';
disp(['Data loaded: CYC_CONSTANT - ',cyc_description])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Accelerator brake and key position vs. time
% 0-100 percent
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cyc_acc= ... 
  [0 0
   949.9 0
   950 40
   1050 100
   1125 30
   1200 45
   1305 45
   1307 0
   1320 0
   1321 50
   1500 40
   1500.1  0
   2200 0];
cyc_brk= ... 
  [0 0
   1310 0
   1311 5
   1314 5
   1315 0  
   1505  0
   1505.1 60
   1525 60
   1528 0
   2200 0];
cyc_key = ... 
  [0 0
  450 1
  950 2
  1530 0
  2200 0]; % 0 for off, 1 for accessories, 2 for motor

cyc_avg_time_samples=100;  %(samples)
cyc_filter_bool=0;	% 0=> no filtering, follow trace exactly; 1=> smooth trace
cyc_grade=0;	%no grade associated with this cycle
cyc_elevation_init=0; %the initial elevation in meters.

if size(cyc_grade,1)<2
   % convert cyc_grade to a two column matrix, grade vs. dist
   cyc_grade=[0 cyc_grade; 1 cyc_grade]; % use this for a constant roadway grade
end

cyc_key_ts = timeseries(cyc_key(:,2),cyc_key(:,1));
cyc_acc_ts = timeseries(cyc_acc(:,2),cyc_acc(:,1));
cyc_brk_ts = timeseries(cyc_brk(:,2),cyc_brk(:,1));
cyc_grade_ts = timeseries(cyc_grade(:,2),cyc_grade(:,1));
period = cyc_key(size(cyc_key,1),1);

cyc_kph = [0 0; 1 0];
cyc_kph_ts = cyc_kph;