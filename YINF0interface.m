function f0Structure = YINF0interface(x,fs,option)
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
        sourceInformation = [];
        f0Structure.controlParameters = [];
        return;
    case 2
        option.sr = fs;
        option.hop = round(0.005*fs);
        r = yin(x,option);
    case 3
        r = yin(x,option);
    otherwise
        disp('Please check inputs.');
        f0Structure = [];
        return;
end;

%adJustForFrameRate = round(0.005/(r.hop/fs));
%decimationIndex = 1:adJustForFrameRate:length(r.f0);
framePeriod = r.hop/fs;
f0 = 440*2.0.^r.f0;
%
%---- minimum requisite parameters
%
f0Structure.f0Extractor = 'YIN';
f0Structure.samplingFrequency = fs;
f0Structure.f0 = f0;
f0Structure.f0(isnan(f0Structure.f0)) = mean(f0Structure.f0(~isnan(f0Structure.f0)));
f0Structure.periodicityLevel = 1-r.ap;
f0Structure.temporalPositions = ...
    (0:length(r.ap)-1)*framePeriod;
f0Structure.vuv = ~isnan(f0);
%
%---- recommended parameters
%
f0Structure.f0CandidatesMap = f0Structure.f0;
f0Structure.f0CandidatesScoreMap = f0Structure.periodicityLevel;
%
%---- auxiliary parameters
%
additionalInformation.framePower = r.pwr;
additionalInformation.option = option;
additionalInformation.elapsedTimeForF0 = toc;
f0Structure.additionalInformation = additionalInformation;
return;