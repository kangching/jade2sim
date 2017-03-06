cyc_description='Japanese 10-15 mode driving cycle';
cyc_version=2003; % version of ADVISOR for which the file was generated
cyc_proprietary=0; % 0=> non-proprietary, 1=> proprietary, do not distribute
cyc_validation=0; % 0=> no validation, 1=> data agrees with source data, 
% 2=> data matches source data and data collection methods have been verified
disp(['Data loaded: CYC_1015 - ',cyc_description])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPEED AND KEY POSITION vs. time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load variable 'cyc_mph', 2 column matrix with time in the first column
load CYC_1015.mat
cyc_kph = [cyc_mph(:,1),cyc_mph(:,2)*1.60934];
cyc_key = ... 
  [0 2
  660 2]; % 0 for off, 1 for accessories, 2 for motor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OTHER DATA		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%													
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