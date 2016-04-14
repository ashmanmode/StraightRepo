function morphingTimeBase = generateCommonTimeAnchors3(mSubstrate,mRateForCommonTime);
%disp('I am here!');
defaultFramePeriod = 0.005; % 5 ms in second
%   copy each time axis for each parameter
timeAxisF0A = mSubstrate.f0TimeBaseOfSpeakerA;
timeAxisF0B = mSubstrate.f0TimeBaseOfSpeakerB;
timeAxisAperiodicityA = mSubstrate.aperiodicityTimeBaseOfSpeakerA;
timeAxisAperiodicityB = mSubstrate.aperiodicityTimeBaseOfSpeakerB;
timeAxisSpectrograA = mSubstrate.spectrogramTimeBaseOfSpeakerA;
timeAxisSpectrograB = mSubstrate.spectrogramTimeBaseOfSpeakerB;

%   copy anchor points

timeAnchorA = mSubstrate.temporaAnchorOfSpeakerA;
timeAnchorB = mSubstrate.temporaAnchorOfSpeakerB;

extendedTimeAnchorA = [0; timeAnchorA; ...
    max([timeAxisF0A(end), timeAxisAperiodicityA(end), ...
    timeAxisSpectrograA(end)])];
extendedTimeAnchorB = [0; timeAnchorB; ...
    max([timeAxisF0B(end), timeAxisAperiodicityB(end), ...
    timeAxisSpectrograB(end)])];

%   define segments

segmentsA = zeros(length(extendedTimeAnchorA)-1,3);
segmentsB = zeros(length(extendedTimeAnchorA)-1,3);

for ii = 1:size(segmentsA,1)
    segmentsA(ii,:) = [extendedTimeAnchorA(ii), extendedTimeAnchorA(ii+1), ...
        extendedTimeAnchorA(ii+1)-extendedTimeAnchorA(ii)];
    segmentsB(ii,:) = [extendedTimeAnchorB(ii), extendedTimeAnchorB(ii+1), ...
        extendedTimeAnchorB(ii+1)-extendedTimeAnchorB(ii)];
end;

%   calculate anchor points on the common time axis

anchorOnMorphingTime = zeros(size(timeAnchorA,1),1);
currentAnchorPosition = 0;
for ii = 1:size(timeAnchorA,1)
    currentAnchorPosition = exp((1-mRateForCommonTime)*log(segmentsA(ii,3))+...
        mRateForCommonTime*log(segmentsB(ii,3)))+currentAnchorPosition;
    anchorOnMorphingTime(ii) = currentAnchorPosition;
end;
morphingTimeAxis = (0:defaultFramePeriod: ...
    currentAnchorPosition+exp((1-mRateForCommonTime)*log(abs(segmentsA(end,3)))...
    +mRateForCommonTime*log(abs(segmentsB(end,3)))))';

morphingTimeBase.anchorOnMorphingTime = anchorOnMorphingTime;
morphingTimeBase.framePeriod = defaultFramePeriod;
morphingTimeBase.morphingTimeAxis = morphingTimeAxis;
morphingTimeBase.mRateForCommonTime = mRateForCommonTime;

return;
