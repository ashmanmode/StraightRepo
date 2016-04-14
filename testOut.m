clear all;
close all;
clc;

% Load the model
load('ttsModelv1.mat');

%load the input features
INDIR = '/home/ashish/Documents/HTS-demo_CMU-ARCTIC-SLT/data/inpFeatsASH/';
Files = dir(INDIR);
fileName = Files(3).name; 
inputs = importdata(strcat(INDIR,fileName)); 

outputs = net(inputs')';

output = outputs(:,1:40);
f0_target = outputs(:,41);

fs=16000;
[testfeature,weightMatrix,q,f]=mfcc_straight('/home/ashish/Documents/HTS-demo_CMU-ARCTIC-SLT/data/wavASH16/cmu_us_arctic_slt_a0001.wav');
%load('weightMatrixQF.mat');

% Using the output 
q.f0 = f0_target;
nCoefficients = size(weightMatrix,1);
cosTable=dctmtx(nCoefficients)';
n3sgram=(pinv(weightMatrix)*(sqrt(exp(cosTable\output')))).^2;
f.spectrogramSTRAIGHT=n3sgram;

sgramSTRAIGHT = 10*log10(n3sgram);
maxLevel = max(max(sgramSTRAIGHT));
figure;
imagesc([0 f.temporalPositions(end)],[0 fs/2],max(maxLevel-80,sgramSTRAIGHT));
axis('xy')
set(gca,'fontsize',14);
xlabel('time (s)')
ylabel('frequency (Hz)');
title('Reconstructed STRAIGHT spectrogram');
s2 = exGeneralSTRAIGHTsynthesisR2(q,f);
sound(s2.synthesisOut,fs);
%audiowrite('moni_1_straight.wav',s2.synthesisOut,fs);
wavwrite(s2.synthesisOut,fs,'generated_straightASH.wav');