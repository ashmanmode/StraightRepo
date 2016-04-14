function revisedF0 = baseF0withIF(x,fs,tc,f0,nh)
%   F0 refinement using instantaneous frequency base function
%   revidedF0 = baseF0withIF(x,fs,tc,f0,nh)
%   Input arguments
%       x   : input signal
%       fs  : sampling frequency (Hz)
%       tc  : analysis location (second)
%       f0  : intial estimate of F0 (Hz)
%       nh  : number of harmonics

%   Designed and coded by Hideki Kawahara
%   14/Oct./2007
%   15/March/2008 bug fix

%% Initialization of parameters
%

correctionForBlackman = 1.5;
fragmentIndex = 0:round(correctionForBlackman*fs/f0);
nFragment = length(fragmentIndex);
baseIndex = [-fragmentIndex(nFragment:-1:2),fragmentIndex];
xsegment = x(min(length(x),max(1,baseIndex+round(tc*fs)+1)));
baseTime = baseIndex/fs+(tc*fs -round(tc*fs))/fs;
baseTimeB = baseTime/correctionForBlackman;
filterEnvelope = 0.5*cos(pi*baseTimeB*f0)+0.42+0.08*cos(2*pi*baseTimeB*f0);
%quadratureResponse = filterEnvelope.*exp(i*2*pi*f0*baseTime); %bug
F0v = zeros(nh,2);
for ii = 1:nh
    quadratureResponse = filterEnvelope.*exp(i*2*pi*f0*baseTime*ii); %fixed
    s = sum(xsegment.*quadratureResponse');
    s1 = sum(xsegment.*quadratureResponse'.*baseTime');
    F0v(ii,1) = f0*ii+ ...
        (real(s)*imag(s1)-imag(s)*real(s1))/(abs(s)^2)*fs/2/pi; % bug fixed
    F0v(ii,2) = abs(s);
    quadratureResponse = quadratureResponse.*exp(i*2*pi*f0*baseTime);
end;
revisedF0.baseInformation = F0v;
revisedF0.averageF0 = sum(sqrt(F0v(:,2)).*F0v(:,1)./(1:nh)')/sum(sqrt(F0v(:,2)));