function labelStruct = readMEILabel(fname)
fs = 44100;
%  get file id
fid = fopen(fname,'r');
labelCell = textscan(fid,'%n%s%s%s%s%s');
fclose(fid);

duration = labelCell{1};
%endTime = labelCell{2};
phonemeLabel = labelCell{2};

labelStruct.segment = duration(:)/fs;
labelStruct.phoneme = char(phonemeLabel);

