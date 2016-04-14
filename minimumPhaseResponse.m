function responseInFreqDomain = minimumPhaseResponse(specSlice)
%   responseInFreqDomain = minimumPhaseResponse(specSlice)

%   minimum phase resoponse through complex cepstrum
%   codec by Hideki Kawahara
%   24/Feb./2012
%   04/Mar./2012 revised to generalize

%responseInFreqDomain = [];
fftl = 2*(size(specSlice,1)-1);
doubleSpectrum = [specSlice;specSlice(end-1:-1:2)];
complexCepstrum = ifft(log(doubleSpectrum)/2);
complexCepstrum(fftl/2+1:end) = 0;
complexCepstrum(2:fftl/2) = complexCepstrum(2:fftl/2)*2;
responseInFreqDomain = exp(fft(complexCepstrum));
return;