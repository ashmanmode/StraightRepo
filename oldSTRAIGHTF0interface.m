function f0Structure = oldSTRAIGHTF0interface(x,fs,option)
%f0Structure = NDFF0interface(x,fs,option)
%   x   : input signal (one dimensional column vector)
%   fs  : sampling frequency (Hz)
%   option  : optional parameters to be passed to F0 extractor

%   Please use this as a template for programming to the other
%   routines

%   Designed and coded by Hideki Kawahara
%   01/April/2009
tic;
switch nargin
    case 0
        sourceInformation = exF0candidatesTSTRAIGHTGB;
        f0Structure.controlParameters = sourceInformation.controlParameters;
        return;
    case 2
        option = [];
        [f0raw,ap,analysisParams]=exstraightsource(x,fs);
    case 3
        [f0raw,ap,analysisParams]=exstraightsource(x,fs,option);
    otherwise
        disp('Please check inputs.');
        f0Structure = [];
        return;
end;
if analysisParams.F0frameUpdateInterval == 1
    decimationIndex = (1:5:length(f0raw))';
end;
%
%---- minimum requisite parameters
%
f0Structure.f0Extractor = 'legacySTRAIGHT';
f0Structure.samplingFrequency = fs;
f0Structure.f0 = f0raw(decimationIndex);
f0Structure.periodicityLevel = f0Structure.f0>0;
f0Structure.temporalPositions = ...
    (0:length(f0Structure.periodicityLevel)-1)*0.005;
f0Structure.vuv = f0Structure.f0>0;
%f0Structure.refinedF0(f0Structure.refinedF0==0) = ...
%    mean(f0Structure.refinedF0(f0Structure.refinedF0>0))*0.6;
%
%---- recommended parameters
%
f0Structure.f0CandidatesMap = f0Structure.f0;
f0Structure.f0CandidatesScoreMap = f0Structure.periodicityLevel;
%---- auxiliary parameters
%
additionalInformation.controlParameters = analysisParams;
additionalInformation.option = option;
additionalInformation.dateOfSourceExtraction = datestr(now,30);
additionalInformation.elapsedTimeForF0 = toc;
f0Structure.additionalInformation = additionalInformation;
return;