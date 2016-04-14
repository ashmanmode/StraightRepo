function aperiodicityStructure = aperiodicityDisplayFast(sourceStructure,fftl)
%   Calculate spectrographic representation of aperiodicity
%   08/Jan./2010
aperiodicityStructure = sourceStructure;
fs = sourceStructure.samplingFrequency;
%vuv = sourceStructure.vuv;
%f0 = sourceStructure.f0;
locations = sourceStructure.temporalPositions;
nFrames = length(locations);
frequencyAxis = (0:fftl/2)'/fftl*fs;
frequencyAxis(1) = frequencyAxis(2)*0.5;
sigmoidParameter = sourceStructure.sigmoidParameter;
exponent = sourceStructure.exponent;
aperiodicityRange = sourceStructure.aperiodicityRange;
aperiodicitySgram = zeros(fftl/2+1,nFrames);
alpha = max(0.001,sigmoidParameter(1,:)/log(2));
fc = max(50,2.0.^(-sigmoidParameter(2,:)./sigmoidParameter(1,:)));
dynamicRange = diff(aperiodicityRange);
for ii = 1:nFrames
    tmp = (frequencyAxis/fc(ii)).^alpha(ii);
    pHat = (tmp./(1+tmp))*dynamicRange(ii)+aperiodicityRange(1,ii);
    aperiodicitySgram(:,ii) = pHat;
end;
aperiodicityStructure.randomComponent = aperiodicitySgram.^exponent;
return;