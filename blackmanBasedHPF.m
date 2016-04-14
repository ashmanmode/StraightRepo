function xClean = blackmanBasedHPF(x,fs,cornerFrequency,nConvolution)
txx = (-round(fs/cornerFrequency):round(fs/cornerFrequency))'/fs;
ww = blackman(length(txx));
wl = -ww;
wl = wl/sum(ww);
wl(txx == 0) = wl(txx == 0)+1;
wll = wl;
for ii = 1:nConvolution-1
    wll = conv(wl,wll);
end;
halfLength = round(length(wll-1)/2);
xClean = fftfilt(wll,[x;zeros(length(wll),1)]);
xClean = xClean(halfLength+(1:length(x)));
return;