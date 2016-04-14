clear all;
close all;
clc;

%Trained Model path
modelPath = '/home/ashish/Straight/TandemSTRAIGHTmonolithicPackage010/Models/';
%Input feature file path
INDIR = '/home/ashish/Documents/HTS-demo_CMU-ARCTIC-SLT/data/inpFeatsASH/';
%wavfile path
WAVDIR = '/home/ashish/Documents/HTS-demo_CMU-ARCTIC-SLT/data/wavASH16/';

%Loading the DnnTts Model
load(strcat(modelPath,'ttsModelF5.mat'));

%load the input features
file = 'cmu_us_arctic_slt_a0001';
fileName = strcat(file,'.feat');
inputs = importdata(strcat(INDIR,fileName)); 

%Use the model to get the outputs
outputs = net(inputs')';
output = outputs(:,1:40);
f0_target = outputs(:,41);

fs=16000;
[originFeats,weightMatrix,q,f]=mfcc_straight(strcat(WAVDIR,strcat(file,'.wav')));

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