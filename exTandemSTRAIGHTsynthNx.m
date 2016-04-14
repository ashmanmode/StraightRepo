function synthesisResults = ...
    exTandemSTRAIGHTsynthNx(sourceObject,filterObject,sythesisInformation)
%   Synthesis using STRAIGHT parameters specialized for composite
%   aperiodicity parameter.
%   synthesisResults = ...
%     exTandemSTRAIGHTsynthNx(sourceObject,filterObject,sythesisInformation)
%   Inputs
%       sourceObject    : source information structure such as F0 and
%                       : composite aperiodicity information
%       filterObject    : filter information structure such as spectrogram
%       sythesisInformation     : control parameters for synthesis
%   Outputs
%       synthesisResults    : structure variable consisting of synthesized
%                           : signal and synthesis conditions
%
%   Usage
%       synthesisResults = ...
%           exTandemSTRAIGHTsynth(sourceObject,filterObject)
%               simply resynthesizes using analysis results
%
%       synthesisResults = ...
%           exTandemSTRAIGHTsynth(sourceObject,filterObject,sythesisInformation)
%               control synthesis conditions

%   Designed and Coded by Hideki Kawahara
%   01/Nov./2007
%   10/Dec./2007 added DC removal
%   23/Sept./2008 extended source information control with vuv information
%   18/Oct./2008 adopted for composite aperiodicity information

switch nargin
    case 0
        synthesisResults = [];
        return;
    case 1
        [fs,fftl,vuvThLevel,defaultF0,movieOn,sourceTemporalPositions,...
            filterTemporalPositions,sqFilter,vuv,okInd] ...
            = checkAndInitialize(sourceObject);
    case 2
        [fs,fftl,vuvThLevel,defaultF0,movieOn,sourceTemporalPositions,...
            filterTemporalPositions,sqFilter,vuv,okInd] ...
            = checkAndInitialize(sourceObject,filterObject);
    case 3
        [fs,fftl,vuvThLevel,defaultF0,movieOn,sourceTemporalPositions,...
            filterTemporalPositions,sqFilter,vuv,okInd] ...
            = checkAndInitialize(sourceObject,filterObject,sythesisInformation);
end;
if okInd == 0
    synthesisResults = [];
    return;
end;
f0 = sourceObject.f0;

startPosition = min(sourceTemporalPositions(1),filterTemporalPositions(1));
endPosition = max(sourceTemporalPositions(end),filterTemporalPositions(end));
synthesisResults.dateOfSynthesis = datestr(now);
synthesisResults.startPosition = startPosition;
synthesisResults.endPosition = endPosition;
synthesisResults.samplingFrequency = fs;
synthesisResults.movieOn = movieOn;

signalTime = startPosition:1/fs:endPosition;
synthesisOut = 0*signalTime';

[pulseLocations,iPulseLocations,fractionalIndex,vuvinterpolated,f0interpolatedRaw] = ...
    timeBaseGeneration(sourceTemporalPositions,f0,fs,vuv,signalTime,defaultF0);

fftlSynthesis = (size(sqFilter,1)-1)*2;
bufferIndex = [0:fftlSynthesis/2 -(fftlSynthesis/2-1:-1:1)];
fxForSynthesis = abs(bufferIndex)/fftlSynthesis*fs;
indexForOLA = circshift(bufferIndex',fftlSynthesis/2-1);
outputLength = length(synthesisOut);
tmpComplexCepstrum = zeros(fftlSynthesis,1);
latterIndex = fftlSynthesis/2+1:fftlSynthesis;

temporalPositionIndex = interp1(filterTemporalPositions, ...
    1:length(filterTemporalPositions),pulseLocations,'linear','extrap');
temporalPositionIndex = max(1,min(length(filterTemporalPositions), ...
    temporalPositionIndex));

%------ energy allocation based on noise component -----

if isfield(sourceObject,'aperiodicitySigomoid')
    disp('sigmoidal aperiodicity model')
    frequencyAxis = apDisplayStructure.frequencyAxis;
    apDisplayStructure = ...
        displaySigmoidAperiodicity(frequencyAxis,sourceObject.aperiodicitySigomoid);
elseif isfield(sourceObject,'sigmoidParameter')
    disp('constrained sigmoidal model')
    apDisplayStructure = ...
        aperiodicityDisplayFast(sourceObject,fftlSynthesis);
else
    apDisplayStructure = displayAperiodicityStructure(sourceObject);
end;
%amplitudeRandom = sourceObject.amplitudeRandom;
amplitudeRandom = apDisplayStructure.randomComponent;
%amplitudeRandom = apDisplayStructure.randomComponent*0.001+0.001; % test
amplitudePeriodic = sqrt(max(0.001,(1-amplitudeRandom.^2)));
%amplitudeRandom = max(0.01,amplitudeRandom); % 23/Jan./2012

%------ end of energy allocation ---
ampSize = size(amplitudeRandom,1);
ampPulse = interp1((0:ampSize-1)/(ampSize-1), ...
    amplitudePeriodic,(0:size(sqFilter,1)-1)/(size(sqFilter,1)-1),...
    'linear','extrap').^2;
ampNoise = interp1((0:ampSize-1)/(ampSize-1), ...
    amplitudeRandom,(0:size(sqFilter,1)-1)/(size(sqFilter,1)-1),...
    'linear','extrap').^2;
tic
if movieOn == 1
    figure;
end;
%dcRemover = hanning(fftlSynthesis);
%dcRemover = dcRemover/sum(dcRemover);
dcRemoverCore = zeros(fftlSynthesis,1);
dcRemoverCenter = fftlSynthesis/2+1;
%responseShaper = ones(fftlSynthesis,1);
%dcRemoverSize = floor(fs/200); % 2009.10.24 H.K.
%    %dcRemoverSize = fftlSynthesis/2-1; % this is for test
%dcRemoverBase = -dcRemoverSize:dcRemoverSize;
%dcRemover = dcRemoverCore;
%tmpW = hanning(length(dcRemoverBase));
%responseShaper(dcRemoverCenter+dcRemoverBase) = ...
%    responseShaper(dcRemoverCenter+dcRemoverBase)-tmpW;
%responseShaper = fftshift(responseShaper);

%h1 = figure;
%h2 = figure;
for ii = 1:length(iPulseLocations)
    t1 = filterTemporalPositions(floor(temporalPositionIndex(ii)));
    t2 = filterTemporalPositions(ceil(temporalPositionIndex(ii)));
    if t1 == t2
        spectrumSlice = sqFilter(:,floor(temporalPositionIndex(ii)));
    else
        spectrumSlice = ...
            interp1q([t1 t2],[sqFilter(:,floor(temporalPositionIndex(ii))) ...
            sqFilter(:,ceil(temporalPositionIndex(ii)))]', ... 
            max(t1,min(t2,pulseLocations(ii))))';%, ...
            %'lineear','extrap')';
    end;
    t1 = sourceTemporalPositions(floor(temporalPositionIndex(ii)));
    t2 = sourceTemporalPositions(ceil(temporalPositionIndex(ii)));
    if t1 == t2
        ampPulseSlice = ampPulse(:,floor(temporalPositionIndex(ii)));
        ampNoiseSlice = ampNoise(:,floor(temporalPositionIndex(ii)));
    else
        ampPulseSlice = ...
            interp1q([t1 t2],[ampPulse(:,floor(temporalPositionIndex(ii))) ...
            ampPulse(:,ceil(temporalPositionIndex(ii)))]', ...
            max(t1,min(t2,pulseLocations(ii))))';%, ...
            %'lineear','extrap')';
        ampNoiseSlice = ...
            interp1q([t1 t2],[ampNoise(:,floor(temporalPositionIndex(ii))) ...
            ampNoise(:,ceil(temporalPositionIndex(ii)))]', ...
            max(t1,min(t2,pulseLocations(ii))))';%, ...
    end;
    tmpPulseSpectrum = spectrumSlice.*ampPulseSlice;
    if sum(tmpPulseSpectrum==0)>0;tmpPulseSpectrum(tmpPulseSpectrum==0) = eps;end;
    PulseSpectrum = [tmpPulseSpectrum;tmpPulseSpectrum(end-1:-1:2)];
    fractionalF0phase = ...
        2*pi*fractionalIndex(ii)*bufferIndex'/fftlSynthesis;
    tmpCepstrum = fft(log(abs(PulseSpectrum)')/2);
    tmpComplexCepstrum(latterIndex) = tmpCepstrum(latterIndex)*2;
    tmpComplexCepstrum(1) = tmpCepstrum(1);
    response = ...
        fftshift(real(ifft(exp(ifft(tmpComplexCepstrum)).* ...
        exp(1i*fractionalF0phase))))*vuvinterpolated(iPulseLocations(ii));
    %figure(h1);plot(response);grid on;drawnow;title([num2str(ii) ' at ' num2str(iPulseLocations(ii))]);
    %figure(h2);if sum(spectrumSlice)>0;plot(10*log10(spectrumSlice));grid on;drawnow;end;pause;
    outputBufferIndex = ...
        max(1,min(outputLength,iPulseLocations(ii)+indexForOLA));
    %outputBufferIndexNoise = min(outputLength,outputBufferIndex+fftlSynthesis/2);
    %f0tmp = max(1,f0interpolatedRaw(ii));
    f0tmp = max(1,f0interpolatedRaw(iPulseLocations(ii))); % 2012.8.3 H.K., suggested by Hirai
    dcRemoverSize = min(fftlSynthesis/2-1,floor(fs/f0tmp)); % 2009.10.24 H.K.
    %dcRemoverSize = fftlSynthesis/2-1; % this is for test
    dcRemoverBase = -dcRemoverSize:dcRemoverSize;
    dcRemover = dcRemoverCore;
    tmpW = hanning(length(dcRemoverBase));
    dcRemover(dcRemoverCenter+dcRemoverBase) = ...
        dcRemover(dcRemoverCenter+dcRemoverBase)+tmpW/sum(tmpW);
    noiseSize = ...
        iPulseLocations(min(length(iPulseLocations),ii+1))-iPulseLocations(ii);
    synthesisOut(outputBufferIndex) = ...
        synthesisOut(outputBufferIndex)+(response-dcRemover*sum(response))*sqrt(max(1,noiseSize));
    if vuvinterpolated(iPulseLocations(ii)) < 0.5
        tmpNoiseSpectrum = spectrumSlice;
    else
        tmpNoiseSpectrum = spectrumSlice.*ampNoiseSlice;
    end;
    if sum(tmpNoiseSpectrum==0)>0;tmpNoiseSpectrum(tmpNoiseSpectrum==0) = eps;end;
    NoiseSpectrum = [tmpNoiseSpectrum;tmpNoiseSpectrum(end-1:-1:2)];
    tmpCepstrum = fft(log(abs(NoiseSpectrum)')/2);
    tmpComplexCepstrum(latterIndex) = tmpCepstrum(latterIndex)*2;
    tmpComplexCepstrum(1) = tmpCepstrum(1);
    response = ...
        fftshift(real(ifft(exp(ifft(tmpComplexCepstrum)).* ...
        exp(i*fractionalF0phase)))); % .*responseShaper; (this part was not useful)
    noiseSize = ...
        iPulseLocations(min(length(iPulseLocations),ii+1))-iPulseLocations(ii);
    noiseSize = max(3,noiseSize);
    noiseInput = randn(noiseSize,1);
    synthesisOut(outputBufferIndex) = ...
        synthesisOut(outputBufferIndex)+...
        fftfilt(noiseInput-mean(noiseInput),response);

    if movieOn == 1
        plot(fxForSynthesis(1:length(spectrumSlice)),10*log10(spectrumSlice));
        axis([0 fs/2 -100 40]);grid on;
        drawnow;
    end;
end;
elapsedTimeForSynthesis = toc;

synthesisResults.synthesisOut = synthesisOut;
synthesisResults.FFTsizeInSynthesis = fftlSynthesis;
synthesisResults.elapsedTimeForSynthesis = elapsedTimeForSynthesis;

%------- internal functions
function [fs,fftl,vuvThLevel,defaultF0,movieOn,sourceTemporalPositions,...
    filterTemporalPositions,sqFilter,vuv,okInd] ...
    = checkAndInitialize(sourceObject,filterObject,sythesisInformation)

okInd = 0;
if isfield(sourceObject,'procedure') == 0
    synthesisResults = [];
    disp('field:procedure does not exist.');
    return;
end;
if (strcmp(sourceObject.procedure,'aperiodicityRatio') == 0) && ...
        (strcmp(sourceObject.procedure,'aperiodicityRatioSigmoid') == 0) && ...
        (strcmp(sourceObject.procedure,'aperiodicityRatioSigmoid3') == 0) && ...
        (strcmp(sourceObject.procedure,'aperiodicityRatioSigmoid5') == 0)
    synthesisResults = [];
    disp('source information was not produced by <aperiodicityRatio>.');
    return;
end;
%---- initialize default parameters
fs = 44100; % default sampling frequency
fftl = 2048; % default FFT size
vuvThLevel = 1.42/2; % default vuv threshold
defaultF0 = 500; % default F0 for unvoiced synthesis
movieOn = 0;
switch nargin
    case 0
        synthesisResults = [];
        return;
    case 1
        if ~isfield(sourceObject,'temporalPositions')
            error('no field: temporalPositions');
        end;
        if ~isfield(sourceObject,'samplingFrequency')
            error('no field: samplingFrequency');
        end;
        f0 = sourceObject.f0;
        sourceTemporalPositions = sourceObject.temporalPositions;
        sqFilter = ones(fftl/2+1,length(sourceTemporalPositions));
        filterTemporalPositions = sourceTemporalPositions;
        fs = sourceObject.samplingFrequency;
        if isfield(sourceObject,'vuv')
            vuv = sourceObject.vuv;
        else
            vuv = sourceObject.periodicityLevel > vuvThLevel;
            disp('VUV information is not given. Default is applied.');
        end;
    case {2,3}
        if ~isfield(sourceObject,'temporalPositions')
            synthesisResults = [];
            return;
        end;
        if ~isfield(sourceObject,'samplingFrequency')
            synthesisResults = [];
            return;
        end;
        if ~isfield(filterObject,'temporalPositions')
            synthesisResults = [];
            return;
        end;
        if ~isfield(filterObject,'samplingFrequency')
            synthesisResults = [];
            return;
        end;
        if ~isfield(filterObject,'spectrogramSTRAIGHT')
            synthesisResults = [];
            return;
        end;
        f0 = sourceObject.f0;
        sourceTemporalPositions = sourceObject.temporalPositions;
        sqFilter = filterObject.spectrogramSTRAIGHT;
        filterTemporalPositions = filterObject.temporalPositions;
        fs = sourceObject.samplingFrequency;
        if isfield(sourceObject,'vuv')
            vuv = sourceObject.vuv;
        else
            vuv = sourceObject.periodicityLevel > vuvThLevel;
        end;
        %disp('here!')
        if nargin == 3
            if isfield(sythesisInformation,'movieOn')
                movieOn = sythesisInformation.movieOn;
            end;
        end;
end;
okInd = 1;

function [pulseLocations,iPulseLocations,fractionalIndex,vuvinterpolated,f0interpolatedRaw] = ...
    timeBaseGeneration(sourceTemporalPositions,f0,fs,vuv,signalTime,defaultF0)

f0interpolatedRaw = ...
    interp1(sourceTemporalPositions,f0,signalTime,'linear','extrap');
vuvinterpolated = ...
    interp1(sourceTemporalPositions,vuv,signalTime,'linear','extrap');
vuvinterpolated = vuvinterpolated>0.5;
f0interpolated = f0interpolatedRaw.*vuvinterpolated;
f0interpolated(f0interpolated == 0) = ...
    f0interpolated(f0interpolated == 0)+defaultF0;

%figure;plot(signalTime,f0interpolated);grid on;

totalPhase = cumsum(2*pi*f0interpolated/fs);
pulseLocations = signalTime(abs(diff(rem(totalPhase,2*pi)))>pi/2);
iPulseLocations = round(pulseLocations*fs)+1;
fractionalIndex = ...
    (rem(totalPhase(abs(diff(rem(totalPhase,2*pi)))>pi/2),pi)-pi)./ ...
    (2*pi*f0interpolated(abs(diff(rem(totalPhase,2*pi)))>pi/2)/fs);

