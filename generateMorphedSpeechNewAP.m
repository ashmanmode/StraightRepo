%  function morphedSignal = generateMorphedSpeechNewAP(mSubstrate,opt)
function morphedSignal = generateMorphedSpeechNewAP(mSubstrate)

%   Designed and coded by Hideki Kawahara
%   09/Sept./2008
%   21/Oct./2008 extended to new aperiodicity measure
%   07/Nov./2008 revised default conditions
%   21/April/2012 revised for compatibility with R2011a and later
%   21/June/2012 bug fix on VUV
%   26/June/2012 bug fix that was introduced compatibility hack

%   generate morphed temporal axis in sampling rate resolution

timeAnchor = tic;
displayOn = 0;
switch nargin
    case 2
        isfield(opt,'displayOn')
        displayOn = opt.displayOn;
end;

fs = mSubstrate.samplintFrequency;
realTimeBase = generateMorphingRealTimeAxis(mSubstrate);
samplingPoints = 0:1/fs:realTimeBase.mapMtoSonM(end);
outputBuffer = 0*samplingPoints';
outputBufferFIR = 0*samplingPoints';

%   generate interpolated f0 information to set event location
%   event is pitch pulse for voiced sounds
%   event is a synthesis frame for unvoiced sounds
%   It has to be extended to add signle event such as click or plosive
%   sounds

lengthTimeOnM = length(realTimeBase.mapMtoAonM);
morphedF0onM = zeros(lengthTimeOnM,1);
morphedvuvonM = zeros(lengthTimeOnM,1);
%---------- copy aperiodicity information
aperiodicityFixA = mSubstrate.aperiodicityOfSpeakerA.residualMatrixFix;
aperiodicityFixB = mSubstrate.aperiodicityOfSpeakerB.residualMatrixFix;
aperiodicityOrgA = mSubstrate.aperiodicityOfSpeakerA.residualMatrixOriginal;
aperiodicityOrgB = mSubstrate.aperiodicityOfSpeakerB.residualMatrixOriginal;
cutOffListFixA = mSubstrate.aperiodicityOfSpeakerA.cutOffListFix;
cutOffListOriginalA = mSubstrate.aperiodicityOfSpeakerA.cutOffListOriginal;
targetF0A = mSubstrate.aperiodicityOfSpeakerA.targetF0;
cutOffListFixB = mSubstrate.aperiodicityOfSpeakerB.cutOffListFix;
cutOffListOriginalB = mSubstrate.aperiodicityOfSpeakerB.cutOffListOriginal;
targetF0B = mSubstrate.aperiodicityOfSpeakerB.targetF0;
aperiodicityTimeBaseA = mSubstrate.aperiodicityOfSpeakerA.temporalPositions;
aperiodicityTimeBaseB = mSubstrate.aperiodicityOfSpeakerB.temporalPositions;
%----------
mSubstrate.f0OfSpeakerA = cleanUpF0(mSubstrate.f0OfSpeakerA);
mSubstrate.f0OfSpeakerB = cleanUpF0(mSubstrate.f0OfSpeakerB);
tmpMinTime = min(mSubstrate.f0TimeBaseOfSpeakerA);
tmpMaxTime = max(mSubstrate.f0TimeBaseOfSpeakerA);
F0ofAonA = interp1q(mSubstrate.f0TimeBaseOfSpeakerA',mSubstrate.f0OfSpeakerA, ...
    max(tmpMinTime,min(tmpMaxTime,realTimeBase.mapMtoAonM)));%,'linear','extrap');
tmpMinTime = min(mSubstrate.f0TimeBaseOfSpeakerB);
tmpMaxTime = max(mSubstrate.f0TimeBaseOfSpeakerB);
F0ofBonB = interp1q(mSubstrate.f0TimeBaseOfSpeakerB',mSubstrate.f0OfSpeakerB, ...
    max(tmpMinTime,min(tmpMaxTime,realTimeBase.mapMtoBonM)));%,'linear','extrap');
%---------- for vuv processing by HK at 12/June/2011
if isfield(mSubstrate.aperiodicityOfSpeakerA,'vuv') && ...
        isfield(mSubstrate.aperiodicityOfSpeakerB,'vuv') % bug fixed A-->B 2012.Aug.3 H.K.
    vuvOn = 1;
    tmpMinTime = min(mSubstrate.aperiodicityTimeBaseOfSpeakerA);
    tmpMaxTime = max(mSubstrate.aperiodicityTimeBaseOfSpeakerA);
    vuvofAonA = interp1q(mSubstrate.aperiodicityTimeBaseOfSpeakerA',...
        mSubstrate.aperiodicityOfSpeakerA.vuv, ...
        max(tmpMinTime,min(tmpMaxTime,realTimeBase.mapMtoAonM))); %% This was the bug!! 2012.6.21
        %realTimeBase.mapMtoAonM,'linear','extrap');
    tmpMinTime = min(mSubstrate.aperiodicityTimeBaseOfSpeakerB);
    tmpMaxTime = max(mSubstrate.aperiodicityTimeBaseOfSpeakerB);
    vuvofBonB = interp1q(mSubstrate.aperiodicityTimeBaseOfSpeakerB',...
        mSubstrate.aperiodicityOfSpeakerB.vuv, ...
        max(tmpMinTime,min(tmpMaxTime,realTimeBase.mapMtoBonM)));
        %realTimeBase.mapMtoBonM,'linear','extrap');
else
    vuvOn = 0;
end;
for ii = 1:lengthTimeOnM
    morphedF0onM(ii) = (1-mSubstrate.temporalMorphingRate.F0(ii))* ...
        F0ofAonA(ii)+mSubstrate.temporalMorphingRate.F0(ii)*F0ofBonB(ii);
end;
boundedSamplingPoints = max(min(realTimeBase.mapMtoSonM),max(min(realTimeBase.mapMtoSonM),samplingPoints))';
if vuvOn
    for ii = 1:lengthTimeOnM
        morphedvuvonM(ii) = (1-mSubstrate.temporalMorphingRate.F0(ii))* ...
            vuvofAonA(ii)+mSubstrate.temporalMorphingRate.F0(ii)*vuvofBonB(ii);
    end;
    vuvonSamplingPoints = interp1q(realTimeBase.mapMtoSonM, ...
        morphedvuvonM,boundedSamplingPoints);%,'linear','extrap');
end;
f0onSamplingPoints = interp1q(realTimeBase.mapMtoSonM, ...
    morphedF0onM,boundedSamplingPoints);%,'linear','extrap');
totalPhase = cumsum(f0onSamplingPoints*2*pi/fs);
basePhase = 0;
eventCount = 0;
eventLocations = f0onSamplingPoints*0;
eventTime = eventLocations;
for ii = 1:length(f0onSamplingPoints)
    if totalPhase(ii)-basePhase>2*pi
        basePhase = basePhase+2*pi;
        fractionalPhase = totalPhase(ii)-basePhase;
        %outputBuffer(ii) = 1;
        eventCount = eventCount+1;
        eventLocations(eventCount) = ii + fractionalPhase/(2*pi/fs*f0onSamplingPoints(ii));
        eventTime(eventCount) = samplingPoints(ii);
    end;
end;
eventLocations = eventLocations(1:eventCount);
eventTime = eventTime(1:eventCount);
deltaTT = realTimeBase.timeOnM(2); % The following 11 lines are fixed. 26/JUne/2012 H.K.
extendedMapMtoSonM = [0;realTimeBase.mapMtoSonM;realTimeBase.mapMtoSonM(end)+deltaTT];
extendedTimeOnM = [0;realTimeBase.timeOnM;realTimeBase.timeOnM(end)+deltaTT];
extendedMapMtoAonM = [0;realTimeBase.mapMtoAonM;realTimeBase.mapMtoAonM(end)+deltaTT];
extendedMapMtoBonM = [0;realTimeBase.mapMtoBonM;realTimeBase.mapMtoBonM(end)+deltaTT];
eventTimeOnM = interp1q(extendedMapMtoSonM,extendedTimeOnM,eventTime);
eventTimeOnA = interp1q(extendedTimeOnM,extendedMapMtoAonM,eventTimeOnM);
eventTimeOnB = interp1q(extendedTimeOnM,extendedMapMtoBonM,eventTimeOnM);%,'linear','extrap');
extendedIndex = [1 1:lengthTimeOnM lengthTimeOnM];
frequencyMorphingRateOnEvent = interp1q(extendedMapMtoSonM,...
    mSubstrate.temporalMorphingRate.frequency(extendedIndex),eventTime);%,'linear','extrap');
levelMorphingRateOnEvent = interp1(realTimeBase.mapMtoSonM,...
    mSubstrate.temporalMorphingRate.spectrum,eventTime,'linear','extrap');
spectumAonEvnet = interp1(mSubstrate.spectrogramTimeBaseOfSpeakerA, ...
    (mSubstrate.STRAIGHTspectrogramOfSpeakerA)',eventTimeOnA,'linear','extrap')';
spectumBonEvnet = interp1(mSubstrate.spectrogramTimeBaseOfSpeakerB, ...
    (mSubstrate.STRAIGHTspectrogramOfSpeakerB)',eventTimeOnB,'linear','extrap')';

aperiodicityFixAonEvnet = interp1(aperiodicityTimeBaseA,aperiodicityFixA',eventTimeOnA,'linear','extrap')';
aperiodicityFixBonEvnet = interp1(aperiodicityTimeBaseB,aperiodicityFixB',eventTimeOnB,'linear','extrap')';
aperiodicityOrgAonEvnet = interp1(aperiodicityTimeBaseA,aperiodicityOrgA',eventTimeOnA,'linear','extrap')';
aperiodicityOrgBonEvnet = interp1(aperiodicityTimeBaseB,aperiodicityOrgB',eventTimeOnB,'linear','extrap')';

f0StretchAonEvnet = interp1(aperiodicityTimeBaseA, ...
    mSubstrate.f0OfSpeakerA/targetF0A,eventTimeOnA,'linear','extrap')';
f0StretchBonEvnet = interp1(aperiodicityTimeBaseB, ...
    mSubstrate.f0OfSpeakerB/targetF0B,eventTimeOnB,'linear','extrap')';
aperiodicityMrateOnEvent = interp1(mSubstrate.morphingTimeAxis, ...
    mSubstrate.temporalMorphingRate.aperiodicity,eventTimeOnM,'linear','extrap')';

numberOfTimeAnchors = length(mSubstrate.temporaAnchorOfSpeakerA);
frequencyMappingForAtoB = zeros(size(spectumAonEvnet,1),numberOfTimeAnchors);
%   note that this mapping is a linear lintepolation. This should be
%   replaced
frequencyAxis = (0:size(spectumAonEvnet,1)-1)/(size(spectumAonEvnet,1)-1)*fs/2;
for ii = 1:numberOfTimeAnchors
    if mSubstrate.frequencyAnchorOfSpeakerA.counts(ii) > 0
        counts = mSubstrate.frequencyAnchorOfSpeakerA.counts(ii);
        extendedFrequencyAnchorsA = [0 mSubstrate.frequencyAnchorOfSpeakerA.frequency(ii,1:counts) fs/2];
        extendedFrequencyAnchorsB = [0 mSubstrate.frequencyAnchorOfSpeakerB.frequency(ii,1:counts) fs/2];
    else
        extendedFrequencyAnchorsA = [0 fs/2];
        extendedFrequencyAnchorsB = [0 fs/2];
    end;
    frequencyMappingForAtoB(:,ii) = ...
        interp1(extendedFrequencyAnchorsA,extendedFrequencyAnchorsB,frequencyAxis,'linear','extrap');
end;

fftl = (size(spectumAonEvnet,1)-1)*2;
baseIndex = ((1:fftl)-fftl/2-1)';
maxIndex = length(outputBuffer);
morphedSpectrumOnEvent = spectumAonEvnet*0;
morphedFrequencyMapping = morphedSpectrumOnEvent;
if displayOn; figure; end;
for ii = 1:eventCount
    boundedEventTimeOnA = max(0,min(mSubstrate.spectrogramTimeBaseOfSpeakerA(end),eventTimeOnA(ii)));
    currentFrequencyMappingAtoB = ...
        interp1q([0;mSubstrate.temporaAnchorOfSpeakerA;mSubstrate.spectrogramTimeBaseOfSpeakerA(end)]...
        ,[frequencyAxis(:),frequencyMappingForAtoB,frequencyAxis(:)]',...
        boundedEventTimeOnA);
        %eventTimeOnA(ii),'linear','extrap');
    morphedFrequencyMappingAtoB = frequencyAxis(:)+ ...
        (currentFrequencyMappingAtoB(:)-frequencyAxis(:))*frequencyMorphingRateOnEvent(ii);
    currentIndex = max(1,min(maxIndex,round(baseIndex+eventLocations(ii))));
    currentPoint = max(1,min(maxIndex,round(eventLocations(ii))));
    nextPoint = max(1,min(maxIndex,round(eventLocations(min(eventCount,ii+1)))));
    morphedFrequencyMapping(:,ii) = currentFrequencyMappingAtoB;
    spectrumA = log(abs(spectumAonEvnet(:,ii)));
    spectrumB = log(abs(spectumBonEvnet(:,ii)));
    spectrumBonA = interp1(frequencyAxis,spectrumB,currentFrequencyMappingAtoB(:),'linear','extrap');
    if displayOn
        semilogx(frequencyAxis,spectrumA,frequencyAxis,real(spectrumBonA),frequencyAxis,spectrumB);grid on;
        title(num2str(eventTime(ii)));
        axis([100 fs/2 -15 10])
        drawnow;%pause(0.2)
    end;
    morphedSpectrumOnA = exp((1-levelMorphingRateOnEvent(ii))*spectrumA+...
        levelMorphingRateOnEvent(ii)*real(spectrumBonA));
    tmpMinimumFrequency = min(morphedFrequencyMappingAtoB);
    tmpMaximumFrequency = max(morphedFrequencyMappingAtoB);
    morphedSpectrum = interp1q(morphedFrequencyMappingAtoB,morphedSpectrumOnA,...
        max(tmpMinimumFrequency,min(tmpMaximumFrequency,frequencyAxis(:))));%,'linear','extrap');
    firResponse = fftshift(real(ifft(sqrt([morphedSpectrum; ...
        morphedSpectrum(end-1:-1:2)]))));
    morphedSpectrumOnEvent(:,ii) = morphedSpectrum;
    randomFractionA = aperiodicSpectrum(cutOffListOriginalA,cutOffListFixA,f0StretchAonEvnet(ii), ...
        aperiodicityOrgAonEvnet(:,ii),aperiodicityFixAonEvnet(:,ii),fs,fftl);
    randomFractionB = aperiodicSpectrum(cutOffListOriginalB,cutOffListFixB,f0StretchBonEvnet(ii), ...
        aperiodicityOrgBonEvnet(:,ii),aperiodicityFixBonEvnet(:,ii),fs,fftl);
    randomFraction = exp((1-aperiodicityMrateOnEvent(ii))*log(randomFractionA)+ ...
        aperiodicityMrateOnEvent(ii)*log(randomFractionB));
    if vuvOn
        if vuvonSamplingPoints(min(length(vuvonSamplingPoints),round(eventLocations(ii)))) < 0.5
            randomFraction = randomFraction*0+0.999;
        end;
    end
    outputBuffer(currentIndex) = outputBuffer(currentIndex)...
        +spectrum2minimumPhaseEx(morphedSpectrum,randomFraction,(nextPoint-currentPoint));
    outputBufferFIR(currentIndex) = outputBufferFIR(currentIndex)+firResponse;
end;

%   output results
morphedSignal.f0onSamplingPoints = f0onSamplingPoints;
morphedSignal.outputBuffer = outputBuffer;
morphedSignal.outputBufferFIR = outputBufferFIR;
morphedSignal.eventLocations = eventLocations;
morphedSignal.spectumAonEvnet = spectumAonEvnet;
morphedSignal.frequencyMappingForAtoB = frequencyMappingForAtoB;
morphedSignal.frequencyMorphingRateOnEvent = frequencyMorphingRateOnEvent;
morphedSignal.morphedSpectrumOnEvent = morphedSpectrumOnEvent;
morphedSignal.morphedFrequencyMapping = morphedFrequencyMapping;
morphedSignal.samplintFrequency = fs;
morphedSignal.elapsedTime = toc(timeAnchor);
morphedSignal.timeStamp = datestr(now);

%   Internal functions
function minimumPResponse = spectrum2minimumPhaseEx(halfSpectrum,randomFraction,skip)

if skip == 0;skip = 1;end;
periodicFraction = sqrt(1-randomFraction.^2);
spectralSlice = [halfSpectrum;halfSpectrum(end-1:-1:2)];
fftl = size(spectralSlice,1);
randomSignalSpectrum = fft(randn(skip,1),fftl);
symmetricCepstrum = fft(log(spectralSlice)/2);
baseSpectrum = exp(ifft([symmetricCepstrum(1); ...
    symmetricCepstrum(2:fftl/2)*0;symmetricCepstrum(fftl/2+1:end)*2]));
periodicResponse = fftshift(real(ifft(baseSpectrum.*[periodicFraction;periodicFraction(end-1:-1:2)])));
if size(randomSignalSpectrum) == size(baseSpectrum)
    randomResponse = fftshift(real(ifft(randomSignalSpectrum.*baseSpectrum.*[randomFraction;randomFraction(end-1:-1:2)])));
else
    randomResponse = periodicResponse*0;
end;
minimumPResponse = sqrt(skip)*periodicResponse+randomResponse;

function randomFraction = aperiodicSpectrum(staticCutOff,fixedCutOff,stretching, ...
    staticAPlevel,fixedAPlevel,fs,fftl)

halfFrequency = (0:fftl/2)/fftl*fs;
staticBoundaryList = [0;staticCutOff;fs/2];
fixedBoundaryList = [0;fixedCutOff;fs/2]*stretching;
originalPart = ...
    interp1q(staticBoundaryList,[0.005;staticAPlevel(:)],min(fs/2,halfFrequency)')';%,'linear','extrap');
fixedPart = ...
    interp1q(fixedBoundaryList,[0.005;fixedAPlevel(:)],min(max(fixedBoundaryList),halfFrequency)')';%,'linear','extrap');
randomFraction = min([fixedPart, originalPart],2)';
randomFraction = randomFraction(1:fftl/2+1);

return;

function f0 = cleanUpF0(f0)
f0 = f0;
if sum(isnan(f0)) > 0
    f0(isnan(f0)) = ones(length(f0),1)+mean(f0(~isnan(f0)));
else
    return;
end;
return;
