function mSubstrate = morphingSubstrateNewAP(objectIn,instructionString,fieldName,fieldValue)
%   mSubstrate =
%   morphingSubstrateNewAP(objectIn,instructionString,fieldName,fieldValue)
%   manipulator of morphing substrate

%   by Hideki Kawahara
%   27/Aug./2008
%   03/Nov./2008 revised for new aperiodicity parameter

if nargin <1
    mSubstrate.creator = 'morphingSubstrateNewAP';
    mSubstrate.creationDate = datestr(now,30);
    mSubstrate.dataDirectoryForSpeakerA = [];
    mSubstrate.dataDirectoryForSpeakerB = [];
    mSubstrate.fileNameForSpeakerA = [];
    mSubstrate.fileNameForSpeakerB = [];
    mSubstrate.waveformForSpeakerA = [];
    mSubstrate.waveformForSpeakerB = [];
    mSubstrate.samplintFrequency = [];
    mSubstrate.temporaAnchorOfSpeakerA = [];
    mSubstrate.temporaAnchorOfSpeakerB = [];
    mSubstrate.frequencyAnchorOfSpeakerA = [];
    mSubstrate.frequencyAnchorOfSpeakerB = [];
    mSubstrate.f0OfSpeakerA = [];
    mSubstrate.f0TimeBaseOfSpeakerA = [];
    mSubstrate.f0OfSpeakerB = [];
    mSubstrate.f0TimeBaseOfSpeakerB = [];
    mSubstrate.STRAIGHTspectrogramOfSpeakerA = [];
    mSubstrate.spectrogramTimeBaseOfSpeakerA = [];
    mSubstrate.STRAIGHTspectrogramOfSpeakerB = [];
    mSubstrate.spectrogramTimeBaseOfSpeakerB = [];
    mSubstrate.aperiodicityOfSpeakerA = [];
    mSubstrate.aperiodicityTimeBaseOfSpeakerA = [];
    mSubstrate.aperiodicityOfSpeakerB = [];
    mSubstrate.aperiodicityTimeBaseOfSpeakerB = [];
    mSubstrate.temporalMorphingRate = [];
    return;
end;
mSubstrate = objectIn;
if nargin == 2
    switch instructionString
        case 'get'
            mSubstrate =  objectIn;
        case 'empty'
            mSubstrate = [];
    end;
    return;
end;
if nargin == 3
    switch instructionString
        case 'get'
            if isfield(objectIn,fieldName)
                mSubstrate = eval(['objectIn.' fieldName]);
            else
                disp([fieldName ' is not in the input object.'])
                mSubstrate = [];
            end;
        case 'generate'
            switch fieldName
                case 'morphingTimeAxis'
                    if length(mSubstrate.temporaAnchorOfSpeakerA) ~= ...
                        length(mSubstrate.temporaAnchorOfSpeakerB) 
                        if (length(mSubstrate.temporaAnchorOfSpeakerA)*...
                        length(mSubstrate.temporaAnchorOfSpeakerB)) > 0
                        disp('Temporal anchors are inconsistent');
                        disp(['Speaker A:' num2str(length(mSubstrate.temporaAnchorOfSpeakerA)) ...
                            '  Speaker B:' num2str(length(mSubstrate.temporaAnchorOfSpeakerB))]);
                        return;
                        else
                            if length(mSubstrate.temporaAnchorOfSpeakerB) == 0
                                mSubstrate.temporaAnchorOfSpeakerB = mSubstrate.temporaAnchorOfSpeakerA;
                            else
                                mSubstrate.temporaAnchorOfSpeakerA = mSubstrate.temporaAnchorOfSpeakerB;
                            end;
                        end;
                    end;
                    morphingTimeBase = ...
                        generateCommonTimeAnchors3(mSubstrate,0.5);
                    mSubstrate.anchorOnMorphingTime = ...
                        morphingTimeBase.anchorOnMorphingTime;
                    mSubstrate.morphingTimeAxis = ...
                        morphingTimeBase.morphingTimeAxis;
                case 'realTimeAxis'
                    if ~isempty(objectIn.temporalMorphingRate)
                        realTimeBase = ...
                            generateMorphingRealTimeAxis(mSubstrate);
                        mSubstrate.realTimeBase = ...
                            realTimeBase;
                    else
                        disp('Morphing time series is empty!');
                    end;
                case 'morphedDisplayParameters'
                    if isfield(objectIn,'realTimeBase')
                        morphedParam = generateMorphedF0(mSubstrate);
                        mSubstrate.morphedDisplayF0 = morphedParam.f0morph;
                        mSubstrate.morphedDisplayRealTime = ...
                            morphedParam.temporalPosition;
                        mSubstrate.morphedDisplayspectrum = ...
                            morphedParam.spectrum;
                    else
                        disp('Realtime axes has to be generated first!');
                    end;
                otherwise
                    disp([fieldName ' is not in the input object.'])
                    mSubstrate = objectIn; % keep object intact
            end;
        otherwise
            disp([instructionString ' is not recognizable'])
            mSubstrate = [];
    end;
    return;
end;
if nargin == 4
    switch instructionString
        case 'set'
            if isfield(objectIn,fieldName)
                eval(['mSubstrate.' fieldName ' = fieldValue;']);
            else
                disp([fieldName ' is not in the input object.'])
                mSubstrate = objectIn; % keep object intact
            end;
        case 'generate'
            switch fieldName
                case 'morphingTimeAxis'
                    %disp(['arg ' num2str(fieldValue)])
                    if length(mSubstrate.temporaAnchorOfSpeakerA) ~= ...
                        length(mSubstrate.temporaAnchorOfSpeakerB)
                        if (length(mSubstrate.temporaAnchorOfSpeakerA)*...
                        length(mSubstrate.temporaAnchorOfSpeakerB)) > 0
                        disp('Temporal anchors are inconsistent');
                        disp(['Speaker A:' num2str(length(mSubstrate.temporaAnchorOfSpeakerA)) ...
                            '  Speaker B:' num2str(length(mSubstrate.temporaAnchorOfSpeakerB))]);
                        return;
                        else
                            if length(mSubstrate.temporaAnchorOfSpeakerB) == 0
                                mSubstrate.temporaAnchorOfSpeakerB = mSubstrate.temporaAnchorOfSpeakerA;
                            else
                                mSubstrate.temporaAnchorOfSpeakerA = mSubstrate.temporaAnchorOfSpeakerB;
                            end;
                        end;
                    end;
                    morphingTimeBase = ...
                        generateCommonTimeAnchors3(mSubstrate,fieldValue);
                    mSubstrate.anchorOnMorphingTime = ...
                        morphingTimeBase.anchorOnMorphingTime;
                    mSubstrate.morphingTimeAxis = ...
                        morphingTimeBase.morphingTimeAxis;
                otherwise
                    disp([fieldName ' is not in the input object.'])
                    mSubstrate = objectIn; % keep object intact
            end;
        otherwise
            disp([instructionString ' is not recognizable'])
            mSubstrate = objectIn; % keep object intact
    end;
end;
