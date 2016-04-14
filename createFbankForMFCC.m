function fbankObject = createFbankForMFCC(lowerFrequency,higherFrequency,nChannel,SamplingFrequency,frequencyAxis);

frequencyAxis = frequencyAxis(:)';
%   Yong's implementation is followed
melLowBound = frequencyToYongMel(lowerFrequency);
melHighBound = frequencyToYongMel(higherFrequency);
melStep = (melHighBound-melLowBound)/(nChannel+1);

melLandmarks = melLowBound+(0:nChannel+1)*melStep;
lowMels = melLandmarks(1:end-2);
centerMels = melLandmarks(2:end-1);
highMels = melLandmarks(3:end);

lowFrequency = YongMelToFrequency(lowMels);
centerFrequency = YongMelToFrequency(centerMels);
highFrequency = YongMelToFrequency(highMels);

temporalyWeightMatrix = ones(nChannel,1)*frequencyAxis;
for ii = 1:nChannel
    temporaly1 = ((frequencyAxis-lowFrequency(ii)).*(frequencyAxis>lowFrequency(ii)))/(centerFrequency(ii)-lowFrequency(ii));
    temporaly2 = ((highFrequency(ii)-frequencyAxis).*(frequencyAxis<highFrequency(ii)))/(highFrequency(ii)-centerFrequency(ii));
    temporalyWeightMatrix(ii,:) = max(0,temporaly1.*(temporaly1<temporaly2)+temporaly2.*(temporaly1>=temporaly2));
end;
fbankObject.weightMatrix = temporalyWeightMatrix;
fbankObject.centerFrequency = centerFrequency;

function melFrequency = frequencyToYongMel(linearFrequency)

melFrequency = 2595*log10(1+linearFrequency/700);
return;

function linearFrequency = YongMelToFrequency(melFrequency);

linearFrequency = 700*(10.0.^(melFrequency/2595)-1);
return;