function morphingRateStructure = interpolateMorphingRate(mSubstrateA,mSubstrateB,lambda,expansionRate)

fieldNames = {'spectrum';'frequency';'aperiodicity';'F0';'time'};
morphingRateStructure = [];
mRateA = mSubstrateA.temporalMorphingRate;
mRateB = mSubstrateB.temporalMorphingRate;
for ii = 1:length(fieldNames)
    %eval(['scalarMRate = (1-lambda)*mRateA.' fieldNames{ii} ...
    %    '+lambda*mRateB.' fieldNames{ii} ';']);
    eval(['valueA = mRateA.' fieldNames{ii} ';']);
    eval(['valueB = mRateB.' fieldNames{ii} ';']);
    tmp = (1-lambda)*valueA+lambda*valueB;
    scalarMRate = (tmp-0.5)*expansionRate+0.5;
    eval(['morphingRateStructure.' fieldNames{ii} ' = scalarMRate;']);
end;
%disp(['lambda=' num2str(lambda) '  valueA=' num2str(valueA(15)) ... 
%    '  valueB=' num2str(valueB(15)) ' tmp=' num2str(tmp(15)) ...
%    '  final=' num2str(scalarMRate(15))]);
return;