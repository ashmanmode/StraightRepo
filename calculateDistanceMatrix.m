function distanceMatrix = calculateDistanceMatrix(mSubstrate,metric)
%MFCC
%Linear
%Shift invariant 1
%MFCCmod
sgramA = mSubstrate.STRAIGHTspectrogramOfSpeakerA;
sgramB = mSubstrate.STRAIGHTspectrogramOfSpeakerB;
fs = mSubstrate.samplintFrequency;
fftl = (size(sgramA,1)-1)*2;
switch metric
    case 'Linear'
        matrixA = 10*log10(sgramA);
        matrixB = 10*log10(sgramB);
    case 'MFCC'
        fAxis = (0:fftl/2)/fftl*fs;
        fbankObject = createFbankForMFCC(100,fAxis(end),20,fs,fAxis);
        [matrixA,filterOut] = ...
            specToYongMFCC2(fbankObject.weightMatrix,sqrt(sgramA),fs);
        [matrixB,filterOut] = ...
            specToYongMFCC2(fbankObject.weightMatrix,sqrt(sgramB),fs);
    case 'Shift invariant 1'
        fAxis = (0:fftl/2)/fftl*fs;
        fbankObject = createFbankForMFCC(100,fAxis(end),20,fs,fAxis);
        filterOutA = fbankObject.weightMatrix*sgramA;
        filterOutB = fbankObject.weightMatrix*sgramB;
        matrixA = abs(fft((log(filterOutA)),128));
        matrixB = abs(fft((log(filterOutB)),128));
        %normalizationFactor = (1.0./sqrt((1:64)+3));
        %matrixA = normalizationFactor*matrixA(1:64,:);
        %matrixB = normalizationFactor*matrixB(1:64,:);
        matrixA = matrixA(1:40,:);
        matrixB = matrixB(1:40,:);
    case 'MFCCmod'
        fAxis = (0:fftl/2)/fftl*fs;
        fbankObject = createFbankForMFCC(100,fAxis(end),20,fs,fAxis);
        [matrixAorg,filterOut] = ...
            specToYongMFCC2(fbankObject.weightMatrix,sqrt(sgramA),fs);
        [matrixBorg,filterOut] = ...
            specToYongMFCC2(fbankObject.weightMatrix,sqrt(sgramB),fs);
        mfccWeight = diag([0.2; 0.5; 0.8; ones(size(matrixAorg,1)-3,1)]);
        matrixA = mfccWeight*matrixAorg;
        matrixB = mfccWeight*matrixBorg;
    otherwise % default is MFCC (best at least by now)
        fAxis = (0:fftl/2)/fftl*fs;
        fbankObject = createFbankForMFCC(100,fAxis(end),20,fs,fAxis);
        [matrixA,filterOut] = ...
            specToYongMFCC2(fbankObject.weightMatrix,sqrt(sgramA),fs);
        [matrixB,filterOut] = ...
            specToYongMFCC2(fbankObject.weightMatrix,sqrt(sgramB),fs);
end;
nFrameOfA = size(matrixA,2);
nFrameOfB = size(matrixB,2);
distanceMatrix = zeros(nFrameOfA,nFrameOfB);
for ii = 1:nFrameOfA
    for jj = 1:nFrameOfB
        tmp = std(matrixA(:,ii)-matrixB(:,jj));
        distanceMatrix(ii,jj) = tmp;
    end;
end;
distanceMatrix = log(distanceMatrix/max(max(distanceMatrix)));
return;