function labelStruct = readAudacityLabel(fname)

%%  get file id
fid = fopen(fname,'r');
labelCell = textscan(fid,'%n%n%s');
fclose(fid);

startTime = labelCell{1};
endTime = labelCell{2};
phonemeLabel = labelCell{3};

labelStruct.segment = [startTime endTime];
labelStruct.phoneme = char(phonemeLabel);

