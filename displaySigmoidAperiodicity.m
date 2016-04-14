function aperiodicityStructure = displaySigmoidAperiodicity(fAxis,aperiodicityParameter,displayOn)

switch nargin
    case 2
        displayOnInternal = 0;
    otherwise
        displayOnInternal = displayOn;
end;

nFrames = size(aperiodicityParameter,1);
randomComponent = zeros(size(fAxis(:),1),nFrames);
erbAxis = hzToERBNnumber(fAxis(:));
for ii = 1:nFrames
    centerErb = aperiodicityParameter(ii,1);
    widthErb = aperiodicityParameter(ii,2);
    ySigmoid = 1.0./(1+exp(-(erbAxis-centerErb)/widthErb)) ...
        -1.0./(1+exp(-(13-centerErb)/widthErb));
    randomComponent(:,ii) = ySigmoid;
end;
randomComponent = max(0.00001,randomComponent);
aperiodicityStructure.frequencyAxis = fAxis;
aperiodicityStructure.randomComponent = randomComponent;
if displayOnInternal
    figure;
    imagesc([0 nFrames-1],[0 fAxis(end)],randomComponent);
    axis('xy');
end;
return;

