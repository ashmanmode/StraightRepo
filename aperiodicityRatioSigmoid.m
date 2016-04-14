function apStructure = aperiodicityRatioSigmoid(x,sourceStruture,sideMargin,exponent,displayOn)
%   apStructure = aperiodicityRatioSigmoid(x,sourceStruture,sideMargin,exponent,displayOn)
%   Aperiodicity extraction using dual clue

%   Designed and coded by Hideki Kawahara
%   17/Oct./2008
%   05/Jan./2010 Logit model
%   07/Jan./2010 evaluation part is added
%   11/Jan./2010 boudary condition is revised
%   15/Dec./2012 bug (fragility) fix
%   22/March/2013 bug (fragility) fix
%   24/April/2013 bug (fragility) fix
%   21/Nov./2013 HK safeguard for lower sampling frequency

%---- initialize parameters -------
pc = exponent;
apStructure = sourceStruture;
tic;
fs = sourceStruture.samplingFrequency;
if isfield(sourceStruture,'controlParameters')
    f0 = min(sourceStruture.controlParameters.f0ceil,sourceStruture.f0); % 24/April/2013 safe guard
elseif isfield(sourceStruture,'')
    f0 = min(sourceStruture.additionalInformation.controlParameters.f0ceil,sourceStruture.f0); % 24/April/2013 safe guard
else
    f0 = min(800,sourceStruture.f0); % 24/April/2013 safe guard
end;
locations = sourceStruture.temporalPositions;
if isfield(sourceStruture,'vuv') && sum(sourceStruture.vuv) > 0
    targetF0 = min(200,max(32,min(f0(sourceStruture.vuv>0)))); % 32 and 200 Hz are safe guards
else
    targetF0 = min(200,max(32,min(f0(f0>=0)))); % 32 and 200 Hz are safe guards
end;
%   comments by M.M. 27/Oct./2009
%----
tic;
aperiodicityWithOriginalTime = ...
    bandwiseAperiodicity(x,sourceStruture,fs,sideMargin,30);
toc
tic
[stretchedSignal,stretchedLocations] = normalizeSignal(x,fs,f0,locations,targetF0);
toc
fixedSource = sourceStruture;
fixedSource.f0 = fixedSource.f0*0+targetF0;
fixedSource.temporalPositions = stretchedLocations;
tic
aperiodicityWithNormalizedTime = ...
    bandwiseAperiodicity(stretchedSignal(:),fixedSource,fs,sideMargin,round(2000/targetF0));
toc
%---- model fitting body -----
tic
originalCenterFrequencies = [aperiodicityWithOriginalTime.cutOffList;fs/2]/sqrt(2);
nFrames = length(f0);
basebandAperiodicity = sqrt(abs(1-sourceStruture.periodicityLevel));
if displayOn
    figure;
    logFrequencyAxis = 2.0.^(log2(30):1/12:log2(fs/2));
    xi = log2(logFrequencyAxis)';
    logSpectrogram = zeros(length(logFrequencyAxis),nFrames);
end;
aperiodicityRange = zeros(2,nFrames);
sigmoidParameter = zeros(2,nFrames);
evaluation = zeros(nFrames,1);
referenceError = zeros(nFrames,1);
for ii = 1:nFrames
    fixedCenterFrequencies = ...
        [aperiodicityWithNormalizedTime.cutOffList;fs/2]/sqrt(2)/targetF0*f0(ii);
    fixedCenterFrequencies = fixedCenterFrequencies(fixedCenterFrequencies<fs/2);
    %frequencyAxisForAperiodicity = [f0(ii);originalCenterFrequencies;fixedCenterFrequencies];
    if length(fixedCenterFrequencies) > 0 % 21/Nov/2013 HK safeguard
        frequencyAxisForAperiodicity = [originalCenterFrequencies;fixedCenterFrequencies];
    else
        frequencyAxisForAperiodicity = [originalCenterFrequencies;fs/2];
    end;
    originalResidual = aperiodicityWithOriginalTime.residualMatrix(:,ii);
    if length(fixedCenterFrequencies) > 0 % 21/Nov/2013 HK safeguard
        fixedResidual = aperiodicityWithNormalizedTime.residualMatrix(fixedCenterFrequencies<fs/2,ii);
    else
        fixedResidual = originalResidual(1); % safeguard
    end;
    baseApriodicity = min([basebandAperiodicity(ii),originalResidual(1),fixedResidual(1)]);
    %aperiodicityVector = [baseApriodicity/10;originalResidual;fixedResidual].^(1/3);
    originalResidual(1) = baseApriodicity;
    fixedResidual(1) = baseApriodicity;
    aperiodicityVector = [originalResidual;fixedResidual].^(1/pc);
    logDataFreqency = log2(frequencyAxisForAperiodicity);
    tmpAperiodicity = aperiodicityVector;
    for jj = 1:length(aperiodicityVector)
        tmpAperiodicity(jj) = min(aperiodicityVector(abs(logDataFreqency-logDataFreqency(jj))<0.51));
    end;
    aperiodicityVector = tmpAperiodicity;
    %tmpRange = [min(aperiodicityVector)*0.98,max(aperiodicityVector)*1.02];
    %tmpRange = [max(0,min(aperiodicityVector)-0.1^(1/pc)),min(1,max(aperiodicityVector)*1.1)];
    tmpRange = [0 1];
    %tmp = (aperiodicityVector-tmpRange(1))/diff(tmpRange); % 15/Dec./2012 safe guard (before)
    tmp = max(0.0001,min(0.99,(aperiodicityVector-tmpRange(1))/diff(tmpRange))); % 15/Dec./2012 safe guard (fix)
    y = log(tmp./(1-tmp));
    R = tmp.*(1-tmp);
    Hr = [logDataFreqency.*R R];
    a = (Hr'*Hr)\(Hr'*(R.*y));
    for jj = 1:4
        yEst = [logDataFreqency ones(length(y),1)]*a;
        pEst = exp(yEst)./(1+exp(yEst));
        %R = sqrt(pEst.*(1-pEst).*tmp.*(1-tmp));
        R = pEst.*(1-pEst);
        Hr = [logDataFreqency.*R R];
        if condest(Hr'*Hr) < 10^6
            a = (Hr'*Hr)\(Hr'*(R.*y));
        end;
    end;
    %yEst = y; % for test
    if displayOn
        yEst = a(1)*xi+a(2);
        estimatedTmp = ((exp(yEst)./(1+exp(yEst)))*diff(tmpRange)+tmpRange(1)).^pc;
        logSpectrogram(:,ii) = estimatedTmp;
        semilogx(f0(ii),basebandAperiodicity(ii),'ro',...
            originalCenterFrequencies,aperiodicityWithOriginalTime.residualMatrix(:,ii),'o-',...
            fixedCenterFrequencies,aperiodicityWithNormalizedTime.residualMatrix(fixedCenterFrequencies<fs/2,ii),'go-');
        hold on;
        semilogx(frequencyAxisForAperiodicity,aperiodicityVector.^pc,'+','linewidth',2);
        semilogx(logFrequencyAxis,estimatedTmp);
        axis([30 fs/2 0 1]);grid on;
        title(['frame:' num2str(ii) '  at:' num2str(locations(ii)) ' (s)']);
        hold off;
        drawnow
        % if sum(ii==[4 21 105 577 671])>0;figure;end;
        %pause(0.1);
    end;
    aperiodicityRange(:,ii) = tmpRange;
    a(1) = max(0.001,a(1)); % safeguard
    a(2) = min(-0.001,a(2)); % safeguard
    sigmoidParameter(:,ii) = a;
    evaluation(ii) = sum(R.^2.*(y-[logDataFreqency ones(length(y),1)]*a).^2)/sum(R.^2);
    weightedMean = sum(R.^2.*y)/sum(R.^2);
    referenceError(ii) = sum(R.^2.*(y-weightedMean).^2)/sum(R.^2);
end;
if displayOn
    figure;imagesc(logSpectrogram);axis('xy');colorbar
end;
toc
%---- end of fitting -----
apStructure.dateOfExtraction = datestr(now);
apStructure.stretchedSignal = stretchedSignal;
apStructure.residualMatrixOriginal = aperiodicityWithOriginalTime.residualMatrix;
apStructure.cutOffListOriginal = aperiodicityWithOriginalTime.cutOffList;
apStructure.residualMatrixFix = aperiodicityWithNormalizedTime.residualMatrix;
apStructure.cutOffListFix = aperiodicityWithNormalizedTime.cutOffList;
apStructure.temporalPositions = locations;
apStructure.targetF0 = targetF0;
apStructure.f0 = f0;
apStructure.periodicityLevel = sourceStruture.periodicityLevel;
apStructure.solutionConditionsOriginal = aperiodicityWithOriginalTime.solutionConditions;
apStructure.solutionConditionsFix = aperiodicityWithNormalizedTime.solutionConditions;
apStructure.samplingFrequency = fs;
apStructure.aperiodicityRange = aperiodicityRange.^pc;
apStructure.sigmoidParameter = sigmoidParameter;
apStructure.evaluation = evaluation;
apStructure.referenceError = referenceError;
apStructure.exponent = pc;
apStructure.elapsedTimeForAperiodicity = toc;
apStructure.procedure = 'aperiodicityRatioSigmoid3';

%---- internal functions ----
function [stretchedSignal,stretchedLocations] = ...
    normalizeSignal(x,fs,f0,locations,targetF0)
%targetF0 = max(32,min(f0(f0>0)));
f0(f0<targetF0) = f0(f0<targetF0)*0+targetF0;
extendedX = reshape([x,zeros(length(x),3)]',length(x)*4,1);
interpolatedX = conv(hanning(7),extendedX);
originalSignalTime = (0:length(interpolatedX)-1)/(fs*4);
interpolatedF0 = interp1(locations,f0, ...
    originalSignalTime,'linear','extrap');
stretchedTime = cumsum(interpolatedF0/targetF0/(fs*4));
stretchedSignal4 = interp1(stretchedTime,interpolatedX,...
    0:1/(fs*4):stretchedTime(end),'linear','extrap');
stretchedLocations = ...
    interp1(originalSignalTime,stretchedTime,locations,'linear','extrap');
stretchedSignal = decimate(stretchedSignal4,4);

function [hHP,hLP] = designQMFpairOfFilters(fs)
%   This routine is not optimized. But, it is practically functional.
%   Power sum of each frequency response is within 3% deviation around
%   crossover frequency. This part can be replaced by discrete wavelet
%   transform.

%fs = 22050; % This is only an example.
boundaryFq = fs/4;
transitionWidth = 1/4;
levelTolerancePassBand = 0.1; % 4% fluctuation
levelToleranceStopBand = 0.002; % -60 dB
mags = [0 1];
fcuts = boundaryFq*2.0.^(transitionWidth*[-1 1]);
devs = [levelToleranceStopBand levelTolerancePassBand];
cutOffShift = 1/17.3; % numerically adjusted

[nTapsHP,WnHP,betaHP,ftypeHP] = ...
    kaiserord(fcuts*2.0.^(-cutOffShift),mags,devs,fs);

[nTapsLP,WnLP,betaLP,ftypeLP] = ...
    kaiserord(fcuts*2.0.^(cutOffShift),mags(end:-1:1),devs(end:-1:1),fs);

hLP = fir1(nTapsLP,WnLP,ftypeLP,kaiser(nTapsLP+1,betaLP),'noscale');
hHP = fir1(nTapsHP,WnHP,ftypeHP,kaiser(nTapsHP+1,betaHP),'noscale');

function aperiodicityStr = ...
    bandwiseAperiodicity(wholeSignal,sourceStr,samplingFrequency,nOrder,windowLengthMs)
PermissibleLimit = 0.2;
TBLimProduct = [3.5794 5.1728 6.4941];
OrderList = [2 3 4];

%nominalCutOff = 1000;
%nominalCutOff = interp1(OrderList,...
%    TBLimProduct/PermissibleLimit/(windowLengthMs/1000),nOrder,'linear','extrap');
%   The above automatic limit is replaced by fixed frequency.
%   Automatic setting is not good for perception. 29/Nov./2009
nominalCutOff = 600;
nFrames = length(sourceStr.f0);
[hHP,hLP] = designQMFpairOfFilters(samplingFrequency);

cutOffList = (samplingFrequency/4);
while cutOffList(end) > nominalCutOff
    cutOffList = [cutOffList; cutOffList(end)/2];
end;
cutOffList = cutOffList(1:end-1);

nMarginBias = nOrder; % 2 may be reasonable
residualMatrix = zeros(length(cutOffList)+1,nFrames);
wholeSignal = [wholeSignal;0.0001*randn(length(hHP)*2,1)];

for ii = 1:length(cutOffList)
    fsTmp = cutOffList(ii)*2;
    highSignal = fftfilt(hHP,wholeSignal);
    lowSignal = fftfilt(hLP,wholeSignal);
    downSampledHighSignal = highSignal(1:2:end);
    residualObj = f0PredictionResidualFixSegmentW(downSampledHighSignal,...
        fsTmp,sourceStr,nMarginBias,-length(hHP)/2/fsTmp,windowLengthMs);
    wholeSignal = [lowSignal(1:2:end);0.0001*randn(length(hHP)*2,1)];
    residualMatrix(length(cutOffList)+1-ii+1,:) = residualObj.rmsResidual';
    solutionConditions(ii).conditionNumberList = residualObj.conditionNumberList;
end;
residualObjW = f0PredictionResidualFixSegmentW(wholeSignal,...
    fsTmp,sourceStr,nMarginBias,-length(hLP)/2/fsTmp,windowLengthMs);
residualMatrix(1,:) = residualObjW.rmsResidual';
aperiodicityStr.residualMatrix = residualMatrix;
aperiodicityStr.solutionConditions = solutionConditions;
aperiodicityStr.cutOffList = cutOffList(end:-1:1);


