function outputArgument = noiseBurstInFrequencyR2(commandString,currentDataStructure,randomHandleOption)
%   outBuffer = noiseBurstInFrequency(buffer,fs,f0,stretch)

%   F0 adaptive noise burst shaper-type1
%   noise is located on top of the excitation pulse
%   Designed and coded by Hideki Kawahara
%   24/Feb./2012
%   04/Mar./2012
%   26/Mar./2012 generalized
%   17/Oct./2013 safe guard

switch commandString
    case 'initialize'
        currentDataStructure.buffer = zeros(currentDataStructure.fftLength,1);
        fs = currentDataStructure.samplingFrequency;
        if nargin > 2
            if isfield(randomHandleOption,'stretch')
                currentDataStructure.stretch = randomHandleOption.stretch;
            else
                currentDataStructure.stretch = 1;
            end;
        else
            currentDataStructure.stretch = 1;
        end;
        currentDataStructure.noiseBuffer = randn(round(1.1*currentDataStructure.temporalPositions(end)*fs),1);
        outputArgument = currentDataStructure;
    case 'fetch'
        fftl = currentDataStructure.fftLength;
        currentTime = currentDataStructure.eventLocations(currentDataStructure.eventCount);
        halfLength = round(currentDataStructure.samplingFrequency/currentDataStructure.f0*currentDataStructure.stretch);
        if fftl/2 <= halfLength  % 17/Oct./2013 H.K.
            halfLength = fftl/2-1;
            disp(['warning! Too low f0:' num2str(currentDataStructure.f0) ' (Hz)']);
        end;
        w = hanning(halfLength*2+1).*currentDataStructure.noiseBuffer(...
            max(1,(-halfLength:halfLength)+round(currentTime*currentDataStructure.samplingFrequency)));
        outputArgument = currentDataStructure.buffer;
        outputArgument(fftl/2+1+(-halfLength:halfLength)) = w/sqrt(currentDataStructure.stretch);
        outputArgument = fft(outputArgument);
end;
return;