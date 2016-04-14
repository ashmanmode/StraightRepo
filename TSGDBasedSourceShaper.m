function currentDataStructure = TSGDBasedSourceShaper(commandString,dataSubstrate,currentDataStructure)
%   currentDataStructure = TSGDBasedSourceShaper(commandString,dataSubstrate,currentDataStructure)

%   Output excitation source spectral shape for aperiodic component
%   Designed and coded by Hideki Kawahara
%   25/Feb./2012 initially designed based on sigmoid
%   26/Aug./2014 modified for Temporally Static Group Delay-based method

fftl = currentDataStructure.fftLength;
fs = dataSubstrate.samplingFrequency;
switch commandString
    case 'initialize'
        currentDataStructure.frequencyAxis = (0:fftl/2)'/fftl*fs;
        currentDataStructure.frequencyAxis(1) = ...
            currentDataStructure.frequencyAxis(2)*0.5;
        currentDataStructure.logFrequencyAxis = log(currentDataStructure.frequencyAxis);
        currentDataStructure.logCenterFrequencies = log(dataSubstrate.centerFrequencies);
        currentDataStructure.maxFrame = size(dataSubstrate.sourceSNR,2);
    case 'fetch'
        ii = min(currentDataStructure.maxFrame,currentDataStructure.eventCount);
        logFreqMinimum = currentDataStructure.logFrequencyAxis(1);
        aperiodicityInDB = interp1([logFreqMinimum;currentDataStructure.logCenterFrequencies;...
            currentDataStructure.logCenterFrequencies(end)+1],...
            [-50;dataSubstrate.sourceSNR(:,ii);dataSubstrate.sourceSNR(end,ii)],...
            currentDataStructure.logFrequencyAxis,'linear','extrap');
        currentDataStructure.randomComponent = 10.0.^(aperiodicityInDB(:)/10);
end;
return;