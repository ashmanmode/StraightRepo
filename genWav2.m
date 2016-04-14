clear;clc;
addpath('/home/ashish/Documents/MATLAB/audioread/');
file = '/home/ashish/Documents/HTS-demo_CMU-ARCTIC-SLT/data/wavASH/cmu_us_arctic_slt_a0001.wav';
%listofsltfiles=importdata('sltlist.text');
[testfeature,weightMatrix,q,f]=mfcc_straightM(file);

fs=48000;
nCoefficients = size(weightMatrix,1);
cosTable=dctmtx(nCoefficients)';
n3sgram=(pinv(weightMatrix)*(sqrt(exp(cosTable\testfeature')))).^2;
f.spectrogramSTRAIGHT=n3sgram;
sgramSTRAIGHT = 10*log10(n3sgram);
maxLevel = max(max(sgramSTRAIGHT));
figure;
imagesc([0 f.temporalPositions(end)],[0 fs/2],max(maxLevel-80,sgramSTRAIGHT));
axis('xy')
set(gca,'fontsize',14);
xlabel('time (s)');
ylabel('frequency (Hz)');
title('Reconstructed STRAIGHT spectrogram');
s2 = exGeneralSTRAIGHTsynthesisR2(q,f);
sound(s2.synthesisOut,fs);
wavwrite(s2.synthesisOut,fs,'generated_straightASH.wav');