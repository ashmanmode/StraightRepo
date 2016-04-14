function morphingRecord = ...
    makeMorphingContinuum(outFileDirecotry,outFileRootName,nOfSteps,expansionRate)

%   06/Oct./2015 R2015b compatibility fix
%   Author: Hideki Kawahara

[file,path] = uigetfile('*.mat','Select morphing substrate for A-end');
if length(file) == 1 && length(path) == 1
    if file == 0 || path == 0
        disp('Load is cancelled!');
        return;
    end;
end;
load([path file]);
if exist('revisedData') ~= 1
    disp(['The file ' file ' is not a morphing substrate']);
    return;
else
    mSubstrateA = revisedData;
end;

morphingRecord.directoryForA = path;
morphingRecord.fileNameForA = file;

[file,path] = uigetfile('*.mat','Select morphing substrate for B-end');
if length(file) == 1 && length(path) == 1
    if file == 0 || path == 0
        disp('Load is cancelled!');
        return;
    end;
end;
load([path file]);
if exist('revisedData') ~= 1
    disp(['The file ' file ' is not a morphing substrate']);
    return;
else
    mSubstrateB = revisedData;
end;
clear('revisedData');

morphingRecord.directoryForB = path;
morphingRecord.fileNameForB = file;

%outFileDirecotry = 'testMorphing';
%outFileRootName = 'testMorph';
if fopen(outFileDirecotry) < 0
    mkdir(outFileDirecotry);
end;

morphingRecord.outFileDirecotry = outFileDirecotry;
morphingRecord.outFileRootName = outFileRootName;
morphingRecord.dataOfCreation = datestr(now);
morphingRecord.computer = computer;
morphingRecord.version = version;

fs = mSubstrateA.samplintFrequency;

if ischar(nOfSteps)
    nOfSteps = eval(nOfSteps);
end;
if ischar(expansionRate)
    expansionRate = eval(expansionRate);
end;

%nOfSteps = 11;
deltaLambda = 1/(nOfSteps-1);
morphingRateList = cell(nOfSteps,1);
mSubstrateSynthesis = mSubstrateA;
for ii = 1:nOfSteps
    lambda = (ii-1)*deltaLambda;
    currentMorphingRate = interpolateMorphingRate(mSubstrateA,mSubstrateB,lambda,expansionRate);
    currentMorphingRate.spectrum(1)
    mSubstrateSynthesis.temporalMorphingRate = currentMorphingRate;
    morphedSignal = generateMorphedSpeechNewAP(mSubstrateSynthesis);
    tmpSound = morphedSignal.outputBuffer;
    sound(0.9*tmpSound/max(abs(tmpSound)),fs);
    outFileName = [outFileDirecotry '/' outFileRootName num2str(ii,'%03d') ...
        '.wav'];
    maxAmplitude = max(abs(morphedSignal.outputBuffer));
    %wavwrite(morphedSignal.outputBuffer/maxAmplitude*0.9,fs,16,outFileName);
    audiowrite(outFileName,morphedSignal.outputBuffer/maxAmplitude*0.9,fs); % 06/Oct./2015 HK
    morphingRateList{ii} = currentMorphingRate;
end;

morphingRecord.morphingRateList = morphingRateList;
morphingRecord.knobYdataForEndA = mSubstrateA.knobYdata;
morphingRecord.knobYdataForEndB = mSubstrateB.knobYdata;
morphingRecord.temporaAnchorOfSpeakerA = mSubstrateA.temporaAnchorOfSpeakerA;
morphingRecord.temporaAnchorOfSpeakerB = mSubstrateB.temporaAnchorOfSpeakerB;
recordFileName = ['recordOf' outFileRootName datestr(now,30)];
eval(['save ' outFileDirecotry '/' recordFileName ' morphingRecord;']);

