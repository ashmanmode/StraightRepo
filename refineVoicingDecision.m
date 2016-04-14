function vuv = refineVoicingDecision(x,sourceStructure)

%   This function should be called after F0 refinement and intial vuv
%   decision.
%   This is an old-fashioned procedure.
%   Please rewrite this function based on Bayesian approach.

fs = sourceStructure.samplingFrequency;
vuv = sourceStructure.vuv;
f0 = sourceStructure.f0;
%vuv = initialVUVmark; % initial condition
periodicityScore = max(0,sourceStructure.periodicityLevel);
locations = sourceStructure.temporalPositions;
seggmentLengthThreshold = 0.019;
marginWidth = 0.021;

%f0PowerLevel = sourceStructure.f0candidatesPowerMap(1,:);
%medianVoicedLevel = median(f0PowerLevel(vuv>0));
%relativePower = f0PowerLevel/medianVoicedLevel;

f0AdaptiveScore = f0AdaptiveSmoothing(periodicityScore',locations,f0);
smoothedPower = f0AdaptivePower(x,fs,locations,f0,vuv);
f0AdaptiveLevel = 10*log10(smoothedPower);
normalizedLevel = f0AdaptiveLevel-median(f0AdaptiveLevel(vuv>0));

initialVUVmark = vuv;%((f0AdaptiveScore>0.6) & (normalizedLevel>-20))';

onLocations = find(diff([0;initialVUVmark;0]) > 0.5);
offLocations = find(diff([0;initialVUVmark;0]) < -0.5);

segmentLengthInFrames = offLocations-onLocations;
onLocations = onLocations(segmentLengthInFrames>1);
offLocations = offLocations(segmentLengthInFrames>1);

segmentLength = locations(offLocations-1)-locations(onLocations);
onLocations = onLocations(segmentLength>seggmentLengthThreshold);
offLocations = offLocations(segmentLength>seggmentLengthThreshold);
offLocations = min(length(vuv),offLocations);

%onLocations = find(diff([0;initialVUVmark;0]) > 0.5);
%offLocations = find(diff([0;initialVUVmark;0]) < -0.5);

numberOfSegments = length(onLocations);
backwardSearchEndLocation = 1;
if numberOfSegments > 1
    forwardSerachEndLocation = ceil((onLocations(2)+offLocations(1))/2);
else
    forwardSerachEndLocation = length(locations);
end;

f0AdaptiveScore = f0AdaptiveSmoothing(periodicityScore',locations,f0);
smoothedPower = f0AdaptivePower(x,fs,locations,f0,vuv);
f0AdaptiveLevel = 10*log10(smoothedPower);
normalizedLevel = f0AdaptiveLevel-median(f0AdaptiveLevel(vuv>0));
offlevelThreshold = -24;
onlevelThreshold = -14;
socreThreshold = 0.3;

numberOfSegments = length(onLocations);
backwardSearchEndLocation = 1;
if numberOfSegments > 1
    forwardSerachEndLocation = ceil((onLocations(2)+offLocations(1))/2);
else
    forwardSerachEndLocation = length(locations);
end;
forwardSerachEndLocation = max(1,min(forwardSerachEndLocation,length(normalizedLevel)));

skeltonVUV = vuv*0;
for ii = 1:numberOfSegments
    centerPosition = round((onLocations(ii)+offLocations(ii))/2);
    skeltonVUV(centerPosition) = 1;
    for jj = centerPosition:-1:backwardSearchEndLocation
        if ((normalizedLevel(jj) > onlevelThreshold) && ...
                (f0AdaptiveScore(jj) > socreThreshold)) || ...
                (locations(onLocations(ii))+marginWidth < locations(jj))
            skeltonVUV(jj) = 1;
        else
            break
        end;
    end;
    for jj = centerPosition:forwardSerachEndLocation
        
        if ((normalizedLevel(jj) > offlevelThreshold) && ...
                (f0AdaptiveScore(jj) > socreThreshold)) || ...
                (locations(offLocations(ii))-marginWidth > locations(jj))
            skeltonVUV(jj) = 1;
        else
            break
        end;
    end;
    backwardSearchEndLocation = forwardSerachEndLocation;
    if numberOfSegments > ii+1
        forwardSerachEndLocation = ceil((onLocations(ii+2)+offLocations(ii+1))/2);
    else
        forwardSerachEndLocation = length(locations);
    end;
end;
vuv = skeltonVUV;

function smoothedValue = f0AdaptiveSmoothing(data,locations,f0)

deltaT = locations(2);
totalEnergy = cumsum(data*deltaT);
energyAtFrontEdge = interp1([0-deltaT locations locations(end)+deltaT], ...
    [totalEnergy(1) totalEnergy totalEnergy(end)],locations-0.5./f0','linear','extrap');
energyAtRearEdge = interp1([0-deltaT locations locations(end)+deltaT], ...
    [totalEnergy(1) totalEnergy totalEnergy(end)],locations+0.5./f0','linear','extrap');
smoothedValue = (energyAtRearEdge-energyAtFrontEdge).*f0';

function smoothedPower = f0AdaptivePower(x,fs,locations,f0,vuv)

%upperLimit = 1000;
medianF0 = median(f0(vuv>0));
upperLimit = 4*medianF0;
halfLength = round(fs/upperLimit);
smoothingWindow = hanning(2*halfLength+1);
smoothingWindow = smoothingWindow/sum(smoothingWindow);
dcRemovalLength = round(fs/mean(f0(vuv>0))/2);
dcRemovalWindow = hanning(2*dcRemovalLength+1);
dcRemovalWindow = -dcRemovalWindow/sum(dcRemovalWindow);
dcRemovalWindow(dcRemovalLength+1) = dcRemovalWindow(dcRemovalLength+1)+1;
xTmp = fftfilt(smoothingWindow,[x(:);zeros(halfLength*2,1)]);
xTmp = xTmp((1:length(x))+halfLength);
xTmp = fftfilt(dcRemovalWindow,[xTmp(:);zeros(dcRemovalLength*2,1)]);
xTmp = xTmp((1:length(x))+dcRemovalLength);
tt = (0:length(x)-1)/fs;
frontEdgePower = interp1(tt,cumsum(xTmp.^2/fs),locations-0.5./f0');
rearEdgePower = interp1(tt,cumsum(xTmp.^2/fs),locations+0.5./f0');
smoothedPower = (rearEdgePower-frontEdgePower).*f0';





