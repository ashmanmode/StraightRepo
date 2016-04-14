function realTimeBase = generateMorphingRealTimeAxis(mSubstrate)
%   set corresponding anchors
%   A -- speaker A,  B -- speaker B, M -- morphing space
deltaTofM = diff(mSubstrate.morphingTimeAxis);%diff(mSubstrate.temporalMorphingRate.time);
deltaTofM = deltaTofM(1);
%mSubstrate = morphingSubstrate(mSubstrate,'generate','morphingTimeAxis');
extendedAnchorOnA = [0;mSubstrate.temporaAnchorOfSpeakerA; ...
    mSubstrate.f0TimeBaseOfSpeakerA(end)];
extendedAnchorOnB = [0;mSubstrate.temporaAnchorOfSpeakerB; ...
    mSubstrate.f0TimeBaseOfSpeakerB(end)];
extendedAnchorOnM = [0;mSubstrate.anchorOnMorphingTime; ...
    mSubstrate.morphingTimeAxis(end)];

%   prepare coordinate conversion functions
timeOnM = mSubstrate.morphingTimeAxis;
mRateAtoBonM = mSubstrate.temporalMorphingRate.time;
mapMtoAonM = ...
    interp1(extendedAnchorOnM,extendedAnchorOnA,timeOnM,'linear','extrap');
mapMtoBonM = ...
    interp1(extendedAnchorOnM,extendedAnchorOnB,timeOnM,'linear','extrap');
deltaMtoAonM = diff(mapMtoAonM)/deltaTofM;
deltaMtoAonM = [deltaMtoAonM;deltaMtoAonM(end)];
deltaMtoBonM = diff(mapMtoBonM)/deltaTofM;
deltaMtoBonM = [deltaMtoBonM;deltaMtoBonM(end)];
deltaSonM = real(exp((1-mRateAtoBonM).*log(deltaMtoAonM)+mRateAtoBonM.*log(deltaMtoBonM)));
mapMtoSonM = cumsum(deltaSonM*deltaTofM);

%   set return values
realTimeBase.deltaMtoAonM = deltaMtoAonM;
realTimeBase.deltaMtoBonM = deltaMtoBonM;
realTimeBase.mapMtoAonM = mapMtoAonM;
realTimeBase.mapMtoBonM = mapMtoBonM;
realTimeBase.deltaSonM = deltaSonM;
realTimeBase.mapMtoSonM = mapMtoSonM;
realTimeBase.timeOnM = timeOnM;
