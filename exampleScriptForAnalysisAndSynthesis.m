%%  Test script for basic TANDEM-STRAIGHT analysis and synthesis
%   by Hideki Kawahara
%   20/April/2012
%   06/Oct./2015 R2015b compatibility fix

%   Please use this in "cell mode"

%%  Initialize conditions

% directoryBase = [pwd '/'];
fileName = '/home/ashish/HTS-demo_CMU-ARCTIC-SLT/data/wav/cmu_us_arctic_slt_a0001.wav';
% fileName = 'atr503_mht_sd_a13.wav';

noisy = 0; % If the speech material consists of low frequency noise, set this vaviable 1;
plotFigures = 1; % If you do not need plots, set this variable 0.

%%  Read speech data from a file

%[x,fs] = wavread([directoryBase fileName]);
[x,fs] = audioread([fileName]);

x = x(:,1); %   Make sure it is a comum vector.
soundsc(x,fs) % Playback sound

%%  Extract source information

r = exF0candidatesTSTRAIGHTGB(x,fs) % Extract F0 information

if noisy
    x = removeLF(x,fs,r.f0,r.periodicityLevel); % Low frequency noise remover
    r = exF0candidatesTSTRAIGHTGB(x,fs)
end;

rc = autoF0Tracking(r,x); % Clean F0 trajectory by tracking
rc.vuv = refineVoicingDecision(x,rc);

if plotFigures
    figure;
    plot(rc.temporalPositions,rc.f0);grid on
    set(gca,'fontsize',14);
    xlabel('time (s)')
    ylabel('fundamental frequency (Hz)');
    title('fundamental frequency')
end;
%%

q = aperiodicityRatioSigmoid(x,rc,1,2,0) % aperiodicity extraction

if plotFigures;
    displayAperiodicityStructure(q,1);
end;

%%  Extract spectral informatiopn

f = exSpectrumTSTRAIGHTGB(x,fs,q)

STRAIGHTobject.waveform = x;
STRAIGHTobject.samplingFrequency = fs;
STRAIGHTobject.refinedF0Structure.temporalPositions = r.temporalPositions;
STRAIGHTobject.SpectrumStructure.spectrogramSTRAIGHT = f.spectrogramSTRAIGHT;
STRAIGHTobject.refinedF0Structure.vuv = rc.vuv;
f.spectrogramSTRAIGHT = unvoicedProcessing(STRAIGHTobject);

sgramSTRAIGHT = 10*log10(f.spectrogramSTRAIGHT);
maxLevel = max(max(sgramSTRAIGHT));
figure;
imagesc([0 f.temporalPositions(end)],[0 fs/2],max(maxLevel-80,sgramSTRAIGHT));
axis('xy')
set(gca,'fontsize',14);
xlabel('time (s)')
ylabel('frequency (Hz)');
title('STRAIGHT spectrogram')

%%

s = exTandemSTRAIGHTsynthNx(q,f)
sound(s.synthesisOut/max(abs(s.synthesisOut))*0.8,fs) % old implementation

s2 = exGeneralSTRAIGHTsynthesisR2(q,f) % new implementation
sound(s2.synthesisOut/max(abs(s2.synthesisOut))*0.8,fs)
