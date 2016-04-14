function f0Structure = tandemSTRAIGHTF0interface(x,fs,option)
%f0Structure = tandemSTRAIGHTF0interface(x,fs,option)
%   x   : input signal (one dimensional column vector)
%   fs  : sampling frequency (Hz)
%   option  : optional parameters to be passed to F0 extractor

%   Please use this as a template for programming to the other
%   routines

%   Designed and coded by Hideki Kawahara
%   01/April/2009

switch nargin
    case 0
        sourceInformation = exF0candidatesTSTRAIGHTGB;
        f0Structure.controlParameters = sourceInformation.controlParameters;
        return;
    case 2
        optP.debugperiodicityShaping = 1.3;
        optP.channelsPerOctave = 3;
        optP.f0ceil = 650;
        sourceInformation = exF0candidatesTSTRAIGHTGB(x,fs,optP);
    case 3
        sourceInformation = exF0candidatesTSTRAIGHTGB(x,fs,option);
    otherwise
        disp('Please check inputs.');
        f0Structure = [];
        return;
end;
%
%---- minimum requisite parameters
%
f0Structure.f0Extractor = 'XSX';
f0Structure.samplingFrequency = fs;
f0Structure.f0 = sourceInformation.f0;
f0Structure.periodicityLevel = sourceInformation.periodicityLevel;%/2.5;
f0Structure.temporalPositions = sourceInformation.temporalPositions;
% The following line is too poor. This has to be elaborated.
f0Structure.vuv = sourceInformation.periodicityLevel>0.71; %1.42*(2.5/2);
%
%---- recommended parameters
%
f0Structure.f0CandidatesMap = sourceInformation.f0CandidatesMap;
f0Structure.f0CandidatesScoreMap = sourceInformation.f0CandidatesScoreMap;%/2.5;
f0Structure.f0candidatesPowerMap = sourceInformation.f0candidatesPowerMap;
%
%---- auxiliary parameters
%
additionalInformation.controlParameters = sourceInformation.controlParameters;
additionalInformation.dateOfSourceExtraction = sourceInformation.dateOfSourceExtraction;
additionalInformation.statusParamsF0 = sourceInformation.statusParamsF0;
additionalInformation.elapsedTimeForF0 = sourceInformation.elapsedTimeForF0;
f0Structure.additionalInformation = additionalInformation;
return;