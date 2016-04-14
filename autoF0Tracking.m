function fixedStructure = autoF0Tracking(f0Structure,x)

%   adjusted segment level by H.K. 17/Aug./2012
%   error fix based on Banno's comment 22/March/2013

fixedStructure = f0Structure;
fs = f0Structure.samplingFrequency;
f0Map = f0Structure.f0CandidatesMap;
ScoreMap = f0Structure.f0CandidatesScoreMap;
powerMap = f0Structure.f0candidatesPowerMap;
locations = f0Structure.temporalPositions;
tunedF0 = f0Structure.f0;
deltaT = mean(diff(locations));
voicedMargin = 30; % added by H.K. 17/Aug./2012
sourceMargin = 40; % added by H.K. 17/Aug./2012

% cleaning f0 anomary

f0Raw = f0Map(1,:);
f0Raw = f0Raw(:);
tunedF0(abs(log2(tunedF0./f0Raw))>0.5) = ...
    f0Raw(abs(log2(tunedF0./f0Raw))>0.5);

ScoreThreshold = 0.65;
reliableF0Threshold = 0.8;
seggmentLengthThreshold = 0.019;
%f0SkipLimit = 2^(1/3)*deltaT/0.005; % reference 5ms
%f0SkipLimit = 2^(1/3)*sqrt(deltaT/0.005); % reference 5ms assuming random 17/Aug./2012
f0SkipLimit = (2^(1/3)-1)*sqrt(deltaT/0.005); % comment by Banno
TopScore = ScoreMap(1,:);
TopF0 = f0Map(1,:)';
TopPower = 10*log10(powerMap(1,:)');

voicedLevel = median(TopScore(TopScore>ScoreThreshold));
voicedSD = std(TopScore(TopScore>ScoreThreshold));
voicedPowerLevel = median(TopPower(TopScore>ScoreThreshold));
voicedPowerSD = std(TopPower(TopScore>ScoreThreshold));

vuvLimit = voicedLevel-2*voicedSD;

initialVUVmark = TopScore>vuvLimit;
onLocations = find(diff([0 initialVUVmark 0]) > 0.5);
offLocations = find(diff([0 initialVUVmark 0]) < -0.5);

segmentLengthInFrames = offLocations-onLocations;
onLocations = onLocations(segmentLengthInFrames>1);
offLocations = offLocations(segmentLengthInFrames>1);

segmentLength = locations(offLocations-1)-locations(onLocations);
onLocations = onLocations(segmentLength>seggmentLengthThreshold);
offLocations = offLocations(segmentLength>seggmentLengthThreshold);
offLocations = min(length(TopPower),offLocations);

%segmentLength = locations(offLocations-1)-locations(onLocations);
numberOfSegments = length(onLocations);
if numberOfSegments < 1
    disp('number of segments is 0');
    return;
end;
meanPowerLevel = zeros(numberOfSegments,1);
for ii = 1:numberOfSegments
    meanPowerLevel(ii) = mean(TopPower(onLocations(ii):offLocations(ii)));
end;
onLocations = onLocations(meanPowerLevel>voicedPowerLevel-voicedMargin); % by H.K. 17/Aug./2012
offLocations = offLocations(meanPowerLevel>voicedPowerLevel-voicedMargin);% by H.K. 17/Aug./2012
numberOfSegments = length(onLocations);
if numberOfSegments < 1
    disp('number of segments is 0');
    return;
end;

backwardSearchEndLocation = 1;
if numberOfSegments > 1
    forwardSerachEndLocation = ceil((onLocations(2)+offLocations(1))/2);
else
    forwardSerachEndLocation = length(locations);
end;

vuvLimitLow = 0.2;
skeltonF0 = TopF0*0;
skeltonScore = skeltonF0;
skeltonPower = skeltonF0;
for ii = 1:numberOfSegments
    centerPosition = round((onLocations(ii)+offLocations(ii))/2);
    startF0 = TopF0(centerPosition);
    previousF0 = startF0;
    skeltonF0(centerPosition) = previousF0;
    skeltonScore(centerPosition) = TopScore(centerPosition);
    %disp([num2str(centerPosition) '  ' num2str(backwardSearchEndLocation) ...
    %'  ' num2str(forwardSerachEndLocation)]);
    for jj = centerPosition:-1:backwardSearchEndLocation
        [dummy,closestIndex] = min(abs(f0Map(:,jj)-previousF0));
%        if (dummy/previousF0 < (f0SkipLimit-1)) && % comment by Banno
%        (ScoreMap(closestIndex,jj) > vuvLimitLow) % comment by Banno
        if (dummy/previousF0 < f0SkipLimit) && (ScoreMap(closestIndex,jj) > vuvLimitLow)
            previousF0 = f0Map(closestIndex,jj);
        end;
        skeltonF0(jj) = previousF0;
        skeltonScore(jj) = ScoreMap(closestIndex,jj);
        skeltonPower(jj) = powerMap(jj);
    end;
    previousF0 = startF0;
    for jj = centerPosition:forwardSerachEndLocation
        [dummy,closestIndex] = min(abs(f0Map(:,jj)-previousF0));
%        if (dummy/previousF0 < (f0SkipLimit-1)) && % comment by Banno
%        (ScoreMap(closestIndex,jj) > vuvLimitLow) % comment by Banno
        if (dummy/previousF0 < f0SkipLimit) && (ScoreMap(closestIndex,jj) > vuvLimitLow)
            previousF0 = f0Map(closestIndex,jj);
        end;
        skeltonF0(jj) = previousF0;
        skeltonScore(jj) = ScoreMap(closestIndex,jj);
        skeltonPower(jj) = powerMap(jj);
    end;
    backwardSearchEndLocation = forwardSerachEndLocation;
    if numberOfSegments > ii+1
        forwardSerachEndLocation = ceil((onLocations(ii+2)+offLocations(ii+1))/2);
    else
        forwardSerachEndLocation = length(locations);
    end;
end;

tunedF0(abs(log2(tunedF0./skeltonF0))>0.5) = ...
    skeltonF0(abs(log2(tunedF0./skeltonF0))>0.5);
skeltonF0(skeltonScore>reliableF0Threshold) = ...
    tunedF0(skeltonScore>reliableF0Threshold);
medianF0 = median(skeltonF0(skeltonScore>0.7));
marginWidth = 0.75/medianF0;

source = voicedPowerExtractor(x,fs,medianF0);
timeBase = (0:length(x)-1)/fs;
%f0Interpolated = interp1(locations,skeltonF0,timeBase,'linear','extrap');
scoreDetailForward = ...
    interp1(locations,skeltonScore,timeBase+marginWidth,'linear','extrap');
scoreDetailForwardH = ...
    interp1(locations,skeltonScore,timeBase+marginWidth/2,'linear','extrap');
scoreDetailCenter = ...
    interp1(locations,skeltonScore,timeBase,'linear','extrap');
scoreDetailBackward = ...
    interp1(locations,skeltonScore,timeBase-marginWidth,'linear','extrap');
scoreDetailBackwardH = ...
    interp1(locations,skeltonScore,timeBase-marginWidth/2,'linear','extrap');
scoreInterpolated = max([scoreDetailForward(:)';scoreDetailCenter(:)';scoreDetailBackward(:)';...
    scoreDetailForwardH(:)';scoreDetailBackwardH(:)']);

medianLevel = 20*log10(median(source(scoreInterpolated>0.7)));

vuvInterpolated = double((scoreInterpolated(:)>0.4) & (20*log10(source(:))>medianLevel-sourceMargin));% by H.K. 17/Aug./2012
fixedStructure.f0 = skeltonF0(:);
vuv = interp1(timeBase,vuvInterpolated,locations,'nearest','extrap');
periodicityLevel = interp1(timeBase,scoreInterpolated,locations,'nearest','extrap');
fixedStructure.vuv = vuv(:);
fixedStructure.periodicityLevel = periodicityLevel(:);

return;

function source = voicedPowerExtractor(x,fs,medianF0)

w1 = hanning(2*round(fs/(medianF0/2))-1);
w2 = hanning(2*round(fs/(medianF0*3))-1);
xl = fftfilt(w2/sum(w2),[x;w2*0]);
xl = xl((1:length(x))+round(length(w2)/2));
w1 = -w1/sum(w1);
w1center = ceil(length(w1)/2);
w1(w1center) = w1(w1center)+1;
xlh = fftfilt(w1,[xl;w1*0]);
xlh = xlh((1:length(x))+w1center);
w3 = hanning(round(2*sqrt(2)*(fs/medianF0))+1);
xrec = fftfilt(w3/sum(w3),abs([xlh;w3*0]));
source = xrec((1:length(x))+round(length(w3)/2));
