function cleanedSignal = removeLF(x,fs,f0,periodicityLevel)

periodicityThreshold = 0.7;
lengthLimit = 10;
defaultMedianF0 = 100;
if length(f0(periodicityLevel>periodicityThreshold)) > lengthLimit
    medianF0 = median(f0(periodicityLevel>periodicityThreshold));
else
    medianF0 = defaultMedianF0;
end;
t0InSamples = round(fs/(medianF0*0.7));
w = hanning(2*t0InSamples+1);
w = -w/sum(w);
w(t0InSamples+1) = w(t0InSamples+1)+1;
cleanedSignal = fftfilt(w,[x;zeros(2*t0InSamples,1)]);
cleanedSignal = cleanedSignal(t0InSamples+(1:length(x)));
return;
