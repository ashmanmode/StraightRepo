function [f0raw,periodicityRating,statusParams] = ...
    TANDEMf0GB(x,fs,tc,f0floor,f0ceil,optP)
%   F0 extraction based on TANDEM-STRAIGHT
%   [f0raw,periodicityRating,statusParams] = ...
%       exTANDEMf0GB(x,fs,tc,f0floor,f0ceil,optP)
%   Input parameters
%       x   : input signal
%       fs  : sampling frequency (Hz)
%       tc  : current time (second)
%       f0floor     : lowest assumed F0 (Hz)
%       f0ceil      : highest assumed F0 (Hz)
%       optP        : optional parameters

%   Designed and coded by Hideki Kawahara
%   13/Oct./2007
%   14/Oct./2007 revised
%   17/Oct./2007 extended for single band indicator
%   18/Oct./2007 weighting allocation
%   18/Oct./2007 weighting allocation restored to the original
%   19/Oct./2007 specialized tandem straight
%   20/Oct./2007 replaced by general Blackman
%   29/Oct./2007 multiple candidate extraction
%   01/Nov./2007 revised TANDEM-STRIGHT function
%   11/Dec./2007 compatibility fix by Hideki Banno
%   16/Dec./2007 renamed
%   23/April/2010 fine tuning
%   17/May/2011 added switch for compatibility

%--- optional parameter check
biasCorrection = 0.06;
if nargin == 6
    cycles = optP.cycles;
    channelsPerOctave = optP.channelsPerOctave;
    tuningFactor = optP.tuningFactor;
    isSingleBand = optP.isSingleBand;
    correctionForBlackman = optP.correctionForBlackman;
    periodicityShaping = optP.periodicityShaping;
    lagShapingType = 'logarithmic';
    if isfield(optP,'DCremoval')
        optionalParams.DCremoval = optP.DCremoval;
    end;
    if isfield(optP,'exponentControl')
        optionalParams.exponentControl = optP.exponentControl;
    end;
    if isfield(optP,'lagShapingType')
        optionalParams.lagShapingType = optP.lagShapingType;
        lagShapingType = optP.lagShapingType;
    end;
    if isfield(optP,'biasCorrection')
        optionalParams.biasCorrection = optP.biasCorrection;
        biasCorrection = optP.biasCorrection;
    end;
    q1 = optP.q1;
else
    cycles = 5;
    channelsPerOctave = 2;
    tuningFactor = 0.1;
    isSingleBand = 1;
    periodicityShaping = 2.5;
    correctionForBlackman = 4; % 18/Oct./2009 H.K.
    %exponentControl = 0;
    q1 = 0;
end;
optionalParams.correctionForBlackman = correctionForBlackman;
optionalParams.q1 = q1;
optionalParams.cepstralSmoothing = 0; % 17/May/1011 by H.K.

%--- initial analysis assuming downsampling was already done

tSTRAIGHTresults = ...
    TandemSTRAIGHTGeneralBody(x,fs,f0floor,tc,f0floor,optionalParams);
sliceSTRAIGHT = tSTRAIGHTresults.sliceSTRAIGHT;
sliceTANDEM = tSTRAIGHTresults.sliceTANDEM;
fftl = (length(sliceSTRAIGHT)-1)*2;

cumulativePeriodicity = sliceSTRAIGHT*0;
%cumulativePPower = sliceSTRAIGHT*0; % 01/Nov./2009 H.K.
lagBase = 1:size(cumulativePeriodicity,1);
lagSize = length(lagBase);
numberOfOctave = ceil(log2(f0ceil/f0floor)*channelsPerOctave)/channelsPerOctave;

bandTable = f0floor*2.0.^(0:1/channelsPerOctave:numberOfOctave);
if isSingleBand == 1
    bandTable = bandTable(1);
end;

bandPower = zeros(length(bandTable),1);
bandIndex = 1;
for currentF0 = bandTable
    if currentF0 > f0floor
        tSTRAIGHTresults = ...
            TandemSTRAIGHTGeneralBody(x,fs,currentF0,tc,f0floor,optionalParams);
        sliceSTRAIGHT = tSTRAIGHTresults.sliceSTRAIGHT;
        sliceTANDEM = tSTRAIGHTresults.sliceTANDEM;
    end;
    periodLength = (currentF0/fs*fftl);
    baseAxis = 0:periodLength*cycles;
    filterLength = min(fftl/2+1,length(baseAxis));
    baseAxis = baseAxis(1:filterLength);
    lagFilter = (0.5+0.5*cos(pi*baseAxis/periodLength/cycles))';
    lagFilter = lagFilter/sum(lagFilter);
    normalizedSpectrum = (sliceTANDEM./sliceSTRAIGHT)-1;
    weightedSpectrum = zeros(fftl,1);
    weightedSpectrum(1:filterLength) = ...
        normalizedSpectrum(1:filterLength).*lagFilter;
    weightedSpectrum(end:-1:end-(filterLength-2)) = ...
        weightedSpectrum(2:filterLength);
    modulationCorrelation = real(fft(weightedSpectrum));
    bandPower(bandIndex) = sum(sliceSTRAIGHT(1:filterLength).*lagFilter); % 01/Nov./2009 H.K.
    bandIndex = bandIndex+1;
    lagAxis = (lagBase-1)/fs;
    lagAxis(1) = 0.1/fs;
    logLagAxis = log2(lagAxis/(1/currentF0))*periodicityShaping;
    lagWeight = (0.5+0.5*cos(pi*logLagAxis)).*(abs(logLagAxis)<1);
    reciprocalLagAxis = 1.0./(lagAxis*currentF0);%/fs./(lagBase*currentF0);
    stretchdReciprocalLagAxis = (reciprocalLagAxis-1)*periodicityShaping;
    lagWeightReciprocal = (0.5+0.5*cos(pi*stretchdReciprocalLagAxis)).*(abs(stretchdReciprocalLagAxis)<1);
    switch lagShapingType
        case 'logarithmic'
            lagWeightReciprocal = lagWeight;
        case 'reciprocal'
    end;
    cumulativePeriodicity = cumulativePeriodicity ...
        + modulationCorrelation(lagBase).*lagWeightReciprocal'* ...
        (currentF0/f0floor)^tuningFactor;
end;
[peakLevel,peakPosition] = max(cumulativePeriodicity);
y = cumulativePeriodicity(max(1,min(lagSize,peakPosition+[-1 1])))- ...
    cumulativePeriodicity(peakPosition);
fineLag = (peakPosition-1)-(y(2)-y(1))/(y(1)+y(2))/2;
cumulativePPower = interp1(1.0./[bandTable(1)*0.9 bandTable bandTable(end)*1.1],...
    [bandPower(1);bandPower;bandPower(end)],lagAxis,'linear','extrap');

scanLine = cumulativePeriodicity;
peaksTmp = (diff([0;scanLine]).*diff([scanLine;0])<0).*(diff([0;scanLine])>0);
peakIndices = (1:size(peaksTmp,1))'.*peaksTmp;
peakIndices = peakIndices(peakIndices>0);
ym1 = scanLine(max(1,peakIndices-1))-scanLine(peakIndices);
yp1 = scanLine(min(lagSize,peakIndices+1))-scanLine(peakIndices);
fineLagVector = (peakIndices-1)-(yp1-ym1)./(ym1+yp1)/2;

%--- output section
f0raw = fs/(fineLag-biasCorrection);
f0candidates = fs./(fineLagVector-biasCorrection);
f0candidatesRatings = scanLine(peakIndices);
f0candidatedPower = cumulativePPower(peakIndices);
if sscanf(version('-release'), '%d') < 2006
    [sortedValue,sortedIndex]=sort(f0candidatesRatings);
    sortedValue = sortedValue(end:-1:1);
    sortedIndex = sortedIndex(end:-1:1);
else
    [sortedValue,sortedIndex]=sort(f0candidatesRatings,'descend');
end
f0candidates = f0candidates(sortedIndex);
f0candidatesRatings = sortedValue;
f0candidatesPower = f0candidatedPower(sortedIndex); % 01/Nov./2009 H.K.
periodicityRating = peakLevel;
statusParams.cumulativePeriodicity = cumulativePeriodicity;
statusParams.cumulativePPower = cumulativePPower;
statusParams.numberOfOctave = numberOfOctave;
statusParams.finalCurrentF0 = currentF0;
statusParams.totalNumberOfBands = length(bandTable);
statusParams.fftl = fftl;
statusParams.filterLength = filterLength;
statusParams.peakLevel = peakLevel;
statusParams.peakPosition = peakPosition;
statusParams.f0candidates = f0candidates;
statusParams.f0candidatesRatings = f0candidatesRatings;
statusParams.f0candidatesPower = f0candidatesPower; % 01/Nov./2009 H.K.
statusParams.tSTRAIGHTanalysisConditions = tSTRAIGHTresults.analysisConditions;
