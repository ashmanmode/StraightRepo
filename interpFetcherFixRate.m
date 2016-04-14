function currentDataStructure = interpFetcherFixRate(commandString,dataSubstrate,currentDataStructure,feedingHandleOption)
%   currentDataStructure = interpFetcher(commandString,dataSubstrate,currentDataStructure)

%   STRAIGHT spectrum fetcher for generic STRAIGHT synthesizer
%   with linear interpolation
%   Designed and coded by Hideki Kawahara
%   (c) Hideki Kawahara 2012
%   23/Feb./2012
%   04/Mar./2012 source option is extended
%   25/Mar./2012 fixed rate parameter fetching is enabled

switch nargin
    case {1,2}
        currentDataStructure = [];
    case 4
        currentDataStructure = [];
        currentDataStructure.frameRateInSecond = feedingHandleOption.frameRateInSecond;
        frameRateInSecond = feedingHandleOption.frameRateInSecond;
end;
switch commandString
    case 'initialize'
        spectralSlice = dataSubstrate.spectrogramSTRAIGHT(:,1);
        fftLength = 2*(size(spectralSlice,1)-1);
        fs = dataSubstrate.samplingFrequency;
        temporalPositions = dataSubstrate.temporalPositions;
        timeBase = (0:1/fs:temporalPositions(end))';
        f0Interpolated = interp1(temporalPositions,dataSubstrate.f0,timeBase,'linear','extrap');
        if nargin == 4
            f0Interpolated = f0Interpolated*0+1/frameRateInSecond;
        end;
        phaseThread = cumsum(2*pi*f0Interpolated/fs);
        eventLocations = interp1(phaseThread,timeBase,(1:phaseThread(end)/2/pi)'*2*pi,'linear','extrap');
        eventLocations = eventLocations(eventLocations<temporalPositions(end));
        eventLocations = eventLocations(eventLocations>0);
        currentDataStructure.fftLength = fftLength;
        currentDataStructure.samplingFrequency = fs;
        currentDataStructure.originalF0 = dataSubstrate.f0;
        currentDataStructure.eventLocations = eventLocations;
        currentDataStructure.temporalPositions = temporalPositions;
        currentDataStructure.timeBase = timeBase;
        currentDataStructure.frameIndexList = ...
            interp1(temporalPositions,1:length(temporalPositions),eventLocations,'linear','extrap');
        currentDataStructure.eventCount = 1;
        currentDataStructure.maxFrameIndex = length(temporalPositions);
        currentDataStructure = sigmoidModeSourceShaper(commandString,dataSubstrate,currentDataStructure);
    case 'fetch'
        ii = currentDataStructure.eventCount;
        maxFrameIndex = currentDataStructure.maxFrameIndex;
        integerIndex = min(maxFrameIndex,max(1,floor(currentDataStructure.frameIndexList(ii))));
        fractionalIndex = currentDataStructure.frameIndexList(ii)-integerIndex;
        currentDataStructure.spectrum = dataSubstrate.spectrogramSTRAIGHT(:,integerIndex)*(1-fractionalIndex) ...
            +dataSubstrate.spectrogramSTRAIGHT(:,min(integerIndex+1,maxFrameIndex))*fractionalIndex;
        currentDataStructure.f0 = dataSubstrate.f0(integerIndex)*(1-fractionalIndex) ...
            +dataSubstrate.f0(min(integerIndex+1,maxFrameIndex))*fractionalIndex;
        currentDataStructure.vuv = dataSubstrate.vuv(integerIndex)*(1-fractionalIndex) ...
            +dataSubstrate.vuv(min(integerIndex+1,maxFrameIndex))*fractionalIndex;
        currentDataStructure.sigmoidParameter = dataSubstrate.sigmoidParameter(:,integerIndex)*(1-fractionalIndex) ...
            +dataSubstrate.sigmoidParameter(:,min(integerIndex+1,maxFrameIndex))*fractionalIndex;
        currentDataStructure.sourceOption = dataSubstrate.sourceOption(:,integerIndex)*(1-fractionalIndex) ...
            +dataSubstrate.sourceOption(:,min(integerIndex+1,maxFrameIndex))*fractionalIndex;
        currentDataStructure = sigmoidModeSourceShaper(commandString,dataSubstrate,currentDataStructure);
        currentDataStructure.eventCount = min(length(currentDataStructure.eventLocations),ii+1);
end;
return;