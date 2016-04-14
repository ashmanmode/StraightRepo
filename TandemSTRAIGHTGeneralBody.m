function tSTRAIGHTresults  = TandemSTRAIGHTGeneralBody(x,fs,f0,tc,fl,optionalParameters)
%   tSTRAIGHTresults = TandemSTRAIGHTGeneralBody(x,fs,f0,tc,fl,optionalParameters)
%   TANDEM-STRAIGHT using Blackman window
%   (FFT size is variable based F0 information)
%   Input
%       x   : data (1-channel vertical vector)
%       fs  : sampling frequency (Hz)
%       f0  : fundamental frequency (Hz) scalar
%       tc  : analysis position (s, second! not ms) center of windows
%       fl  : acceptable lowest F0 (Hz)
%       optionalParameters  : optional parameters
%   Output
%       tSTRAIGHTresults   : results in structure
%
%   Note:
%   This routine has only one adjustable parameter q1. The default value
%   suitable for using with current STRAIGHT synthesis engine is 0.375.
%   The default value suitable for using with sinusoidal model is 0.0897.
%   Please refer to our IEICEJ Technical report published in 17, July
%   2007 for details.
%
%   Reference:
%   A temporal and frequency interference-free power spectral
%   representation of periodic signals, by Hideki Kawahara, Masanori
%   Morise, Toru Takahasni, Ryuichi Nisimura, Toshio Irino and Hideki
%   Banno. (in Japanese)
%
%   Warning:
%   This is beta version. There can be bugs.

%   Designed and coded by Hideki Kawahara
%   Copyright(c) 2007, Hideki Kawahara
%   21/July/2007
%   23/July/2007 API modification fftl --> fl
%   24/July/2007 minor bug fix
%   24/July/2007 DC estimation used in the old STRAIGHT is replicated
%   24/July/2007 bug fix in power normalization
%   24/July/2007 DC substitution is refined
%   25/July/2007 bug fix in shaper and filler design
%   27/July/2007 variable output size
%   29/July/2007 Blackman window version
%   10/Sept./2007 Modification for aperiodicity extraction
%   24/Sept./2007 Bug fix
%   19/Oct./2007 Specialized version for F0 extraction
%   22/Oct./2007 bug fix
%   01/Nov./2007 direct FFT length control
%   03/Nov./2007 separate TANDEM to STRAIGHT conversion
%   15/Nov./2007 default DC removal
%   16/Nov./2007 renamed

%---- set default values
q1 = 0;
correctionForBlackman = 2.5; % 18/Oct./2009
DCcorrection = 1;
DCremoval = 1;
exponentControl = 0.3; % 15/Oct./2009
cepstralSmoothing = 1; % 17/May/2011

if nargin < 6
    optionalParameters.q1 = 0;
    optionalParameters.correctionForBlackman = correctionForBlackman;
    optionalParameters.DCcorrection = DCcorrection;
    optionalParameters.DCremoval = DCremoval;
    optionalParameters.exponentControl = exponentControl;
    optionalParameters.cepstralSmoothing = cepstralSmoothing;
end;
tSTRAIGHTresults.optionalParameters = optionalParameters;
if nargin == 0
    return;
end;
%---- Replace optional parameters if exists
%

if nargin == 6
    if isfield(optionalParameters,'q1')
        q1 = optionalParameters.q1;
    end;
    if isfield(optionalParameters,'correctionForBlackman')
        correctionForBlackman = optionalParameters.correctionForBlackman;
    end;
    if isfield(optionalParameters,'DCcorrection')
        DCcorrection = optionalParameters.DCcorrection; % bug found 27/Oct./2009
    end;
    if isfield(optionalParameters,'exponentControl')
        exponentControl = optionalParameters.exponentControl;
    end;
    if isfield(optionalParameters,'DCremoval')
        DCremoval = optionalParameters.DCremoval;
    end;
    if isfield(optionalParameters,'cepstralSmoothing')
        cepstralSmoothing = optionalParameters.cepstralSmoothing;
    end;
end;
if f0<fl;f0=fl;end; % safe guard
t0 = 1/f0;
%fftl = 2^ceil(log2(correctionForBlackman*fs/fl+1)+1);
fftl = 2^ceil(log2(correctionForBlackman*fs/fl+1));
fftlDefault = fftl;
if isfield(optionalParameters,'FFTsize')
    fftl = optionalParameters.FFTsize;
end;

analysisConditions.FFTsize = fftl;
analysisConditions.defaultFFTsize = fftlDefault;
analysisConditions.compensationCoefficient = q1;
analysisConditions.correctionForBlackman = correctionForBlackman;
analysisConditions.lowerF0Limit = fl;
analysisConditions.analysisPosition = tc;
analysisConditions.assumedF0 = f0;
analysisConditions.DCcorrection = DCcorrection;
analysisConditions.DCremoval = DCremoval;
analysisConditions.exponentControl = exponentControl;
analysisConditions.cepstralSmoothing = cepstralSmoothing;

analysisConditions.samplingFrequency = fs;

tSTRAIGHTresults.analysisConditions = analysisConditions;

%%  prepare internal variables

fragmentIndex = 0:round(correctionForBlackman*fs/f0/2); % 18/Oct./2009
nFragment = length(fragmentIndex);
baseIndex = [-fragmentIndex(nFragment:-1:2),fragmentIndex]';
%fprintf('%f\n',length(baseIndex)/(fs/f0));
preIndex = (tc-t0/4)*fs+1+baseIndex;
postIndex = (tc+t0/4)*fs+1+baseIndex;
iPreIndex = min(length(x),max(1,round(preIndex)));
iPostIndex = min(length(x),max(1,round(postIndex)));

%%  wave segments and set of windows preparation
%
preSegment = x(iPreIndex);
postSegment = x(iPostIndex);
preTime = baseIndex/fs/(correctionForBlackman/2)+ ...
    ((tc-t0/4)*fs -round((tc-t0/4)*fs))/fs;
postTime = baseIndex/fs/(correctionForBlackman/2)+ ...
    ((tc+t0/4)*fs-round((tc+t0/4)*fs))/fs;
preWindow = 0.5*cos(pi*preTime*f0)+0.42+0.08*cos(2*pi*preTime*f0);
postWindow = 0.5*cos(pi*postTime*f0)+0.42+0.08*cos(2*pi*postTime*f0);
preWindow = preWindow/sqrt(sum(preWindow.^2));
postWindow = postWindow/sqrt(sum(postWindow.^2));

%%  TANDEM window based power spectrum calculation
%
if DCremoval == 1
%    fftBuffer = zeros(fftl,1);
%    preSignal = fftBuffer;
%    postSignal = fftBuffer;
    %preSignal(1:length(preSegment)) = ...
    preSignal = ...
        preSegment.*preWindow-mean(preSegment.*preWindow)*preWindow/mean(preWindow);
    %postSignal(1:length(preSegment)) = ...
    postSignal = ...
        postSegment.*postWindow-mean(postSegment.*postWindow)*postWindow/mean(postWindow);
    powerSpectrum1 = ...
        abs(fft(preSignal,fftl)).^2;
    powerSpectrum2 = ...
        abs(fft(postSignal,fftl)).^2;
else
    powerSpectrum1 = abs(fft(preSegment.*preWindow,fftl)).^2;
    powerSpectrum2 = abs(fft(postSegment.*postWindow,fftl)).^2;
end;
tandemSpectrum = powerSpectrum1 + powerSpectrum2;

tSTRAIGHTresults.originalTANDEMspectrum = tandemSpectrum;
%%  convert TANDEM to STRAIGHT

structureSTRAIGHT = tandem2STRAIGHT(tSTRAIGHTresults);
tSTRAIGHTresults.sliceSTRAIGHT = structureSTRAIGHT.sliceSTRAIGHT;
tSTRAIGHTresults.sliceTANDEM = structureSTRAIGHT.sliceTANDEM;

