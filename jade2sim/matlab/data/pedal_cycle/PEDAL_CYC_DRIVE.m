cyc_description='development - quick 300s accel and brake';
disp(['Data loaded: CYC_CONSTANT - ',cyc_description])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Accelerator brake and key position vs. time
% 0-100 percent
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cyc_acc= ... 
  [0 0
   10 10
   280 10
   280.5 0
   285 0
   300 0];
cyc_brk= ... 
  [0 0
  225 0
  228 0.25
  235 0.25
  240 0
  282.9 0
  283 2
  283.5 15
  300   15];
cyc_key = ... 
  [0 2
  300 2]; % 0 for off, 1 for accessories, 2 for motor

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