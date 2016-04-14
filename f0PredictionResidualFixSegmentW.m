function residualObj = f0PredictionResidualFixSegmentW(x,fs,r,nMarginBias,initialTime,durationMs)
%   residualObj =
%   f0PredictionResidualFixSegmentW(x,fs,r,nMarginBias,initialTime,durationMs)
%   Prediction error with
%       Fixed evaluation segment length
%       Hanning weighting

%   Designed and coded by Hideki Kawahara
%   03/Oct./2008
%   16/Oct./2008
%   17/Oct./2008
%   12/Oct./2009 fix for condition number hangling

nMargin = nMarginBias*2+1; % this also shoudl be a odd number
nFrames = length(r.temporalPositions);
rmsResidual = zeros(nFrames,1);
f0LowerLimit = 32;
nDataLength = length(x);
topLevel = max(x);
bottomLevel = min(x);
segmentLength = round(fs*durationMs/1000/2)*2+1;
w = diag(hanning(segmentLength));
wsqrt = sqrt(hanning(segmentLength));
conditionNumberList = zeros(nFrames,1);
%tic;
for ii = 1:nFrames
    currentF0 = r.f0(ii);
    if currentF0 >= f0LowerLimit
        t0InSamples = round(fs/currentF0);
        currentPositionInSample = round(-initialTime+r.temporalPositions(ii)*fs)+1;
        indexBias = round(fs/currentF0/2);
        segmentIndex = max(1,min(nDataLength,currentPositionInSample-indexBias ...
            +(1:segmentLength)'));
        H = zeros(segmentLength,nMargin*2);
        for jj = -nMarginBias:nMarginBias
            preSegmendIndex = max(1,min(nDataLength,jj+ ...
                currentPositionInSample-indexBias-t0InSamples+(1:segmentLength)'));
            H(:,jj+nMarginBias+1) = x(preSegmendIndex);
            postSegmendIndex = max(1,min(nDataLength,jj+ ...
                currentPositionInSample-indexBias+t0InSamples+(1:segmentLength)'));
            H(:,jj+nMarginBias+1+nMargin) = x(postSegmendIndex);
        end;
        R = H'*w*H;
        conditionNumberList(ii) = cond(R);
        if (conditionNumberList(ii) < 0.001) || (conditionNumberList(ii) > 10^6)
            %disp(['condition number=' num2str(conditionNumberList(ii))])
            %disp(['time at: ' num2str(r.temporalPositions(ii))]);
            if conditionNumberList(ii) < 0.001
                rmsResidual(ii) = 1;
            else
                rmsResidual(ii) = 0.0013;
            end;
        else
            a = inv(R)*(H'*w*x(segmentIndex));
            rmsResidual(ii) = std(wsqrt.*(x(segmentIndex)-H*a))/std(wsqrt.*x(segmentIndex));
        end;
        if 1 == 2
            plot((1:segmentLength),x(segmentIndex));
            axis([1 segmentLength bottomLevel topLevel]);
            drawnow;
        end;
    else
        rmsResidual(ii) = 1;
    end;
end;
%elapsedTimeList(kk) = toc;
residualObj.rmsResidual = rmsResidual;
residualObj.conditionNumberList = conditionNumberList;
residualObj.samplingFrequency = fs;

