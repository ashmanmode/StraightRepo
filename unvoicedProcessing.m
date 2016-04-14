function processedSpectrum = unvoicedProcessing(STRAIGHTobject)

%   added safe guard: 22/March/2013

averagingWidth = 0.025;
x = STRAIGHTobject.waveform;
fs = STRAIGHTobject.samplingFrequency;
locations = STRAIGHTobject.refinedF0Structure.temporalPositions;
originalSpectrum = STRAIGHTobject.SpectrumStructure.spectrogramSTRAIGHT;
vuv = STRAIGHTobject.refinedF0Structure.vuv;
deltaT = locations(2);
nFrames = ceil(averagingWidth/deltaT);
nFrames = 2*max(1,round(nFrames/2))+1;
halfLength = (nFrames-1)/2;
w = ones(nFrames,1);

processedSpectrum = originalSpectrum;
framePower = sum(processedSpectrum);
averagedPower = mean(framePower(~isnan(framePower)));
processedSpectrum(:,averagedPower/10000000>framePower) = averagedPower/10000000*1.1; % safe guard
processedSpectrum(:,isnan(framePower)) = averagedPower/10000000*1.1; % safe guard
originalSpectrum(:,averagedPower/10000000>framePower) = averagedPower/10000000*1.1; % safe guard
originalSpectrum(:,isnan(framePower)) = averagedPower/10000000*1.1; % safe guard
framePower(isnan(framePower)) = averagedPower/10000000*1.1; % safe guard
for ii = 1:length(locations)
    processedSpectrum(:,ii) = processedSpectrum(:,ii)*(1-vuv(ii));
end;
processedSpectrum = [processedSpectrum zeros(size(processedSpectrum,1),nFrames)];
processedSpectrum = abs(fftfilt(w,processedSpectrum'))';
processedSpectrum = processedSpectrum(:,halfLength+(1:length(locations)));

%targetLevel = sum(originalSpectrum);
targetLevel = framePower; % safe guard
initialLevel = sum(processedSpectrum);

for ii = 1:length(locations)
    if (vuv(ii) == 0) && (initialLevel(ii) >0)
        processedSpectrum(:,ii) = processedSpectrum(:,ii)/initialLevel(ii)*targetLevel(ii);
    else
        processedSpectrum(:,ii) = originalSpectrum(:,ii);
    end;
end;
return;

