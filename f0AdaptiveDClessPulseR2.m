function outputArgument = f0AdaptiveDClessPulseR2(commandString,currentDataStructure)
%   outBuffer = f0AdaptiveDClessPulse(buffer,fs,f0)

%   F0 adaptive pulse with DC removal using hanning shape
%   Designed and coded by Hideki Kawahara
%   24/Feb./2012
%   04/Mar./2012
%   25/Mar./2012 generalized 
%   17/Oct./2013 safe guard

switch commandString
    case 'initialize'
        currentDataStructure.outBuffer = zeros(currentDataStructure.fftLength,1);
        outputArgument = currentDataStructure;
    case 'fetch'
        outputArgument = currentDataStructure.outBuffer;
        fftl = currentDataStructure.fftLength;
        halfBaseLength = round(currentDataStructure.samplingFrequency/currentDataStructure.f0);
        if fftl/2 <= halfBaseLength % 17/Oct./2013 H.K.
            halfBaseLength = fftl/2-1;
            disp(['warning! Too low f0:' num2str(currentDataStructure.f0) ' (Hz)']);
        end;
        w = hanning(2*halfBaseLength+1);
        w = w/sum(w);
        outputArgument((-halfBaseLength:halfBaseLength)+fftl/2+1) = -w;
        outputArgument(fftl/2+1) = outputArgument(fftl/2+1)+1;
        outputArgument = fft(outputArgument)*sqrt(currentDataStructure.samplingFrequency/currentDataStructure.f0);
end;
return;