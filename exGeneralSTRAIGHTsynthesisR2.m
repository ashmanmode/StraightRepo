function synthOut = exGeneralSTRAIGHTsynthesisR2(sourceStructure,filterStructure)
%   synthOut = exGeneralSTRAIGHTsynthesisR2(sourceStructure,filterStructure)

%   wrapper for generalized synthesis routine for TANDEM-STRAIGHT manipulation
%   Designed and coded by Hideki Kawahara
%   05/Mar./2012 more generalization
%   27/Mar./2012 revised for new formulation

dataStructure.samplingFrequency = sourceStructure.samplingFrequency;
dataStructure.sigmoidParameter = sourceStructure.sigmoidParameter;
dataStructure.vuv = sourceStructure.vuv;
dataStructure.f0 = sourceStructure.f0;
dataStructure.temporalPositions = sourceStructure.temporalPositions;
dataStructure.cutOffListFix = sourceStructure.cutOffListFix;
dataStructure.targetF0 = sourceStructure.targetF0;
dataStructure.exponent = sourceStructure.exponent;
dataStructure.spectrogramSTRAIGHT = filterStructure.spectrogramSTRAIGHT;

dataStructure.transitionWidth = 0.15;
dataStructure.sourceOption = (1-0.5*sourceStructure.vuv');

synthOut = generalSTRAIGHTsynthesisFrameworkR2(@interpFetcherFixRate, ...
    @minimumPhaseResponse,@f0AdaptiveDClessPulseR2,@noiseBurstInFrequencyR2, ...
    @generateBaseShifterSigmoid,dataStructure);
return;
