function spectrumParamter = exSpectrumTSTRAIGHTGB(x,fs,sourceObj,paramsIn)
%   Spectrum extraction based on TANDEM-STRAIGHT
%   spectrumParamter = exSpectrumTSTRAIGHTGB(x,fs,sourceObj,paramsIn)
%
%   Inputs
%       x   : input signal
%       fs  : sampling frequency
%       sourceObj   : source information object
%   Outputs
%       spectrumParameter   : spectum infromation output structure
%

%   Designed and coded by Hideki Kawahara
%   31/Oct./2007
%   26/Oct./2008 error in default F0 handling
% .......
%   01/Nov./2009 revision for default settings


%---- set default parameters
framePeriod = 5; % in ms
%f0lowLimit = 70;
f0lowLimit = 40; % 24/Oct./2009 H.K.
defaultF0 = 300; % 27/Oct./2008 H.K.
%optionalParameter.q1 = -0.315669;
optionalParameter.q1 = -0.09; % based on Akagiri, 17/May/2011 H.K.
%optionalParameter.DCremoval = 0; % 27/Oct./2008 H.K.
optionalParameter.DCremoval = 1; % 27/April/2010 H.K.
outputTANDEMspectrum = 1;
optionalParameter.exponentControl = 1/6; % 01/Nov./2009 by H.K.
optionalParameter.correctionForBlackman = 2.5; % 18/Oct./2009 by H.K.
optionalParameter.cepstralSmoothing = 1; % based on Akagiri, 17/May/2011 H.K.

%---- check for input parameters
if nargin > 2
    temporalPositions = 0:framePeriod/1000:length(x)/fs;
    if ~isfield(sourceObj,'f0')
        error('no F0 information in sourceObject')
    else
        f0Sequence = sourceObj.f0;
        if isfield(sourceObj,'vuv')
            f0Sequence = sourceObj.vuv.*f0Sequence;
        end;
    end;
    if isfield(sourceObj,'temporalPositions')
        temporalPositions = sourceObj.temporalPositions;
    end;
end;
if nargin > 3
    if isfield(paramsIn,'f0lowLimit')
        f0lowLimit = paramsIn.f0lowLimit;
    end;
    if isfield(paramsIn,'compensationCoefficient')
        optionalParameter.q1 = paramsIn.compensationCoefficient;
    end;
    if isfield(paramsIn,'FFTsize')
        optionalParameter.FFTsize = paramsIn.FFTsize;
    end;
    if isfield(paramsIn,'defaultF0')  % 27/Oct./2008 H.K.
        defaultF0 = paramsIn.defaultF0;
    end;
    if isfield(paramsIn,'exponentControl')  % 15/Oct./2009 H.K.
        optionalParameter.exponentControl = paramsIn.exponentControl;
    end;
    if isfield(paramsIn,'correctionForBlackman')  % 18/Oct./2009 H.K.
        optionalParameter.correctionForBlackman = paramsIn.correctionForBlackman;
    end;
    if isfield(paramsIn,'outputTANDEMspectrum')
        outputTANDEMspectrum = paramsIn.outputTANDEMspectrum;
    end;
    if isfield(paramsIn,'cepstralSmoothing')
        optionalParameter.cepstralSmoothing = paramsIn.cepstralSmoothing;
    end;
end;
analysisConditions.f0lowLimit = f0lowLimit;
analysisConditions.compensationCoefficient = optionalParameter.q1;
analysisConditions.exponentControl = optionalParameter.exponentControl;
analysisConditions.outputTANDEMspectrum = outputTANDEMspectrum;
analysisConditions.defaultF0 = defaultF0;  % 27/Oct./2008 H.K.
analysisConditions.DCremoval = optionalParameter.DCremoval;  % 27/Oct./2008 H.K.
analysisConditions.cepstralSmoothing = optionalParameter.cepstralSmoothing;
spetrumParamter.analysisConditions = analysisConditions;
if nargin == 0
    return;
end;

%---- STRAIGHT spectral analysis body

tSTRAIGHTresults = TandemSTRAIGHTGeneralBody(x,fs,f0Sequence(1),...
    temporalPositions(1),f0lowLimit,optionalParameter);

spectrogramSTRAIGHT = ...
    zeros(size(tSTRAIGHTresults.sliceSTRAIGHT,1),length(f0Sequence));
if outputTANDEMspectrum
    spectrogramTANDEM = spectrogramSTRAIGHT;
end
tic;
for ii = 1:length(f0Sequence);
    currentTime = temporalPositions(ii);
    currentF0 = f0Sequence(ii);  % 27/Oct./2008 H.K.
    if currentF0 == 0
        currentF0 = defaultF0;
    end;
    tSTRAIGHTresults = TandemSTRAIGHTGeneralBody(x,fs,currentF0,...
        currentTime,f0lowLimit,optionalParameter);  % 27/Oct./2008 H.K.
    spectrogramSTRAIGHT(:,ii) = tSTRAIGHTresults.sliceSTRAIGHT;
    if outputTANDEMspectrum
        spectrogramTANDEM(:,ii) = tSTRAIGHTresults.sliceTANDEM;
    end;
end;
ElapsedTimeForSpectrum = toc;

%---- output parameters
spectrumParamter.ElapsedTimeForSpectrum = ElapsedTimeForSpectrum;
spectrumParamter.temporalPositions = temporalPositions;
spectrumParamter.spectrogramSTRAIGHT = spectrogramSTRAIGHT;
spectrumParamter.samplingFrequency = fs;
spectrumParamter.TANDEMSTRAIGHTconditions = tSTRAIGHTresults.analysisConditions;
if outputTANDEMspectrum
    spectrumParamter.spectrogramTANDEM = spectrogramTANDEM;
end;
spectrumParamter.dateOfSpectrumEstimation = datestr(now);

