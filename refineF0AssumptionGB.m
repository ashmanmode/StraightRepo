function estimatedF0 = refineF0AssumptionGB(x,fs,tc,f0,nh)
%   F0 refinement using instantaneous frequency
%   revidedF0 = refineF0AssumptionGB(x,fs,tc,f0,nh)
%   Input arguments
%       x   : input signal
%       fs  : sampling frequency (Hz)
%       tc  : analysis location (second)
%       f0  : intial estimate of F0 (Hz)
%       nh  : number of harmonics

%   Designed and coded by Hideki Kawahara
%   14/Oct./2007
%   20/Oct./2007 revised for margin
%   15/March/2008 revised search range

%% Initialization of parameters
%
marginLimit = 0.995; % revised on 15/March/2008.

revidedF01 = baseF0withIF(x,fs,tc,f0/marginLimit,nh);
revidedF02 = baseF0withIF(x,fs,tc,f0*marginLimit,nh);
a = inv([f0/marginLimit 1;f0*marginLimit 1])*[revidedF01.averageF0;revidedF02.averageF0];
estimatedF0 = a(2)/(1-a(1));