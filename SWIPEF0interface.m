function f0Structure = SWIPEF0interface(x,fs,option)
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
        [P,T,S] = swipep(x,fs, [30 5000],0.005,1/48,0.1,0.5,-Inf);
        option = ', [30 5000],0.005,1/48,0.1,0.5,-Inf';
    case 3
        eval(['[P,T,S] = swipep(x,fs,' option ');']);
    otherwise
        disp('Please check inputs.');
        f0Structure = [];
        return;
end;
%
%---- minimum requisite parameters
%
f0Structure.f0Extractor = 'SWIPE';
f0Structure.samplingFrequency = fs;
f0Structure.f0 = P;
f0Structure.periodicityLevel = S;
f0Structure.temporalPositions = T;
f0Structure.vuv = ~isnan(f0Structure.f0);
%
%---- recommended parameters
%
f0Structure.f0CandidatesMap = P(:)';
f0Structure.f0CandidatesScoreMap = S(:)';
%---- auxiliary parameters
%
additionalInformation.analysisConditions = option;
additionalInformation.dateOfSourceExtraction = datestr(now,30);
additionalInformation.elapsedTimeForF0 = toc;
f0Structure.additionalInformation = additionalInformation;
return;