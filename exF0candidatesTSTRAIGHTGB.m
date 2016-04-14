function sourceInformation = exF0candidatesTSTRAIGHTGB(x,fs,paramSin)
%   sourceInformation = exF0candidatesTSTRAIGHTGB(x,fs,paramSin)
%   F0 candidates extraction using TANDEM-STRAIGHT
%   Inputs
%       x   : input signal
%       fs  : sampling frequency (Hz)
%       paramSin    : optional parameters
%   Outputs
%       sourceInformation   : structure havein source information
%
%   Usage
%       sourceInformation = exF0candidatesTSTRAIGHTGB;
%           This returnes default control parameters
%       sourceInformation = exF0candidatesTSTRAIGHTGB(x,fs);
%           F0 and aperiodicity information are extracted using default
%           control parameters
%       sourceInformation = exF0candidatesTSTRAIGHTGB(x,fs,paramSin);
%           F0 and aperiodicity information are extracted using customized
%           control parameters

%   Designed and coded by Hideki Kawahara
%   31/Oct./2007
%   01/Nov./2007 first release
%   02/Nov./2007 minor bug fix
%   21/Nov./2007 minor bug fix
%   01/Dec./2007 minor bug fix
%   11/Dec./2007 compatibility fix by Hideki Banno
%   16/Dec./2007 DC removal and rename
%   01/Nov./2009 Calibration using a periodic pulse train
%   02/Nov./2012 bug fix

%---- initialize parameters for default
framePeriod =   5; % in ms
f0floor = 32;
f0ceil = 650;
nh = 3;
setLagPeriodicityMapForF0 = 1;
calculateAperiodicityParameter = 1;
optP.cycles = 4;
optP.channelsPerOctave = 3;
optP.tuningFactor = 0; % This parameter is obsolate.
optP.isSingleBand = 0; % default is multi-band (0)
optP.correctionForBlackman = 4;
optP.periodicityShaping = 2.5; % (set 1 for enabling shaping)???
optP.q1 = 0;
optP.DCremoval = 1;
optP.exponentControl = 1;
optP.cepstralSmoothing = 0;
optP.calibration = 1;
optP.lagShapingType = 'logarithmic';
%paramSin.debugBiasCorrection
optP.biasCorrection = 0.07;
%  parameters for aperiodicity parameters
nominalSamplingFrequency = 6000;%4000;
defaultF0 = 100;
targetF0 = 100;
biasInsmoothing = 3; % set smoothing size
nCycles = 14;

if nargin == 2
    % Do nothing meaning to use default parameters
    sourceInformation.samplingFrequency = fs;
elseif nargin == 3
    if isfield(paramSin, 'framePeriod')
        framePeriod = paramSin.framePeriod;
    end;
    if isfield(paramSin, 'f0floor')
        f0floor = paramSin.f0floor;
    end;
    if isfield(paramSin, 'f0ceil')
        f0ceil = paramSin.f0ceil;
    end;
    if isfield(paramSin, 'numberOfHarmonicsForRefinement')
        nh = paramSin.numberOfHarmonicsForRefinement;
    end;
    if isfield(paramSin, 'setLagPeriodicityMapForF0')
        setLagPeriodicityMapForF0 = paramSin.setLagPeriodicityMapForF0;
    end;
    if isfield(paramSin, 'calculateAperiodicityParameter')
        calculateAperiodicityParameter = paramSin.calculateAperiodicityParameter;
    end;
    if isfield(paramSin, 'numberOfHarmonicsForExtraction')
        optP.cycles = paramSin.numberOfHarmonicsForExtraction;
    end;
    if isfield(paramSin, 'channelsPerOctave')
        optP.channelsPerOctave = paramSin.channelsPerOctave;
    end;
    if isfield(paramSin, 'debugF0tuningFactor')
        optP.tuningFactor = paramSin.debugF0tuningFactor;
    end;
    if isfield(paramSin, 'debugisSingleBand')
        optP.isSingleBand = paramSin.debugisSingleBand;
    end;
    if isfield(paramSin, 'debugcorrectionForBlackman')
        optP.correctionForBlackman = paramSin.debugcorrectionForBlackman;
    end;
    if isfield(paramSin, 'debugperiodicityShaping')
        optP.periodicityShaping = paramSin.debugperiodicityShaping;
    end;
    if isfield(paramSin, 'debugq1')
        optP.q1 = paramSin.debugq1;
    end;
    if isfield(paramSin, 'debugnominalSamplingFrequency')
        nominalSamplingFrequency = paramSin.debugnominalSamplingFrequency;
    end;
    if isfield(paramSin, 'defaultF0ForAP')
        defaultF0 = paramSin.defaultF0ForAP;
    end;
    if isfield(paramSin, 'targetF0ForAP')
        targetF0 = paramSin.targetF0ForAP;
    end;
    if isfield(paramSin, 'biasInsmoothingForAP')
        biasInsmoothing = paramSin.biasInsmoothingForAP;
    end;
    if isfield(paramSin, 'nCyclesForAP')
        nCycles = paramSin.nCyclesForAP;
    end;
    if isfield(paramSin, 'DCremoval')
        optP.DCremoval = paramSin.DCremoval;
    end;
    if isfield(paramSin, 'exponentControl')
        optP.exponentControl = paramSin.exponentControl;
    end;
    if isfield(paramSin, 'calibration')
        optP.calibration = paramSin.calibration;
    end;
    if isfield(paramSin, 'lagShapingType')
        optP.lagShapingType = paramSin.lagShapingType;
    end;
    if isfield(paramSin, 'debugBiasCorrection')
        optP.biasCorrection = paramSin.debugBiasCorrection;
    end;
    sourceInformation.samplingFrequency = fs;
end;
% set default parameters
controlParameters.f0floor = f0floor;
controlParameters.f0ceil = f0ceil;
controlParameters.framePeriod = framePeriod;
controlParameters.numberOfHarmonicsForRefinement = nh;
controlParameters.setLagPeriodicityMapForF0 = setLagPeriodicityMapForF0;
controlParameters.calculateAperiodicityParameter = ...
    calculateAperiodicityParameter;
controlParameters.numberOfHarmonicsForExtraction = optP.cycles;
controlParameters.channelsPerOctave = optP.channelsPerOctave;
controlParameters.debugF0tuningFactor = ...
    optP.tuningFactor; % This parameter is obsolate.
controlParameters.debugisSingleBand = ...
    optP.isSingleBand; % default is multi-band (0)
controlParameters.debugcorrectionForBlackman = ...
    optP.correctionForBlackman;
controlParameters.debugperiodicityShaping = ...
    optP.periodicityShaping; % (set 1 for enabling shaping)??
controlParameters.debugq1 = optP.q1;
controlParameters.debugnominalSamplingFrequency = ...
    nominalSamplingFrequency;
controlParameters.lagShapingType = ...
    optP.lagShapingType;
controlParameters.biasCorrection = ...
    optP.biasCorrection;
controlParameters.defaultF0ForAP = defaultF0;
controlParameters.targetF0ForAP = targetF0;
controlParameters.biasInsmoothingForAP = biasInsmoothing; % set smoothing size
controlParameters.nCyclesForAP = nCycles;
controlParameters.cepstralSmoothing = 0;

sourceInformation.dateOfSourceExtraction = datestr(now);
sourceInformation.controlParameters = controlParameters;

if nargin == 0 || isempty(x)
    return
end;

%---- downsample signal and make reference frame
ndivide = round(fs/nominalSamplingFrequency);

fsd = fs/ndivide;
xd = decimate(x,ndivide);

temporalPoints = 0:framePeriod/1000:(length(xd)-1)/fsd;

%---- prepare for iteration
f0 = zeros(length(temporalPoints),1);
f0init = f0;
periodicityLevel = zeros(length(temporalPoints),1);

caliburationConstant = 1;
if optP.calibration
    caliburationConstant = getCaliburation(fsd,f0floor,f0ceil,optP);
end;

[f0raw,periodicityRating,statusParams] = ...
    TANDEMf0GB(xd,fsd,temporalPoints(1),f0floor,f0ceil,optP);
lagAndPeriodicity = statusParams.cumulativePeriodicity;
if setLagPeriodicityMapForF0 == 1
    periodicityMap = zeros(length(lagAndPeriodicity),length(temporalPoints));
end;
maxCandidates = 5;
f0CandidatesMap = zeros(maxCandidates,length(temporalPoints));
f0CandidatesScoreMap = f0CandidatesMap;
f0candidatesPowerMap = f0CandidatesMap;

ii = 0;
tic;
for currentTime = temporalPoints
    ii = ii+1;
    [f0raw,periodicityRating,statusParams] = ...
        TANDEMf0GB(xd,fsd,currentTime,f0floor,f0ceil,optP);
    lagAndPeriodicity = statusParams.cumulativePeriodicity;
    f0init(ii) = f0raw;
    f0raw = max(f0floor,min(fsd/2,f0raw));
    estimatedF01 = refineF0AssumptionGB(xd,fsd,currentTime,f0raw,nh);
    estimatedF01 = max(f0floor,min(fsd/2,estimatedF01));
    f0(ii) = ...
        refineF0AssumptionGB(xd,fsd,currentTime,estimatedF01,nh);
    f0(ii) = max(f0floor,min(fsd/2,f0(ii)));
    periodicityLevel(ii) = periodicityRating;
    if setLagPeriodicityMapForF0 == 1
        periodicityMap(:,ii) = lagAndPeriodicity;
    end;
    numberOfCandidates = min(maxCandidates,sum(statusParams.f0candidates>0));
    if numberOfCandidates > 0
        f0CandidatesMap(1:numberOfCandidates,ii) = ...
            statusParams.f0candidates(1:numberOfCandidates);
        f0CandidatesScoreMap(1:numberOfCandidates,ii) = ...
            statusParams.f0candidatesRatings(1:numberOfCandidates);
        f0candidatesPowerMap(1:numberOfCandidates,ii) = ...
            statusParams.f0candidatesPower(1:numberOfCandidates);
    end;
end;
elapsedTimeForF0 = toc;

%f0Sequence = f0;
%f0Sequence(periodicityLevel<0.9) = f0Sequence(periodicityLevel<0.9)*0;
temporalPositions = temporalPoints;
statusParamsF0 = statusParams;

%---- copy results to output structure
sourceInformation.f0 = f0;
sourceInformation.periodicityLevel = periodicityLevel/caliburationConstant;
if setLagPeriodicityMapForF0 == 1
    sourceInformation.periodicityMap = periodicityMap;
end;
sourceInformation.temporalPositions = temporalPositions;
sourceInformation.f0CandidatesMap = f0CandidatesMap;
sourceInformation.f0CandidatesScoreMap = f0CandidatesScoreMap/caliburationConstant;
sourceInformation.f0candidatesPowerMap = f0candidatesPowerMap;
sourceInformation.elapsedTimeForF0 = elapsedTimeForF0;
sourceInformation.statusParamsF0 = statusParamsF0;

%---- internal function

function caliburationConstant = getCaliburation(fsd,f0floor,f0ceil,optP)

%caliburationConstant = 1;
tt = 0:1/fsd:0.2;
xd = tt(:)*0;
%t0InSample = round(fsd/100);
t0InSample = round(fsd/sqrt(f0floor*f0ceil)); % bug fix 02/Nov./2012
xd(1:t0InSample:end) = 1;
xd = xd-mean(xd);
[dummy,periodicityRating,statusParams] = ...
    TANDEMf0GB(xd,fsd,0.2/2,f0floor,f0ceil,optP);
%disp([num2str(f0raw) '  ' num2str(periodicityRating)]);
caliburationConstant = periodicityRating;
return;

