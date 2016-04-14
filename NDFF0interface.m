function f0Structure = NDFF0interface(x,fs,option)
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
        [f0raw,vuv,auxouts,prmouts]=MulticueF0v14(x,fs);
    case 3
        [f0raw,vuv,auxouts,prmouts]=MulticueF0v14(x,fs,option);
    otherwise
        disp('Please check inputs.');
        f0Structure = [];
        return;
end;
if prmouts.F0frameUpdateInterval == 1
    decimationIndex = (1:5:length(f0raw))';
end;
%
%---- minimum requisite parameters
%
f0Structure.f0Extractor = 'NDF';
f0Structure.samplingFrequency = fs;
f0Structure.f0 = f0raw(decimationIndex);
f0Structure.periodicityLevel = auxouts.RELofcandidatesByMix(decimationIndex,1);
f0Structure.temporalPositions = ...
    (0:length(auxouts.RefinedCN(decimationIndex))-1)*0.005;
f0Structure.vuv = vuv(decimationIndex);
%
%---- recommended parameters
%
%maxRefinedCN = max(auxouts.RefinedCN(decimationIndex));
%[RELHistogram,levelsOfREL] = hist(auxouts.RELofcandidatesByMix(decimationIndex),20);
f0Structure.f0CandidatesMap = auxouts.F0candidatesByMix(decimationIndex,:)';
f0Structure.f0CandidatesScoreMap = ...
    auxouts.RELofcandidatesByMix(decimationIndex,:);%'/levelsOfREL(end)*maxRefinedCN;
%
%---- auxiliary parameters
%
additionalInformation.controlParameters = prmouts;
additionalInformation.option = option;
additionalInformation.dateOfSourceExtraction = datestr(now,30);
additionalInformation.elapsedTimeForF0 = toc;
f0Structure.additionalInformation = additionalInformation;
return;