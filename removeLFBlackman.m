function cleanedSignal = removeLFBlackman(x,fs,f0,periodicityLevel)

periodicityThreshold = 0.7;
lengthLimit = 10;
defaultMedianF0 = 100;
if length(f0(periodicityLevel>periodicityThreshold)) > lengthLimit
    medianF0 = median(f0(periodicityLevel>periodicityThreshold));
else
    medianF0 = defaultMedianF0;
end;
cleanedSignal = blackmanBasedHPF(x,fs,medianF0*0.6,1);
return;
