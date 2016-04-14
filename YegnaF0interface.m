function f0Structure = YegnaF0interface(x,fs,option)
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
        option.shiftTime = 0.005;
        excitationStruct = f0ExtractionByYegnaQPrimeB(x,fs,option);
    case 3
        excitationStruct = f0ExtractionByYegnaQPrimeB(x,fs,option);
    otherwise
        disp('Please check inputs.');
        f0Structure = [];
        return;
end;
%if analysisParams.F0frameUpdateInterval == 1
    %decimationIndex = (1:5:length(excitationStruct.rawF0))';
%end;
%
%---- minimum requisite parameters
%
f0Structure.f0Extractor = 'Yegna';
f0Structure.samplingFrequency = fs;
f0Structure.f0 = excitationStruct.rawF0;
f0Structure.periodicityLevel = excitationStruct.f0CandidatesScore(1,:);
f0Structure.temporalPositions = excitationStruct.temporalPositions;
f0Structure.vuv = f0Structure.periodicityLevel>20;
%
%---- recommended parameters
%
f0Structure.f0CandidatesMap = excitationStruct.f0Candidates;
f0Structure.f0CandidatesScoreMap = excitationStruct.f0CandidatesScore;
%---- auxiliary parameters
%
additionalInformation.analysisConditions = excitationStruct.analysisConditions;
additionalInformation.defaultConditions = excitationStruct.defaultConditions;
additionalInformation.option = option;
additionalInformation.dateOfSourceExtraction = datestr(now,30);
additionalInformation.elapsedTimeForF0 = toc;
f0Structure.additionalInformation = additionalInformation;
return;