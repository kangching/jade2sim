ess_description='DXE400F Capacitor';
disp(['Data loaded: DXE400F Capacitor'])
% SOC RANGE over which data is defined
capCellcap = 400;  %DXE400F
capCellVmax = 2.5; %DXE400F
capCellR = 0.0012; %DXE400F
capstack = 10;
capC = capCellcap/capstack;  % capacitor capacity C, 100F
capVmax = capCellVmax*capstack;  % maximum voltage of the capacitor, V
capR = capstack*capCellR;  % OHM
