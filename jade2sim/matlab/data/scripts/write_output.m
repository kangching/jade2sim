if write_csv == 1
    tic
    disp(['Writing outputs...']);
    names(1,1) = cellstr('Time');
    parameters(:,1) = num2cell(Time);
    names(1,2) = cellstr('Velocity');
    parameters(:,2) = num2cell(Velocity_kmph);
    names(1,3) = cellstr('Distance_travelled');
    parameters(:,3) = num2cell(Distance_travelled);
    names(1,4) = cellstr('SOC');
    parameters(:,4) = num2cell(SOC);
    names(1,5) = cellstr('E_batt_useful');
    parameters(:,5) = num2cell(E_batt_useful);
    names(1,6) = cellstr('E_batt_regen');
    parameters(:,6) = num2cell(E_batt_regen);
    names(1,7) = cellstr('E_batt_loss');
    parameters(:,7) = num2cell(E_batt_loss);
    names(1,8) = cellstr('E_mech_regen');
    parameters(:,8) = num2cell(E_mech_regen);
    names(1,9) = cellstr('E_drive');
    parameters(:,9) = num2cell(E_drive);
    names(1,10) = cellstr('E_friction');
    parameters(:,10) = num2cell(E_friction);
    names(1,11) = cellstr('E_component');
    parameters(:,11) = num2cell(E_component);
    names(1,12) = cellstr('E_accessories');
    parameters(:,12) = num2cell(E_accessories);
    names(1,13) = cellstr('E_mech_brake');
    parameters(:,13) = num2cell(E_mech_brake);
    timestamp = char(datetime);
    timestamp = strrep(timestamp,' ','_');
    timestamp = strrep(timestamp,':','-');
    header = cell(1,size(names,2));
    headertext = [cellstr('Cycle: '),cellstr(cyc_name)];
    headertext = [headertext; cellstr('regen_on = '),num2cell(regen_on)];
    headertext = [headertext; cellstr('ess_init_soc = '),num2cell(ess_init_soc)];
    header(1:3,1:2) = headertext;
    header(4,1:2) = cell(1,2);
    fileName = ['../results/results_',timestamp,'.csv'];
    fileText = [header;names;parameters];
    cell2csv(fileName, fileText, ';', 1997, '.')
    toc
end