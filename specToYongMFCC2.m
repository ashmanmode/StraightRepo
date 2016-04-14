function [mfccParam,filterOut] = specToYongMFCC2(weightMatrix,n3sgram,fs)

nCoefficients = size(weightMatrix,1);
%nFrequency = size(n3sgram,1);
%frequencyAxis = (0:nFrequency-1)/(nFrequency-1)*fs/2;

filterOut = weightMatrix*n3sgram;

%spatialFrequency = ((1:nCoefficients)-1/2)/nCoefficients*pi;
%cosTable = cos((1:nCoefficients)'*spatialFrequency);
cosTable=dctmtx(nCoefficients)';

mfccParam = cosTable*(log(filterOut));
                                                                           
