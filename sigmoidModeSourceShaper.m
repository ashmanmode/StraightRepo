function currentDataStructure = sigmoidModeSourceShaper(commandString,dataSubstrate,currentDataStructure)
%   currentDataStructure = sigmoidModeSourceShaper(commandString,dataSubstrate,currentDataStructure)

%   Output excitation source spectral shape for aperiodic component
%   Designed and coded by Hideki Kawahara
%   25/Feb./2012

fftl = currentDataStructure.fftLength;
fs = dataSubstrate.samplingFrequency;
switch commandString
    case 'initialize'
        currentDataStructure.frequencyAxis = (0:fftl/2)'/fftl*fs;
        currentDataStructure.frequencyAxis(1) = ...
            currentDataStructure.frequencyAxis(2)*0.5;
    case 'fetch'
        frequencyAxis = currentDataStructure.frequencyAxis;
        alpha = max(0.001,currentDataStructure.sigmoidParameter(1)/log(2));
        fc = max(50,2.0.^(-currentDataStructure.sigmoidParameter(2,:)./ ...
            currentDataStructure.sigmoidParameter(1,:)));
        fcLow = dataSubstrate.cutOffListFix(1);
        f0 = currentDataStructure.f0;
        targetF0 = dataSubstrate.targetF0;
        newFrequencyAxis = frequencyAxis.*(1.0./(1+exp(-2.2/(fcLow*f0/targetF0*0.2)*(frequencyAxis-fcLow*f0/targetF0))));
        tmp = (newFrequencyAxis/fc).^alpha;
        currentDataStructure.randomComponent = 0.999*(tmp./(1+tmp)).^dataSubstrate.exponent+0.001;
end;
return;