function apDisplayStructure = displayAperiodicityStructure(apStructure,displayOn)
%   okInd = displayAperiodicityStructure(apStructure)
%   Supporting function to display aperiodicity information

%   Designed and coded by Hideki Kawahara
%   18/Oct./2008

switch nargin
    case 1
        displayOnInternal = 0;
    otherwise
        displayOnInternal = displayOn;
end;

fs = apStructure.samplingFrequency;
f0 = apStructure.f0;
f0Safe = max(apStructure.targetF0,f0);
locations = apStructure.temporalPositions;
fftl = 1024;
frequencyAxis = (0:fftl-1)'/fftl*fs;
displayFrequencyAxis = frequencyAxis(frequencyAxis<=fs/2);
nFrames = length(apStructure.f0);
stretchingFactor = f0Safe/apStructure.targetF0;
staticBoundaryList = [0;apStructure.cutOffListOriginal;fs/2];
fixedBoundaryList = [0;apStructure.cutOffListFix;fs/2];

randomComponent = ones(length(displayFrequencyAxis),nFrames);
for ii = 1:nFrames
    if f0(ii) > 0
        randomLevels = apStructure.residualMatrixOriginal(:,ii);
        originalPart = ...
            exp(interp1(staticBoundaryList,log([0.0000000005;randomLevels(:)]),displayFrequencyAxis,'linear','extrap'));
        randomLevels = apStructure.residualMatrixFix(:,ii);
        fixedPart = ...
            exp(interp1(fixedBoundaryList*stretchingFactor(ii),...
            log([0.00000000005;randomLevels(:)]),displayFrequencyAxis,'linear','extrap'));
        randomComponent(:,ii) = min([fixedPart, originalPart]')';
    else
        % do nothing
    end;
end;
if displayOnInternal
    figure;
    %imagesc([locations(1) locations(end)],...
    %    [displayFrequencyAxis(1) displayFrequencyAxis(end)],max(-30,20*log10(randomComponent)));
    imagesc([locations(1) locations(end)],...
        [displayFrequencyAxis(1) displayFrequencyAxis(end)],randomComponent);
    axis('xy');colorbar
    set(gca,'fontsize',14);
    xlabel('time (s)')
    ylabel('frequency (Hz)');
    title('aperiodicity spectrogram');
end;
apDisplayStructure.frequencyAxis = displayFrequencyAxis;
apDisplayStructure.randomComponent = randomComponent;

