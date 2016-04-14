function xClean = inductionAndLowFrequencyNoizeSuppression(x,fs)
%   xClean = inductionAndLowFrequencyNoizeSuppression(x,fs)

%   designedn and coded by Hideki Kawahara
%   22/April/2013 at Jena

xClean = x;
boundaryFrequency = 70; % in Hz, definition of low frequency region
decisionMargin = 10; % in dB
fftl = 2^ceil(log2(length(x))+1);
fx = (0:fftl-1)'/fftl*fs;
powerSpectrum = abs(fft(x,fftl)).^2;
originalLowFrequencyNoiseLevel = ...
    sqrt(sum(powerSpectrum(fx<boundaryFrequency))/sum(fx<boundaryFrequency));
inductionThreshold = 20*log10(originalLowFrequencyNoiseLevel)+decisionMargin;
lowerFragmentOfPower = powerSpectrum(fx<boundaryFrequency);
if sum(lowerFragmentOfPower>10.0^(inductionThreshold/10))
    xClean = notchFilteringOfInduction(x,fs,fx(fx<boundaryFrequency),...
        lowerFragmentOfPower,inductionThreshold);
end;
return;

function xClean = notchFilteringOfInduction(x,fs,fx,lowerFragmentOfPower,inductionThreshold)
notchFilterLengthInSecond = 0.4; % length is 200ms
notchFilterHalfLength = round(notchFilterLengthInSecond*fs/2); % filter length is long to make notch sharp
tx = (-notchFilterHalfLength:notchFilterHalfLength)'/fs;
selctor = lowerFragmentOfPower>10.0^(inductionThreshold/10);
inductionFrequency = sum(fx(selctor).*lowerFragmentOfPower(selctor))/ ...
    sum(lowerFragmentOfPower(selctor));
w = (1+cos(2*pi*tx/notchFilterLengthInSecond)).*cos(2*pi*inductionFrequency*tx);
w = w/sum((1+cos(2*pi*tx/notchFilterLengthInSecond)));
w = -w;
w(tx == 0) = w(tx == 0)+0.5;
w = w*2;
xClean = fftfilt(w,[x;zeros(length(w),1)]);
xClean = xClean(notchFilterHalfLength+(1:length(x)));
return;