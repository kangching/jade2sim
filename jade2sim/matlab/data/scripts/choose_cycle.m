if use_drive_cycle==0
    folderroot = '../pedal_cycle';
else
    folderroot = '../drive_cycle';
end

filenames = struct2cell(dir([folderroot,'/**.m']));
filenames = filenames(1,:).';
out(:,3) = filenames;
out(:,2) = cellstr('--||--');
out(:,4) = out(:,2);
numbers = 1:1:size(filenames,1);
out(:,1) = cellstr(num2str(numbers.'));
for i=1:1:size(filenames,1)
    out(i,5) = cellstr(strjoin([out(i,1),out(i,2),out(i,3),out(i,4)]));
end
out(:,1) = out(:,5);
out(:,2:5) = [];
for i=1:1:size(filenames,1)
    str = fileread([folderroot,'/',char(filenames(i))]);
    expression = 'cyc_description=\x27(.*?)\x27\x3B';
    [tokens,matches] = regexp(str,expression,'tokens','match');
    description = char(tokens{1});
    out(i,1) = cellstr(strjoin([out(i,1),cellstr(description)]));
end
if size(filenames,1) > 1
    cyc_nr = input(['PLEASE CHOOSE A CYCLE\n',strjoin(out.','\n'),'\nPLEASE TYPE CYCLE #:']);
else
    cyc_nr = 1;
end
cd(folderroot)
eval(['run(''',char(filenames(cyc_nr)),''')']);
cd('../../')
cyc_name = char(filenames(cyc_nr));

