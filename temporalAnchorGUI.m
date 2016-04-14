function varargout = temporalAnchorGUI(varargin)
% TEMPORALANCHORGUI M-file for temporalAnchorGUI.fig
%      TEMPORALANCHORGUI, by itself, creates a new TEMPORALANCHORGUI or
%      raises the existing
%      singleton*.
%
%      H = TEMPORALANCHORGUI returns the handle to a new TEMPORALANCHORGUI
%      or the handle to
%      the existing singleton*.
%
%      TEMPORALANCHORGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEMPORALANCHORGUI.M with the given input arguments.
%
%      TEMPORALANCHORGUI('Property','Value',...) creates a new TEMPORALANCHORGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before temporalAnchorGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to temporalAnchorGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help temporalAnchorGUI

% Last Modified by GUIDE v2.5 04-Feb-2011 22:12:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @temporalAnchorGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @temporalAnchorGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before temporalAnchorGUI is made visible.
function temporalAnchorGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to temporalAnchorGUI (see VARARGIN)

% Choose default command line output for temporalAnchorGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%--- user defined initialization
temporalAnchorGUIuserData = get(handles.temporalAnchorGUI,'userdata');

if ~isempty(temporalAnchorGUIuserData)
    mSubstrate = temporalAnchorGUIuserData;
    clear('temporalAnchorGUIuserData');% is this safe?
    temporalAnchorGUIuserData.mSubstrate = mSubstrate;
    temporalAnchorGUIuserData.creationDate = datestr(now,30);
    temporalAnchorGUIuserData.objectDirectory = pwd;
    temporalAnchorGUIuserData.objectFile = 'invokedByMorphingMenu';
else
    [file,path] = uigetfile('*.mat','Select file with STRAIGHT object.');
    if length(file) == 1 && length(path) == 1
        if file == 0 || path == 0
            disp('Load is cancelled!');
            return;
        end;
    end;
    %eval(['load ' path file ';']);
    load([path file]);
    temporalAnchorGUIuserData.mSubstrate = revisedData;
    temporalAnchorGUIuserData.objectDirectory = path;
    temporalAnchorGUIuserData.objectFile = file;
end;
temporalAnchorGUIuserData.currentHandles = handles;
temporalAnchorGUIuserData.currentKey = 'initial';
set(handles.temporalAnchorGUI,'userdata',temporalAnchorGUIuserData);
set(handles.temporalAnchorGUI,'KeyPressFcn',@keyPressCallBack);
set(handles.temporalAnchorGUI,'KeyReleaseFcn',@keyReleaseCallBack);
set(handles.temporalAnchorGUI,'WindowButtonMotionFcn',@defaultWindowMotionCallback);
set(handles.distanceMatrixAxis,'visible','off');
set(handles.pleaseWait,'visible','off');
%set(handles.timeAxisALabel,'visible','off');
%set(handles.timeAxisBLabel,'visible','off');
set(handles.locator,'visible','off');

%locateTopLeftOfGUI(Top,Left,GUIHandle)
TandemSTRAIGHThandler('locateTopLeftOfGUI',65,70,handles.temporalAnchorGUI);

setupDisplay(hObject,handles);
%updateViews(handles.temporalAnchorGUI,eventdata);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes temporalAnchorGUI wait for user response (see UIRESUME)
% uiwait(handles.temporalAnchorGUI);

%function GUIuserData = checkForTimeAnchors(inputArgument,handles,GUIuserData)
%return;

% --- Outputs from this function are returned to the command line.
function varargout = temporalAnchorGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function setupDisplay(hObject,handles)
%     temporalAnchorGUI: 354.0575
%         waveformAxisB: 385.0576
%            sgramAxisB: 380.0576
%            powerAxisB: 375.0579
%         waveformAxisA: 370.0576
%            sgramAxisA: 365.0575
%            powerAxisA: 360.0575
%    distanceMatrixAxis: 355.0575
%                output: 354.0575

set(handles.temporalAnchorGUI,'RendererMode','manual'); % for future use
%set(handles.temporalAnchorGUI,'Renderer','OpenGL'); % for future use
set(handles.temporalAnchorGUI,'Renderer','zBuffer'); % for future use
GUIuserData = get(handles.temporalAnchorGUI,'userdata');
mSubstrate = GUIuserData.mSubstrate;
fs = mSubstrate.samplintFrequency;
%---- spectrogram
sgramA = mSubstrate.STRAIGHTspectrogramOfSpeakerA;
sgramB = mSubstrate.STRAIGHTspectrogramOfSpeakerB;
timeA = mSubstrate.spectrogramTimeBaseOfSpeakerA;
timeB = mSubstrate.spectrogramTimeBaseOfSpeakerB;
dBsgramA = 10*log10(sgramA);
dBsgramB = 10*log10(sgramB);
maxSgramA = max(max(dBsgramA));
maxSgramB = max(max(dBsgramB));
subplot(handles.sgramAxisA);
set(handles.sgramAxisA,'drawmode','fast');
set(handles.sgramAxisA,'userdata',handles);
handles.sgramImageA = imagesc([timeA(1) timeA(end)],[0 fs/2],max(maxSgramA-80,dBsgramA));
axis([timeA(1) timeA(end) 0 5000]);
axis('xy');
set(handles.sgramImageA,'ButtonDownFcn',@sgramsButtonDownCallback);
set(handles.sgramImageA,'userdata',handles);
subplot(handles.sgramAxisB);
set(handles.sgramAxisB,'drawmode','fast');
set(handles.sgramAxisB,'userdata',handles);
handles.sgramImageB = imagesc([timeB(1) timeB(end)],[0 fs/2],max(maxSgramB-80,dBsgramB));
axis([timeB(1) timeB(end) 0 5000]);
axis('xy');
set(handles.sgramImageB,'ButtonDownFcn',@sgramsButtonDownCallback);
set(handles.sgramImageB,'userdata',handles);
%---- power plot
powerA = 10*log10(sum(sgramA));
powerB = 10*log10(sum(sgramB));
subplot(handles.powerAxisA);
handles.powerPlotA = plot(timeA,powerA);grid on;
axis([timeA(1) timeA(end) max(powerA)+[-60 +5]]);
title('speaker A','fontsize',17);
%set(handles.powerPlotA,'ButtonDownFcn',@sgramsButtonDownCallback);
%set(handles.powerPlotA,'userdata',handles);
GUIuserData.mSubstrate = checkAndGenerateTimeAnchors(handles,mSubstrate);
timeAnchorHandleA = displayTimeAnchorOnSgram(handles,GUIuserData.mSubstrate,'A');
subplot(handles.powerAxisB);
handles.powerPlotB = plot(timeB,powerB);grid on;
axis([timeB(1) timeB(end) max(powerB)+[-60 +5]]);
title('speaker B','fontsize',17);
%set(handles.powerPlotB,'ButtonDownFcn',@sgramsButtonDownCallback);
%set(handles.powerPlotB,'userdata',handles);
timeAnchorHandleB = displayTimeAnchorOnSgram(handles,GUIuserData.mSubstrate,'B');
%set(handles.powerAxisB,'linewidth',2);
%---- waveform plot
waveA = mSubstrate.waveformForSpeakerA;
waveB = mSubstrate.waveformForSpeakerB;
timeBaseOFWaveA = (1:length(waveA))/fs;
timeBaseOFWaveB = (1:length(waveB))/fs;
subplot(handles.waveformAxisA);
handles.waveformPlotA = plot(timeBaseOFWaveA,waveA);grid on;
axis([timeBaseOFWaveA(1) timeBaseOFWaveA(end) 1.05*[min(waveA) max(waveA)]]);
%set(handles.waveformAxisA,'ButtonDownFcn',@sgramsButtonDownCallback);
%set(handles.waveformAxisA,'userdata',handles);
xlabel('Time axis A (s)','fontsize',17);
subplot(handles.waveformAxisB);
handles.waveformPlotB = plot(timeBaseOFWaveB,waveB);grid on;
axis([timeBaseOFWaveB(1) timeBaseOFWaveB(end) 1.05*[min(waveB) max(waveB)]]);
%set(handles.waveformAxisB,'ButtonDownFcn',@sgramsButtonDownCallback);
%set(handles.waveformAxisA,'userdata',handles);
xlabel('Time axis B (s)','fontsize',17);
set(handles.waveformAxisA,'userdata',handles);
set(handles.waveformAxisB,'userdata',handles);
%---- finalize
set(handles.waveformAxisA,'ButtonDownFcn',@waveformAxis_Callback);
set(handles.waveformAxisB,'ButtonDownFcn',@waveformAxis_Callback);
GUIuserData.timeAnchorHandleA = timeAnchorHandleA;
setTimeAnchorCallback(timeAnchorHandleA,handles);
GUIuserData.timeAnchorHandleB = timeAnchorHandleB;
setTimeAnchorCallback(timeAnchorHandleB,handles);
GUIuserData.currentTimeA = timeA(1);
GUIuserData.currentTimeB = timeB(1);
GUIuserData.currentHandles = handles;
set(handles.distanceSelectMenu,'visible','off');
%set(handles.finishButton,'enable','off');
set(handles.setUpButton,'enable','off');
set(handles.temporalAnchorGUI,'userdata',GUIuserData);
return;

function setTimeAnchorCallback(timeAnchorHandle,handles)
nAnchors = size(timeAnchorHandle,1);
for ii = 1:nAnchors
    set(timeAnchorHandle(ii),'ButtonDownFcn',@timeAnchorButtonDownCallback);
    set(timeAnchorHandle(ii),'userdata',handles);
end;
return;

function timeAnchorButtonDownCallback(src,evnt)
%axisHandle = get(src,'parent')
handles = get(src,'userdata');
GUIuserData = get(handles.temporalAnchorGUI,'userdata');
currentPoint = get(gca,'currentpoint');
if isfield(GUIuserData,'mappingPathHandle')
    timeA = get(GUIuserData.mappingPathHandle,'ydata');
    timeB = get(GUIuserData.mappingPathHandle,'xdata');
else
    timeBaseA = GUIuserData.mSubstrate.f0TimeBaseOfSpeakerA;
    timeBaseB = GUIuserData.mSubstrate.f0TimeBaseOfSpeakerB;
    timeA = GUIuserData.mSubstrate.temporaAnchorOfSpeakerA;
    timeB = GUIuserData.mSubstrate.temporaAnchorOfSpeakerB;
    timeA = [timeBaseA(1);timeA;timeBaseA(end)];
    timeB = [timeBaseB(1);timeB;timeBaseB(end)];
end;
switch gca
    case handles.sgramAxisA
        GUIuserData.speakerID = 'A';
        GUIuserData.currentTimeA = currentPoint(1,1);
        [dmy,indexA] = min(abs(timeA-currentPoint(1,1)));
        GUIuserData.timeAnchorID = indexA;
    case handles.sgramAxisB
        GUIuserData.speakerID = 'B';
        GUIuserData.currentTimeB = currentPoint(1,1);
        [dmy,indexB] = min(abs(timeB-currentPoint(1,1)));
        GUIuserData.timeAnchorID = indexB;
    otherwise
        disp('Where am I?');
        return;
end;
set(GUIuserData.timeAnchorHandleA(GUIuserData.timeAnchorID),'linewidth',3);
set(GUIuserData.timeAnchorHandleB(GUIuserData.timeAnchorID),'linewidth',3);
set(handles.temporalAnchorGUI,'WindowButtonMotionFcn',@timeAnchorMotionCallback);
set(handles.temporalAnchorGUI,'WindowButtonUpFcn',@timeAnchorUpCallback);
set(handles.temporalAnchorGUI,'userdata',GUIuserData);
return;

function timeAnchorUpCallback(src,evnt)
GUIuserData = get(src,'userdata');
handles = GUIuserData.currentHandles;
set(GUIuserData.timeAnchorHandleA(GUIuserData.timeAnchorID),'linewidth',1);
set(GUIuserData.timeAnchorHandleB(GUIuserData.timeAnchorID),'linewidth',1);
set(handles.temporalAnchorGUI,'WindowButtonMotionFcn',@defaultWindowMotionCallback);
set(handles.temporalAnchorGUI,'WindowButtonUpFcn','');
set(handles.temporalAnchorGUI,'userdata',GUIuserData);
defaultWindowMotionCallback(src,evnt);
return;

function timeAnchorMotionCallback(src,evnt)
GUIuserData = get(src,'userdata');
handles = GUIuserData.currentHandles;
if isfield(GUIuserData,'mappingPathHandle')
    timeA = get(GUIuserData.mappingPathHandle,'ydata');
    timeB = get(GUIuserData.mappingPathHandle,'xdata');
else
    timeBaseOfA = GUIuserData.mSubstrate.f0TimeBaseOfSpeakerA;
    timeBaseOfB = GUIuserData.mSubstrate.f0TimeBaseOfSpeakerB;
    timeA = GUIuserData.mSubstrate.temporaAnchorOfSpeakerA;
    timeB = GUIuserData.mSubstrate.temporaAnchorOfSpeakerB;
    timeA = [timeBaseOfA(1);timeA;timeBaseOfA(end)];
    timeB = [timeBaseOfB(1);timeB;timeBaseOfB(end)];
end;
switch GUIuserData.speakerID
    case 'A'
        axisHandle = handles.sgramAxisA;
        anchorHandle = GUIuserData.timeAnchorHandleA;
    case 'B'
        axisHandle = handles.sgramAxisB;
        anchorHandle = GUIuserData.timeAnchorHandleB;
    otherwise
        return;
end;
currentPoint = get(axisHandle,'currentpoint');
set(anchorHandle(GUIuserData.timeAnchorID),'xdata',[1 1]*currentPoint(1,1));
if isfield(GUIuserData,'mappingPathHandle')
switch GUIuserData.speakerID
    case 'A'
        timeA(GUIuserData.timeAnchorID) = currentPoint(1,1);
    case 'B'
        timeB(GUIuserData.timeAnchorID) = currentPoint(1,1);
end;
set(GUIuserData.mappingPathHandle,'ydata',timeA,'xdata',timeB);
set(GUIuserData.smallMappingPathHandle,'ydata',timeA,'xdata',timeB);
end;
set(src,'userdata',GUIuserData);
return;

function timeAnchorHandle = displayTimeAnchorOnSgram(handles,mSubstrate,speakerID)
timeA = mSubstrate.spectrogramTimeBaseOfSpeakerA;
timeB = mSubstrate.spectrogramTimeBaseOfSpeakerB;
switch speakerID
    case {'A','B'}
        displayAxis = eval(['handles.sgramAxis' speakerID]);
    otherwise
        return;
end;
timeAnchorHandle = [];
subplot(displayAxis);
if isfield(mSubstrate,'temporaAnchorOfSpeakerA') &&...
        isfield(mSubstrate,'temporaAnchorOfSpeakerB')
    if length(mSubstrate.temporaAnchorOfSpeakerA) == ...
            length(mSubstrate.temporaAnchorOfSpeakerB)
        if length(mSubstrate.temporaAnchorOfSpeakerA) > 1
            switch speakerID
                case 'A'
                    xdata = [timeA(1);mSubstrate.temporaAnchorOfSpeakerA(:);timeA(end)];
                case 'B'
                    xdata = [timeB(1);mSubstrate.temporaAnchorOfSpeakerB(:);timeB(end)];
            end;
            nData = length(xdata);
            hold on
            timeAnchorHandle = plot([xdata xdata]',[zeros(1,nData);ones(1,nData)*5000],'ws-',...
                'linewidth',1,'markersize',7);
            hold off
        end;
    end;
end;
return;

function mSubstrate = checkAndGenerateTimeAnchors(handles,mSubstrate)
GUIuserData = get(handles.temporalAnchorGUI,'userdata');
timeA = mSubstrate.spectrogramTimeBaseOfSpeakerA;
timeB = mSubstrate.spectrogramTimeBaseOfSpeakerB;
morphingTimeAxis = [(timeA(1)+timeB(1))/2:0.005:(timeA(end)+timeB(end))/2]';
fs = mSubstrate.samplintFrequency;
if ~isfield(mSubstrate,'temporaAnchorOfSpeakerA') ||...
        ~isfield(mSubstrate,'temporaAnchorOfSpeakerB')
    mSubstrate.temporaAnchorOfSpeakerA = ...
        [(2*timeA(1)+timeA(end))/3;(timeA(1)+2*timeA(end))/3];
    mSubstrate.temporaAnchorOfSpeakerB = ...
        [(2*timeB(1)+timeB(end))/3;(timeB(1)+2*timeB(end))/3];
    mSubstrate.frequencyAnchorOfSpeakerA = ...
        generateDefaultFrequencyAnchorStructure(2,fs);
    mSubstrate.frequencyAnchorOfSpeakerB = ...
        generateDefaultFrequencyAnchorStructure(2,fs);
    mSubstrate.anchorOnMorphingTime = ...
        (mSubstrate.temporaAnchorOfSpeakerA+mSubstrate.temporaAnchorOfSpeakerB)/2;
    mSubstrate.morphingTimeAxis = morphingTimeAxis;
    mSubstrate.temporalMorphingRate = ...
        generateDefaultTemporalMorphingRate(morphingTimeAxis);
elseif length(mSubstrate.temporaAnchorOfSpeakerA) <2
    mSubstrate.temporaAnchorOfSpeakerA = ...
        [(2*timeA(1)+timeA(end))/3;(timeA(1)+2*timeA(end))/3];
    mSubstrate.temporaAnchorOfSpeakerB = ...
        [(2*timeB(1)+timeB(end))/3;(timeB(1)+2*timeB(end))/3];
    mSubstrate.frequencyAnchorOfSpeakerA = ...
        generateDefaultFrequencyAnchorStructure(2,fs);
    mSubstrate.frequencyAnchorOfSpeakerB = ...
        generateDefaultFrequencyAnchorStructure(2,fs);
    mSubstrate.anchorOnMorphingTime = ...
        (mSubstrate.temporaAnchorOfSpeakerA+mSubstrate.temporaAnchorOfSpeakerB)/2;
    mSubstrate.morphingTimeAxis = morphingTimeAxis;
    mSubstrate.temporalMorphingRate = ...
        generateDefaultTemporalMorphingRate(morphingTimeAxis);
else
    return;
end;
return;

function temporalMorphingRate = ...
    generateDefaultTemporalMorphingRate(morphingTimeAxis)
temporalMorphingRate.time = morphingTimeAxis*0+0.5;
temporalMorphingRate.F0 = morphingTimeAxis*0+0.5;
temporalMorphingRate.frequency = morphingTimeAxis*0+0.5;
temporalMorphingRate.spectrum = morphingTimeAxis*0+0.5;
temporalMorphingRate.aperiodicity = morphingTimeAxis*0+0.5;
return;

function frequencyAnchor = ...
    generateDefaultFrequencyAnchorStructure(nTime,fs)
nFrequency = floor((fs/2+500)/100);
frequencyAnchor.frequency = zeros(nTime,nFrequency);
frequencyAnchor.counts = zeros(nTime,1);
for ii = 1:nTime
    frequencyAnchor.frequency(ii,:) = (1:nFrequency)*1000 - 550;
end;
return;

function waveformAxis_Callback(src,evnt)
handles = get(src,'userdata');
%handles = axisUserData.currentHandles;
GUIuserData = get(handles.temporalAnchorGUI,'userdata');
currentPoint = get(src,'currentPoint');
switch src
    case handles.waveformAxisA
        GUIuserData.currentTimeA = currentPoint(1,1);
        GUIuserData.currentTimeB = [];
        GUIuserData.currentTime = 'A';
    case handles.waveformAxisB
        GUIuserData.currentTimeB = currentPoint(1,1);
        GUIuserData.currentTimeA = [];
        GUIuserData.currentTime = 'B';
end;
set(handles.temporalAnchorGUI,'userdata',GUIuserData);
updateViews(handles.temporalAnchorGUI,evnt);
return;

function updateViews(src,evnt)
GUIuserData = get(src,'userdata');
handles = GUIuserData.currentHandles;
switch GUIuserData.currentKey
    case 'shift'
        scalingFactor = sqrt(2);
    case 'initial'
        scalingFactor = 1;
        GUIuserData.currentKey = 'none';
        set(src,'userdata',GUIuserData);
    otherwise
        scalingFactor = 1/sqrt(2);
end;
if ~isempty(GUIuserData.currentTimeA)
    timeA = GUIuserData.currentTimeA;
    xlim = get(handles.waveformAxisA,'xlim');
    xlimAUpdate = (xlim-timeA)*scalingFactor+timeA;
    xlim = get(handles.waveformAxisB,'xlim');
    xlimBUpdate = (xlim-sum(xlim)/2)*scalingFactor+sum(xlim)/2;
elseif ~isempty(GUIuserData.currentTimeB)
    timeB = GUIuserData.currentTimeB;
    xlim = get(handles.waveformAxisB,'xlim');
    xlimBUpdate = (xlim-timeB)*scalingFactor+timeB;
    xlim = get(handles.waveformAxisA,'xlim');
    xlimAUpdate = (xlim-sum(xlim)/2)*scalingFactor+sum(xlim)/2;
end;
xlimAUpdate = adjustLimit(xlimAUpdate,handles.waveformPlotA);
xlimBUpdate = adjustLimit(xlimBUpdate,handles.waveformPlotB);
drawUpdatedViews(handles,xlimAUpdate,xlimBUpdate)
return;


function xlimUpdate = adjustLimit(xlimUpdate,plotHandle)
xdata = get(plotHandle,'xdata');
if xdata(1) > xlimUpdate(1)
    xlimUpdate = xlimUpdate-xlimUpdate(1)+xdata(1);
elseif xdata(end) < xlimUpdate(2)
    xlimUpdate = xlimUpdate-xlimUpdate(2)+xdata(end);
end;
if (xdata(end)-xdata(1)) < diff(xlimUpdate)
    xlimUpdate = [xdata(1) xdata(end)];
end;
return;

function GUIuserData = showDistanceMartix(GUIuserData,handles)
switch get(gcf,'tag')
    case 'temporalAnchorGUI'
    otherwise
        figure(handles.temporalAnchorGUI);
end;
set(handles.distanceMatrixAxis,'visible','on');
set(handles.locator,'visible','on');
subplot(handles.distanceMatrixAxis);
set(handles.distanceMatrixAxis,'drawmode','fast');
distanceMatrix = GUIuserData.distanceMatrix;
mSubstrate = GUIuserData.mSubstrate;
timeA = mSubstrate.spectrogramTimeBaseOfSpeakerA;
timeB = mSubstrate.spectrogramTimeBaseOfSpeakerB;
mapImage = surface(timeB,timeA,distanceMatrix);
%set(mapImage,'linestyle','none');
set(handles.distanceMatrixAxis,'xlim',[timeB(1) timeB(end)], ...
    'ylim',[timeA(1) timeA(end)]);
shading interp
set(mapImage,'FaceLighting','phong');
hold on
regionHandle = plot3([timeB(1) timeB(end) timeB(end) timeB(1) timeB(1)],...
    [timeA(1) timeA(1) timeA(end) timeA(end) timeA(1)],...
    [1 1 1 1 1]*3,'k','linewidth',4);
if isfield(mSubstrate,'temporaAnchorOfSpeakerA') &&...
        isfield(mSubstrate,'temporaAnchorOfSpeakerB')
    if length(mSubstrate.temporaAnchorOfSpeakerA) == ...
            length(mSubstrate.temporaAnchorOfSpeakerB)
        if length(mSubstrate.temporaAnchorOfSpeakerA) > 1
            zData = ones(length(mSubstrate.temporaAnchorOfSpeakerA)+2,1)*2.9;
            xdata = [timeB(1);mSubstrate.temporaAnchorOfSpeakerB(:);timeB(end)];
            ydata = [timeA(1);mSubstrate.temporaAnchorOfSpeakerA(:);timeA(end)];
            mappingPathHandle = ...
                plot3(xdata,ydata,zData,'wo-','linewidth',2,...
                'MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',10);
        end;
    end;
end;
hold off
axis('xy');
axis('square')
axis off
view(atan((timeB(end)-timeB(1))/(timeA(end)-timeA(1)))/pi*180,90);
set(handles.distanceMatrixAxis,'xlim',[timeB(1) timeB(end)], ...
    'ylim',[timeA(1) timeA(end)]);
timeBLabel = text(0.4*timeB(1)+0.6*timeB(end),timeA(1),3.3,'Time axis B ----',...
    'fontsize',20,'HorizontalAlignment','right');
timeALabel = text(timeB(1),0.4*timeA(1)+0.6*timeA(end),3.3,'Time axis A ----',...
    'fontsize',20,'HorizontalAlignment','right');
%set(handles.timeAxisALabel,'visible','on');
%set(handles.timeAxisBLabel,'visible','on');
%--- show locator
subplot(handles.locator);
set(handles.locator,'drawmode','fast');
locatorImage = surface(timeB,timeA,distanceMatrix);
%set(locatorImage,'linestyle','none');
shading interp
set(locatorImage,'FaceLighting','phong');
hold on
locatorHandle = plot3([timeB(1) timeB(end) timeB(end) timeB(1) timeB(1)],...
    [timeA(1) timeA(1) timeA(end) timeA(end) timeA(1)],...
    [1 1 1 1 1]*3,'m','linewidth',4,'clipping','off');
plot3([timeB(1) timeB(end) timeB(end) timeB(1) timeB(1)],...
    [timeA(1) timeA(1) timeA(end) timeA(end) timeA(1)],...
    [1 1 1 1 1]*2,'k','linewidth',3,'clipping','off');
if isfield(mSubstrate,'temporaAnchorOfSpeakerA') &&...
        isfield(mSubstrate,'temporaAnchorOfSpeakerB')
    if length(mSubstrate.temporaAnchorOfSpeakerA) == ...
            length(mSubstrate.temporaAnchorOfSpeakerB)
        if length(mSubstrate.temporaAnchorOfSpeakerA) > 1
            zData = ones(length(mSubstrate.temporaAnchorOfSpeakerA)+2,1)*2.9;
            xdata = [timeB(1);mSubstrate.temporaAnchorOfSpeakerB(:);timeB(end)];
            ydata = [timeA(1);mSubstrate.temporaAnchorOfSpeakerA(:);timeA(end)];
            smallMappingPathHandle = plot3(xdata,ydata,zData,'w','linewidth',3);
        end;
    end;
end;
hold off
axis([timeB(1) timeB(end) timeA(1) timeA(end)]);
axis('xy');
axis('square')
axis('tight')
view(atan((timeB(end)-timeB(1))/(timeA(end)-timeA(1)))/pi*180,90);
axis off
%view(45,90);
%set(locatorHandle,'clipping','off');
set(mapImage,'userdata',handles);
set(locatorHandle,'userdata',handles);
set(locatorImage,'userdata',handles);
set(smallMappingPathHandle,'userdata',handles);
%set(locatorImage,'visible','off');
%-- finalize
GUIuserData.mapImage = mapImage;
GUIuserData.locatorImage = locatorImage;
GUIuserData.regionHandle = regionHandle;
GUIuserData.locatorHandle = locatorHandle;
GUIuserData.timeALabel = timeALabel;
GUIuserData.timeBLabel = timeBLabel;
GUIuserData.mappingPathHandle = mappingPathHandle;
set(GUIuserData.mappingPathHandle,'ButtonDownFcn',@mappingHandleButtonDownCallback);
set(GUIuserData.mappingPathHandle,'userdata',handles);
GUIuserData.smallMappingPathHandle = smallMappingPathHandle;
return;

function mappingHandleButtonDownCallback(src,evnt)
axisHandle = get(src,'parent');
if ~isInsidePlot(axisHandle,'axis')
    return;
end;
handles = get(src,'userdata');
currentPoint = get(axisHandle,'currentPoint');
GUIuserData = get(handles.temporalAnchorGUI,'userdata');
xdata = get(src,'xdata');
ydata = get(src,'ydata');
[dmy,indexMin] = min((xdata-currentPoint(1,1)).^2+(ydata-currentPoint(1,2)).^2);
GUIuserData.timeAnchorID = indexMin;
GUIuserData.currentTimeA = currentPoint(1,2); % Y is for A
GUIuserData.currentTimeB = currentPoint(1,1); % X is for B
if closeToLineNode(GUIuserData.mappingPathHandle) < 5
    switch GUIuserData.currentKey
        case 'shift'
            if length(xdata) > 4
                deleteAnchorPoint(GUIuserData.mappingPathHandle,currentPoint,handles);
            end;
            return;
        case 'alt'
            set(GUIuserData.timeAnchorHandleA(GUIuserData.timeAnchorID),'linewidth',3);
            set(GUIuserData.timeAnchorHandleB(GUIuserData.timeAnchorID),'linewidth',3);
            GUIuserData.currentFocusID = GUIuserData.timeAnchorID;
            set(handles.temporalAnchorGUI,'userdata',GUIuserData);
            frequencyAnchorGUIHandle = ...
                frequencyAnchorPointGUI('userData',GUIuserData.currentHandles);
            %disp('node clicked while alt pressed');
            GUIuserData.frequencyAnchorGUIHandle = frequencyAnchorGUIHandle;
        otherwise
            set(handles.temporalAnchorGUI,'WindowButtonMotionFcn',@mappingPathMotionCallback);
            set(handles.temporalAnchorGUI,'WindowButtonUpFcn',@mappingPathButtonUpCallback);
            set(GUIuserData.timeAnchorHandleA(GUIuserData.timeAnchorID),'linewidth',3);
            set(GUIuserData.timeAnchorHandleB(GUIuserData.timeAnchorID),'linewidth',3);
    end
else
    addAnchorPoint(GUIuserData.mappingPathHandle,currentPoint,handles);
    return;
end;
set(handles.temporalAnchorGUI,'userdata',GUIuserData);
return;

function deleteAnchorPoint(mappingPathHandle,currentPoint,handles)
GUIuserData = get(handles.temporalAnchorGUI,'userdata');
timeAdata = get(mappingPathHandle,'ydata');
timeBdata = get(mappingPathHandle,'xdata');
zdata = get(mappingPathHandle,'zdata');
[dmy,indexMin] = min((timeAdata-currentPoint(1,2)).^2+(timeBdata-currentPoint(1,1)).^2);
indexMin = max(2,min(indexMin,length(timeAdata)-1)); % safe guard for edge data elimination
sequenceList = 1:length(timeAdata);
newTimeAdata = timeAdata(sequenceList(sequenceList~=indexMin));
newTimeBdata = timeBdata(sequenceList(sequenceList~=indexMin));
if isfield(GUIuserData.mSubstrate,'anchorOnMorphingTime')
    GUIuserData.mSubstrate.anchorOnMorphingTime = ...
        GUIuserData.mSubstrate.anchorOnMorphingTime(sequenceList(2:end-1)~=indexMin-1);
end;
newZdata = zdata(1:end-1);
set(GUIuserData.mappingPathHandle,...
    'xdata',newTimeBdata,'ydata',newTimeAdata,'zdata',newZdata);
set(GUIuserData.smallMappingPathHandle,...
    'xdata',newTimeBdata,'ydata',newTimeAdata,'zdata',newZdata);
%--- delete frequency anchor information
mSubstrate = GUIuserData.mSubstrate;
mSubstrate.temporaAnchorOfSpeakerA = newTimeAdata(2:end-1);
mSubstrate.temporaAnchorOfSpeakerA = ...
    mSubstrate.temporaAnchorOfSpeakerA(:);
mSubstrate.temporaAnchorOfSpeakerB = newTimeBdata(2:end-1);
mSubstrate.temporaAnchorOfSpeakerB = ...
    mSubstrate.temporaAnchorOfSpeakerB(:);
dataList = sequenceList(sequenceList~=indexMin)-1;
mSubstrate.frequencyAnchorOfSpeakerA.frequency = ...
    mSubstrate.frequencyAnchorOfSpeakerA.frequency(dataList(2:end-1),:);
mSubstrate.frequencyAnchorOfSpeakerA.counts = ...
    mSubstrate.frequencyAnchorOfSpeakerA.counts(dataList(2:end-1));
mSubstrate.frequencyAnchorOfSpeakerB.frequency = ...
    mSubstrate.frequencyAnchorOfSpeakerB.frequency(dataList(2:end-1),:);
mSubstrate.frequencyAnchorOfSpeakerB.counts = ...
    mSubstrate.frequencyAnchorOfSpeakerB.counts(dataList(2:end-1));
GUIuserData.mSubstrate = mSubstrate;
set(handles.temporalAnchorGUI,'userdata',GUIuserData);
%--- update time anchor views
replaceTimeAnchors(handles,newTimeAdata,newTimeBdata);
return

function mappingPathButtonUpCallback(src,evnt)
GUIuserData = get(src,'userdata');
handles = GUIuserData.currentHandles;
set(handles.temporalAnchorGUI,'WindowButtonMotionFcn',@defaultWindowMotionCallback);
set(handles.temporalAnchorGUI,'WindowButtonUpFcn','');
set(GUIuserData.timeAnchorHandleA(GUIuserData.timeAnchorID),'linewidth',1);
set(GUIuserData.timeAnchorHandleB(GUIuserData.timeAnchorID),'linewidth',1);
%GUIuserData.mSubstrate.frequencyAnchorOfSpeakerA
return;

function mappingPathMotionCallback(src,evnt)
GUIuserData = get(src,'userdata');
handles = GUIuserData.currentHandles;
axisHandle = handles.distanceMatrixAxis;
currentPoint = get(axisHandle,'currentPoint');
xdata = get(GUIuserData.mappingPathHandle,'xdata');
ydata = get(GUIuserData.mappingPathHandle,'ydata');
if (GUIuserData.timeAnchorID > 1) && (GUIuserData.timeAnchorID < length(xdata))
    xdata(GUIuserData.timeAnchorID) = currentPoint(1,1);
    ydata(GUIuserData.timeAnchorID) = currentPoint(1,2);
    set(GUIuserData.mappingPathHandle,'xdata',xdata,'ydata',ydata);
    set(GUIuserData.smallMappingPathHandle,'xdata',xdata,'ydata',ydata);
    GUIuserData.mSubstrate.temporaAnchorOfSpeakerA = ydata(2:end-1);
    GUIuserData.mSubstrate.temporaAnchorOfSpeakerA = ...
        GUIuserData.mSubstrate.temporaAnchorOfSpeakerA(:);
    GUIuserData.mSubstrate.temporaAnchorOfSpeakerB = xdata(2:end-1);
    GUIuserData.mSubstrate.temporaAnchorOfSpeakerB = ...
        GUIuserData.mSubstrate.temporaAnchorOfSpeakerB(:);
    timeA = get(GUIuserData.timeAnchorHandleA(GUIuserData.timeAnchorID),'xdata');
    timeB = get(GUIuserData.timeAnchorHandleB(GUIuserData.timeAnchorID),'xdata');
    set(GUIuserData.timeAnchorHandleA(GUIuserData.timeAnchorID),...
        'xdata',timeA*0+currentPoint(1,2));
    set(GUIuserData.timeAnchorHandleB(GUIuserData.timeAnchorID),...
        'xdata',timeB*0+currentPoint(1,1));
    set(src,'userdata',GUIuserData);
end;
return;

function addAnchorPoint(mappingPathHandle,currentPoint,handles)
GUIuserData = get(handles.temporalAnchorGUI,'userdata');
timeAdata = get(mappingPathHandle,'ydata');
timeBdata = get(mappingPathHandle,'xdata');
zdata = get(mappingPathHandle,'zdata');
[newTimeAdata,indexSorted] = sort([timeAdata(:);currentPoint(1,2)]);
newTimeBdata = [timeBdata(:);currentPoint(1,1)];
newTimeBdata = newTimeBdata(indexSorted);
newZdata = [zdata(:);zdata(1)];
if isfield(GUIuserData.mSubstrate,'anchorOnMorphingTime')
    %filler = (currentPoint(1,1)+currentPoint(1,2))/2;
    %filler1 = GUIuserData.mSubstrate.morphingTimeAxis(1);
    %filler2 = GUIuserData.mSubstrate.morphingTimeAxis(end);
    %GUIuserData.mSubstrate.anchorOnMorphingTime = ...
    %    [filler1;GUIuserData.mSubstrate.anchorOnMorphingTime;filler2;filler];
    %GUIuserData.mSubstrate.anchorOnMorphingTime = ...
    %    GUIuserData.mSubstrate.anchorOnMorphingTime(indexSorted);
    %figure;plot(GUIuserData.mSubstrate.anchorOnMorphingTime,'o-');
    %GUIuserData.mSubstrate.anchorOnMorphingTime = ...
    %    GUIuserData.mSubstrate.anchorOnMorphingTime(2:end-1);
    GUIuserData.mSubstrate.anchorOnMorphingTime = ...
        (newTimeAdata(2:end-1)+newTimeBdata(2:end-1))/2;
end;
set(GUIuserData.mappingPathHandle,...
    'xdata',newTimeBdata,'ydata',newTimeAdata,'zdata',newZdata);
set(GUIuserData.smallMappingPathHandle,...
    'xdata',newTimeBdata,'ydata',newTimeAdata,'zdata',newZdata);
%--- delete frequency anchor information
mSubstrate = GUIuserData.mSubstrate;
mSubstrate.temporaAnchorOfSpeakerA = newTimeAdata(2:end-1);
mSubstrate.temporaAnchorOfSpeakerA = mSubstrate.temporaAnchorOfSpeakerA(:);
mSubstrate.temporaAnchorOfSpeakerB = newTimeBdata(2:end-1);
mSubstrate.temporaAnchorOfSpeakerB = mSubstrate.temporaAnchorOfSpeakerB(:);

nTime = size(mSubstrate.frequencyAnchorOfSpeakerA.frequency,1);
frequency = [mSubstrate.frequencyAnchorOfSpeakerA.frequency(1,:);...
    mSubstrate.frequencyAnchorOfSpeakerA.frequency;...
    mSubstrate.frequencyAnchorOfSpeakerA.frequency(nTime,:);...
    mSubstrate.frequencyAnchorOfSpeakerA.frequency(1,:)];
mSubstrate.frequencyAnchorOfSpeakerA.frequency = frequency(indexSorted(2:end-1),:);
counts = [0;mSubstrate.frequencyAnchorOfSpeakerA.counts;0;0];
mSubstrate.frequencyAnchorOfSpeakerA.counts = counts(indexSorted(2:end-1));

frequency = [mSubstrate.frequencyAnchorOfSpeakerB.frequency(1,:);...
    mSubstrate.frequencyAnchorOfSpeakerB.frequency;...
    mSubstrate.frequencyAnchorOfSpeakerB.frequency(nTime,:);...
    mSubstrate.frequencyAnchorOfSpeakerB.frequency(1,:)];
mSubstrate.frequencyAnchorOfSpeakerB.frequency = frequency(indexSorted(2:end-1),:);
counts = [0;mSubstrate.frequencyAnchorOfSpeakerB.counts;0;0];
mSubstrate.frequencyAnchorOfSpeakerB.counts = counts(indexSorted(2:end-1));

%dataList = sequenceList(sequenceList~=indexMin)-1;
%mSubstrate.frequencyAnchorOfSpeakerA.frequency = ...
%    mSubstrate.frequencyAnchorOfSpeakerA.frequency(dataList(2:end-1),:);
%mSubstrate.frequencyAnchorOfSpeakerA.counts = ...
%    mSubstrate.frequencyAnchorOfSpeakerA.counts(dataList(2:end-1));
%mSubstrate.frequencyAnchorOfSpeakerB.frequency = ...
%    mSubstrate.frequencyAnchorOfSpeakerB.frequency(dataList(2:end-1),:);
%mSubstrate.frequencyAnchorOfSpeakerB.counts = ...
%    mSubstrate.frequencyAnchorOfSpeakerB.counts(dataList(2:end-1));

GUIuserData.mSubstrate = mSubstrate;
set(handles.temporalAnchorGUI,'userdata',GUIuserData);
%--- update time anchor views
replaceTimeAnchors(handles,newTimeAdata,newTimeBdata);
return

function replaceTimeAnchors(handles,newTimeAdata,newTimeBdata)
GUIuserData = get(handles.temporalAnchorGUI,'userdata');
GUIuserData.mSubstrate.temporaAnchorOfSpeakerA = newTimeAdata(2:end-1);
GUIuserData.mSubstrate.temporaAnchorOfSpeakerA = ...
    GUIuserData.mSubstrate.temporaAnchorOfSpeakerA(:);
GUIuserData.mSubstrate.temporaAnchorOfSpeakerB = newTimeBdata(2:end-1);
GUIuserData.mSubstrate.temporaAnchorOfSpeakerB = ...
    GUIuserData.mSubstrate.temporaAnchorOfSpeakerB(:);
eraseAnchors(GUIuserData.timeAnchorHandleA);
eraseAnchors(GUIuserData.timeAnchorHandleB);
GUIuserData = rmfield(GUIuserData,'timeAnchorHandleA');
GUIuserData = rmfield(GUIuserData,'timeAnchorHandleB');
set(handles.temporalAnchorGUI,'userdata',GUIuserData);
timeAnchorHandleA = ...
    displayTimeAnchorOnSgram(handles,GUIuserData.mSubstrate,'A');
timeAnchorHandleB = ...
    displayTimeAnchorOnSgram(handles,GUIuserData.mSubstrate,'B');
GUIuserData.timeAnchorHandleA = timeAnchorHandleA;
setTimeAnchorCallback(timeAnchorHandleA,handles);
GUIuserData.timeAnchorHandleB = timeAnchorHandleB;
setTimeAnchorCallback(timeAnchorHandleB,handles);
set(handles.temporalAnchorGUI,'userdata',GUIuserData);
return;

function eraseAnchors(anchorHandle)
nAnchors = size(anchorHandle,1);
for ii = 1:nAnchors
    delete(anchorHandle(ii));
end;
return;

% --- Executes on button press in distanceMatrixButton.
function distanceMatrixButton_Callback(hObject, eventdata, handles)
% hObject    handle to distanceMatrixButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
temporalAnchorGUIuserData = get(handles.temporalAnchorGUI,'userdata');
set(handles.pleaseWait,'visible','on');
set(handles.distanceMatrixButton,'visible','off');
set(handles.temporalAnchorGUI,'pointer','watch');
drawnow;
contents = get(handles.distanceSelectMenu,'String');
temporalAnchorGUIuserData.distanceMatrix = ...
    calculateDistanceMatrix(temporalAnchorGUIuserData.mSubstrate,...
    contents{get(handles.distanceSelectMenu,'Value')});
%shiftInvariant1
set(handles.temporalAnchorGUI,'pointer','arrow');
drawnow;
temporalAnchorGUIuserData = showDistanceMartix(temporalAnchorGUIuserData,handles);
set(temporalAnchorGUIuserData.mapImage,'ButtonDownFcn',@distanceMapButtonDnFcn);
set(temporalAnchorGUIuserData.locatorHandle,'ButtonDownFcn',@locatorButtonDnFcn);
set(temporalAnchorGUIuserData.locatorImage,'ButtonDownFcn',@smallMapButtonDnFcn);
set(temporalAnchorGUIuserData.smallMappingPathHandle,'ButtonDownFcn',@smallMapButtonDnFcn);
set(handles.pleaseWait,'visible','off');
set(handles.temporalAnchorGUI,'WindowButtonMotionFcn',@defaultWindowMotionCallback);
temporalAnchorGUIuserData.currentKey = 'initial';
set(handles.distanceSelectMenu,'visible','on');
%set(handles.finishButton,'enable','on');
if isfield(temporalAnchorGUIuserData.mSubstrate,'menuHandle') && ...
        ishandle(temporalAnchorGUIuserData.mSubstrate.menuHandle)
    set(handles.setUpButton,'enable','on');
end;
set(handles.temporalAnchorGUI,'userdata',temporalAnchorGUIuserData);
updateViews(handles.temporalAnchorGUI,eventdata);
return;

function keyPressCallBack(src,evnt)
GUIuserData = get(src,'userdata');
%evnt.Key
GUIuserData.currentKey = evnt.Key;
set(src,'userdata',GUIuserData);
defaultWindowMotionCallback(src,evnt);
return;

function keyReleaseCallBack(src,evnt)
GUIuserData = get(src,'userdata');
GUIuserData.currentKey = 'none';
set(src,'userdata',GUIuserData);
defaultWindowMotionCallback(src,evnt);
return;

function sgramsButtonDownCallback(src,evnt)
handles = get(src,'userdata');
axisHandle = get(src,'parent');
GUIuserData = get(handles.temporalAnchorGUI,'userdata');
currentPoint = get(axisHandle,'currentpoint');
switch axisHandle
    case {handles.waveformAxisA,handles.sgramAxisA,handles.powerAxisA}
        GUIuserData.speakerID = 'A';
        GUIuserData.currentTimeA = currentPoint(1,1);
    case {handles.waveformAxisB,handles.sgramAxisB,handles.powerAxisB}
        GUIuserData.speakerID = 'B';
        GUIuserData.currentTimeB = currentPoint(1,1);
    otherwise
        return;
end;
set(handles.temporalAnchorGUI,'WindowButtonMotionFcn',@sgramsButtonMotionCallback);
set(handles.temporalAnchorGUI,'WindowButtonUpFcn',@sgramsButtonUpCallback);
set(handles.temporalAnchorGUI,'userdata',GUIuserData);
return;

function sgramsButtonUpCallback(src,evnt)
GUIuserData = get(src,'userdata');
handles = GUIuserData.currentHandles;
set(handles.temporalAnchorGUI,'WindowButtonMotionFcn',@defaultWindowMotionCallback);
set(handles.temporalAnchorGUI,'WindowButtonUpFcn','');
set(handles.temporalAnchorGUI,'pointer','arrow');
defaultWindowMotionCallback(src,evnt);
return;

function sgramsButtonMotionCallback(src,evnt)
GUIuserData = get(src,'userdata');
handles = GUIuserData.currentHandles;
switch GUIuserData.speakerID
    case 'A'
        currentpoint = get(handles.sgramAxisA,'currentpoint');
        displacementA = currentpoint(1,1)-GUIuserData.currentTimeA;
        displacementB = 0;
    case 'B'
        currentpoint = get(handles.sgramAxisB,'currentpoint');
        displacementA = 0;
        displacementB = currentpoint(1,1)-GUIuserData.currentTimeB;
end;
limitA = get(handles.sgramAxisA,'xlim');
limitB = get(handles.sgramAxisB,'xlim');
xlimAUpdate = adjustLimit(limitA-displacementA,handles.waveformPlotA);
xlimBUpdate = adjustLimit(limitB-displacementB,handles.waveformPlotB);
drawUpdatedViews(handles,xlimAUpdate,xlimBUpdate)
return;

function smallMapButtonDnFcn(src,evnt)
handles = get(src,'userdata');
GUIuserData = get(handles.temporalAnchorGUI,'userdata');
handles = GUIuserData.currentHandles;
set(handles.temporalAnchorGUI,'WindowButtonMotionFcn','');
set(handles.temporalAnchorGUI,'WindowButtonUpFcn',@smallMapButtonUpFcn);
return;

function smallMapButtonUpFcn(src,evnt)
GUIuserData = get(src,'userdata');
handles = GUIuserData.currentHandles;
%axisHandle = get(src,'parent');
currentpoint = get(handles.locator,'currentpoint');
xData = get(GUIuserData.locatorHandle,'xdata');
yData = get(GUIuserData.locatorHandle,'ydata');
limitA = [min(yData) max(yData)]; % x axis is for time B
limitB = [min(xData) max(xData)];
%---- adjust locator size depending on the current key
switch GUIuserData.currentKey
    case 'shift'
        limitA = (limitA-mean(limitA))*sqrt(2)+mean(limitA);
        limitB = (limitB-mean(limitB))*sqrt(2)+mean(limitB);
    otherwise
        if isOutsideLocator(GUIuserData.locatorHandle)
        else
            limitA = (limitA-mean(limitA))/sqrt(2)+mean(limitA);
            limitB = (limitB-mean(limitB))/sqrt(2)+mean(limitB);
        end;
end;
%---- set locator center to the pointer's position
displacementA = mean(limitA)-currentpoint(1,2);
displacementB = mean(limitB)-currentpoint(1,1);
xlimAUpdate = adjustLimit(limitA-displacementA,handles.waveformPlotA);
xlimBUpdate = adjustLimit(limitB-displacementB,handles.waveformPlotB);
drawUpdatedViews(handles,xlimAUpdate,xlimBUpdate)
set(handles.temporalAnchorGUI,'WindowButtonMotionFcn',@defaultWindowMotionCallback);
set(handles.temporalAnchorGUI,'WindowButtonUpFcn','');
defaultWindowMotionCallback(src,evnt);
return;

function distanceMapButtonDnFcn(src,evnt)
% memo: x is B, y is A
if ~isInsidePlot(get(src,'parent'),'axis')
    return;
end;
handles = get(src,'userdata');
currentPoint = get(handles.distanceMatrixAxis,'currentpoint');
currentTimeB = currentPoint(1,1);
currentTimeA = currentPoint(1,2);
%limitA = get(handles.distanceMatrixAxis,'ylim');
%limitB = get(handles.distanceMatrixAxis,'xlim');
%timeAxisA = get(src,'ydata');
%timeAxisB = get(src,'xdata');
%if ((timeAxisA(end)-timeAxisA(1))<1.05*(diff(limitA))) || ...
%        ((timeAxisB(end)-timeAxisB(1))<1.05*(diff(limitB)))
%disp('full size')
set(handles.temporalAnchorGUI,'WindowButtonMotionFcn',@matrixButtonMotionCallback);
set(handles.temporalAnchorGUI,'WindowButtonUpFcn',@matrixButtonUpCallback);
%end;
GUIBaseHandle = handles.temporalAnchorGUI;
GUIuserData = get(GUIBaseHandle,'userdata');
GUIuserData.currentTimeA = currentTimeA;
GUIuserData.currentTimeB = currentTimeB;
set(GUIBaseHandle,'userdata',GUIuserData);
return;

function matrixButtonUpCallback(src,evnt)
GUIuserData = get(src,'userdata');
handles = GUIuserData.currentHandles;
set(handles.temporalAnchorGUI,'WindowButtonMotionFcn',@defaultWindowMotionCallback);
set(handles.temporalAnchorGUI,'WindowButtonUpFcn','');
set(handles.temporalAnchorGUI,'pointer','arrow');
defaultWindowMotionCallback(src,evnt);
return;

function matrixButtonMotionCallback(src,evnt)
GUIuserData = get(src,'userdata');
handles = GUIuserData.currentHandles;
currentpoint = get(handles.distanceMatrixAxis,'currentpoint');
displacementA = currentpoint(1,2)-GUIuserData.currentTimeA;
displacementB = currentpoint(1,1)-GUIuserData.currentTimeB;
limitA = get(handles.distanceMatrixAxis,'ylim');
limitB = get(handles.distanceMatrixAxis,'xlim');
xlimAUpdate = adjustLimit(limitA-displacementA,handles.waveformPlotA);
xlimBUpdate = adjustLimit(limitB-displacementB,handles.waveformPlotB);
%set(handles.distanceMatrixAxis,'xlim',newLimitB,...
%    'ylim',newLimitA);
%updateViews(src,evnt);
drawUpdatedViews(handles,xlimAUpdate,xlimBUpdate)
return;

function drawUpdatedViews(handles,xlimAUpdate,xlimBUpdate)
GUIuserData = get(handles.temporalAnchorGUI,'userdata');
set(handles.waveformAxisA,'xlim',xlimAUpdate);
set(handles.powerAxisA,'xlim',xlimAUpdate);
set(handles.sgramAxisA,'xlim',xlimAUpdate);
set(handles.waveformAxisB,'xlim',xlimBUpdate);
set(handles.powerAxisB,'xlim',xlimBUpdate);
set(handles.sgramAxisB,'xlim',xlimBUpdate);
set(handles.distanceMatrixAxis,'xlim',xlimBUpdate,'ylim',xlimAUpdate);
if isfield(GUIuserData,'regionHandle')
    set(GUIuserData.regionHandle,...
        'xdata',[xlimBUpdate(1) xlimBUpdate(2) xlimBUpdate(2) xlimBUpdate(1) xlimBUpdate(1)],...
        'ydata',[xlimAUpdate(1) xlimAUpdate(1) xlimAUpdate(2) xlimAUpdate(2) xlimAUpdate(1)]);
    set(GUIuserData.locatorHandle,...
        'xdata',[xlimBUpdate(1) xlimBUpdate(2) xlimBUpdate(2) xlimBUpdate(1) xlimBUpdate(1)],...
        'ydata',[xlimAUpdate(1) xlimAUpdate(1) xlimAUpdate(2) xlimAUpdate(2) xlimAUpdate(1)]);
    set(GUIuserData.timeBLabel,...
        'position',[0.4*xlimBUpdate(1)+0.6*xlimBUpdate(2) xlimAUpdate(1) 3.3]);
    set(GUIuserData.timeALabel,...
        'position',[xlimBUpdate(1) 0.4*xlimAUpdate(1)+0.6*xlimAUpdate(2) 3.3]);
end;
return;

function locatorButtonDnFcn(src,evnt)
handles = get(src,'userdata');
GUIuserData = get(handles.temporalAnchorGUI,'userdata');
currentPoint = get(handles.locator,'currentpoint');
%timeA = get(GUIuserData.mappingPathHandle,'ydata');
%timeB = get(GUIuserData.mappingPathHandle,'xdata');
GUIuserData.currentTimeA = currentPoint(1,2);
GUIuserData.currentTimeB = currentPoint(1,1);
set(handles.temporalAnchorGUI,'WindowButtonMotionFcn',@locatorMotionCallback);
set(handles.temporalAnchorGUI,'WindowButtonUpFcn',@locatorUpCallback);
set(handles.temporalAnchorGUI,'userdata',GUIuserData);
return;

function locatorUpCallback(src,evnt)
GUIuserData = get(src,'userdata');
handles = GUIuserData.currentHandles;
set(handles.temporalAnchorGUI,'WindowButtonMotionFcn',@defaultWindowMotionCallback);
set(handles.temporalAnchorGUI,'WindowButtonUpFcn','');
set(handles.temporalAnchorGUI,'pointer','arrow');
defaultWindowMotionCallback(src,evnt);
return;

function locatorMotionCallback(src,evnt)
GUIuserData = get(src,'userdata');
handles = GUIuserData.currentHandles;
currentpoint = get(handles.locator,'currentpoint');
displacementA = currentpoint(1,2)-GUIuserData.currentTimeA;
displacementB = currentpoint(1,1)-GUIuserData.currentTimeB;
locatorXdata = get(GUIuserData.locatorHandle,'xdata'); % time B
locatorYdata = get(GUIuserData.locatorHandle,'ydata'); % time A
limitA = [min(locatorYdata) max(locatorYdata)];
limitB = [min(locatorXdata) max(locatorXdata)];
xlimAUpdate = adjustLimit(limitA+displacementA,handles.waveformPlotA);
xlimBUpdate = adjustLimit(limitB+displacementB,handles.waveformPlotB);
GUIuserData.currentTimeA = currentpoint(1,2);
GUIuserData.currentTimeB = currentpoint(1,1);
set(handles.temporalAnchorGUI,'userdata',GUIuserData);
%set(handles.distanceMatrixAxis,'xlim',newLimitB,...
%    'ylim',newLimitA);
%updateViews(src,evnt);
drawUpdatedViews(handles,xlimAUpdate,xlimBUpdate);
return;

function defaultWindowMotionCallback(src,evnt)
%       temporalAnchorGUI: 203.0052
%                 locator: 6.0120
%          timeAxisBLabel: 5.0093
%          timeAxisALabel: 4.0203
%              pleaseWait: 3.0159
%    distanceMatrixButton: 239.0033
%           waveformAxisB: 234.0035
%              sgramAxisB: 229.0052
%              powerAxisB: 224.0052
%           waveformAxisA: 219.0052
%              sgramAxisA: 214.0052
%              powerAxisA: 209.0052
%      distanceMatrixAxis: 204.0052
%                  output: 203.0052
%             sgramImageA: 11.0071
%             sgramImageB: 12.0103
%              powerPlotA: 13.0127
%              powerPlotB: 15.0089
%           waveformPlotA: 22.0087
%           waveformPlotB: 23.0087
GUIuserData = get(src,'userdata');
handles = GUIuserData.currentHandles;
GUIhandle = handles.temporalAnchorGUI;
switch GUIuserData.currentKey
    case 'initial'
        GUIuserData.currentKey = 'none';
        set(src,'userdata',GUIuserData);
end;
if isInsidePlot(handles.waveformAxisA,'axis')
    setPointerShape(999);
elseif isfield(GUIuserData,'mappingPathHandle') ...
        && closeToLineNode(GUIuserData.mappingPathHandle) < 5
    switch GUIuserData.currentKey
        case 'shift'
            setPointerShape(7);
        case 'alt'
            setPointerShape(4);
        otherwise
            setPointerShape(5);
    end;
elseif isfield(GUIuserData,'mappingPathHandle') ...
        && closeToSpecificLine(GUIuserData.mappingPathHandle) < 5
    setPointerShape(8);
elseif isOnTimeAnchor(GUIuserData.timeAnchorHandleA)
    switch GUIuserData.currentKey
        case 'alt'
            setPointerShape(4);
        otherwise
            setPointerShape(5);
    end;
elseif isOnTimeAnchor(GUIuserData.timeAnchorHandleB)
    switch GUIuserData.currentKey
        case 'alt'
            setPointerShape(4);
        otherwise
            setPointerShape(5);
    end;
elseif isInsidePlot(handles.sgramAxisA,'axis')
    setPointerShape(3);
elseif isInsidePlot(handles.powerAxisA,'axis')
    setPointerShape(999);
elseif isInsidePlot(handles.sgramAxisB,'axis')
    setPointerShape(3);
elseif isInsidePlot(handles.powerAxisB,'axis')
    setPointerShape(999);
elseif isInsidePlot(handles.waveformAxisB,'axis')
    setPointerShape(999);
elseif isInsidePlot(handles.distanceMatrixAxis,'axis') && ...
        isfield(GUIuserData,'mappingPathHandle')
    setPointerShape(3);
elseif isInsidePlot(handles.waveformAxisA,'fringe')
    switch GUIuserData.currentKey
        case 'shift'
            setPointerShape(2);
        otherwise
            setPointerShape(1);
    end;
elseif isInsidePlot(handles.waveformAxisB,'fringe')
    %GUIuserData.currentKey
    switch GUIuserData.currentKey
        case 'shift'
            setPointerShape(2);
        otherwise
            setPointerShape(1);
    end;
elseif isfield(GUIuserData,'locatorHandle') && ...
        isInsidePlot(handles.locator,'axis')
    if closeToSpecificLine(GUIuserData.locatorHandle) < 5
        setPointerShape(3);
    elseif isOutsideLocator(GUIuserData.locatorHandle)
        switch GUIuserData.currentKey
            case 'shift'
                setPointerShape(2);
            otherwise
                setPointerShape(9);
        end;
    else
        switch GUIuserData.currentKey
            case 'shift'
                setPointerShape(2);
            otherwise
                setPointerShape(1);
        end;
    end;
else
    set(GUIhandle,'pointer','arrow');
end;
if (~isfield(GUIuserData,'frequencyAnchorGUIHandle') || ...
        ~ishandle(GUIuserData.frequencyAnchorGUIHandle)) && ...
        isfield(GUIuserData,'currentFocusID')
            set(GUIuserData.timeAnchorHandleA(GUIuserData.currentFocusID),'linewidth',1);
            set(GUIuserData.timeAnchorHandleB(GUIuserData.currentFocusID),'linewidth',1);    
end;
return;

function answerValue = isOutsideLocator(locatorHandle)
xData = get(locatorHandle,'xdata');
yData = get(locatorHandle,'ydata');
xlim = [min(xData) max(xData)];
ylim = [min(yData) max(yData)];
currentPoint = get(get(locatorHandle,'parent'),'currentpoint');
x = currentPoint(1,1);
y = currentPoint(1,2);
if ((xlim(1)-x)*(xlim(2)-x) < 0) && ((ylim(1)-y)*(ylim(2)-y) < 0)
    answerValue = 0;
else
    answerValue = 1;
end;
return;

function answerValue = isInsidePlot(axisHandle,modeString)
answerValue = 0;
xlim = get(axisHandle,'xlim');
ylim = get(axisHandle,'ylim');
currentPoint = get(axisHandle,'currentpoint');
x = currentPoint(1,1);
y = currentPoint(1,2);
%tightInset = get(axisHandle,'TightInset');
tightInset = [diff(xlim)/8 diff(ylim)/4 diff(xlim)/8 diff(ylim)/4];
switch modeString
    case 'axis'
        if ((xlim(1)-x)*(xlim(2)-x) < 0) && ((ylim(1)-y)*(ylim(2)-y) < 0)
            answerValue = 1;
        else
            answerValue = 0;
        end;
    case 'fringe'
        if ((xlim(1)-x)*(xlim(2)-x) < 0) && ...
                ((ylim(1)-y)*(ylim(1)-tightInset(2)-y) < 0)
            answerValue = 1;
        else
            answerValue = 0;
        end;
end;
return;

function answerValue = closeToSpecificLine(lineHandle)
answerValue = 100000;
xData = get(lineHandle,'xdata');
yData = get(lineHandle,'ydata');
axisHandle = get(lineHandle,'parent');
xLim = get(axisHandle,'xLim');
yLim = get(axisHandle,'yLim');
currentPoint = get(axisHandle,'currentPoint');
x = currentPoint(1,1);
y = currentPoint(1,2);
if ~isInsidePlot(axisHandle,'axis')
    return;
end;
axisUnits = get(axisHandle,'Units');
set(axisHandle,'Units','pixels');
axisPosition = get(axisHandle,'position');
set(axisHandle,'Units',axisUnits);
xp = x/(xLim(2)-xLim(1))*axisPosition(3);
x1 = xData/(xLim(2)-xLim(1))*axisPosition(3);
yp = y/(yLim(2)-yLim(1))*axisPosition(4);
y1 = yData/(yLim(2)-yLim(1))*axisPosition(4);
for ii = 1:length(x1)-1
    currentDistance = proximityToSegment(x1(ii),x1(ii+1),y1(ii),y1(ii+1),xp,yp);
    if currentDistance < answerValue
        answerValue = currentDistance;
    end;
end;
return;

function answerValue = closeToLineNode(lineHandle)
answerValue = 100000;
xData = get(lineHandle,'xdata');
yData = get(lineHandle,'ydata');
axisHandle = get(lineHandle,'parent');
xLim = get(axisHandle,'xLim');
yLim = get(axisHandle,'yLim');
currentPoint = get(axisHandle,'currentpoint');
x = currentPoint(1,1);
y = currentPoint(1,2);
if ~isInsidePlot(axisHandle,'axis')
    return;
end;
axisUnits = get(axisHandle,'Units');
set(axisHandle,'Units','pixels');
axisPosition = get(axisHandle,'position');
set(axisHandle,'Units',axisUnits);
xp = x/(xLim(2)-xLim(1))*axisPosition(3);
x1 = xData/(xLim(2)-xLim(1))*axisPosition(3);
yp = y/(yLim(2)-yLim(1))*axisPosition(4);
y1 = yData/(yLim(2)-yLim(1))*axisPosition(4);
for ii = 1:length(x1)
    currentDistance = sqrt((x1(ii)-xp)^2+(y1(ii)-yp)^2);
    if currentDistance < answerValue
        answerValue = currentDistance;
    end;
end;
return;

function answerValue = isOnTimeAnchor(timeAnchorHandle)
answerValue = 0;
nAnchors = size(timeAnchorHandle,1);
for ii = 1:nAnchors
    axisHandle = get(timeAnchorHandle(ii),'parent');
    xLim = get(axisHandle,'xLim');
    currentPoint = get(axisHandle,'currentpoint');
    if (xLim(1)-currentPoint(1,1))*(xLim(2)-currentPoint(1,1)) > 0
        answerValue = 0;
        return;
    end;
    if closeToSpecificLine(timeAnchorHandle(ii)) <5
        answerValue = 1;
    end;
end;
return;


% --- Executes on button press in setUpButton.
function setUpButton_Callback(hObject, eventdata, handles)
% hObject    handle to setUpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
temporalAnchorGUIuserData = get(handles.temporalAnchorGUI,'userdata');
mSubstrate = temporalAnchorGUIuserData.mSubstrate;
if isfield(mSubstrate,'menuHandle')
    userData = get(mSubstrate.menuHandle,'userdata');
    %userData.mSubstrate = mSubstrate;
    userData.mSubstrate = ...
        updateTemporalAnchorInformation(mSubstrate,userData.mSubstrate);
    set(mSubstrate.menuHandle,'userdata',userData);
    %MorphingMenu('selected','on');
    MorphingMenu('syncGUIStatus',userData.currentHandles);
    figure(mSubstrate.menuHandle);
end;

function updatedSubstrate = updateTemporalAnchorInformation(GUISubstrate,menuSubstrate)
updatedSubstrate = menuSubstrate;
updatedSubstrate.temporaAnchorOfSpeakerA = GUISubstrate.temporaAnchorOfSpeakerA;
updatedSubstrate.temporaAnchorOfSpeakerB = GUISubstrate.temporaAnchorOfSpeakerB;
updatedSubstrate.frequencyAnchorOfSpeakerA = GUISubstrate.frequencyAnchorOfSpeakerA;
updatedSubstrate.frequencyAnchorOfSpeakerB = GUISubstrate.frequencyAnchorOfSpeakerB;
if isfield(GUISubstrate,'anchorOnMorphingTime')
    updatedSubstrate.anchorOnMorphingTime = GUISubstrate.anchorOnMorphingTime;
end;
if isfield(GUISubstrate,'morphingTimeAxis')
    updatedSubstrate.morphingTimeAxis = GUISubstrate.morphingTimeAxis;
end;
return;

% --- Executes on selection change in distanceSelectMenu.
function distanceSelectMenu_Callback(hObject, eventdata, handles)
% hObject    handle to distanceSelectMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Linear
%MFCC
%Shift invariant 1
%Shift Invariant 2
temporalAnchorGUIuserData = get(handles.temporalAnchorGUI,'userdata');
contents = get(hObject,'String');
set(handles.temporalAnchorGUI,'pointer','watch');
drawnow
temporalAnchorGUIuserData.distanceMatrix = ...
    calculateDistanceMatrix(temporalAnchorGUIuserData.mSubstrate,contents{get(hObject,'Value')});
set(temporalAnchorGUIuserData.mapImage,'cdata',temporalAnchorGUIuserData.distanceMatrix);
set(temporalAnchorGUIuserData.locatorImage,'cdata',temporalAnchorGUIuserData.distanceMatrix);
set(handles.temporalAnchorGUI,'pointer','arrow');
drawnow
% Hints: contents = get(hObject,'String') returns distanceSelectMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from distanceSelectMenu

% --- Executes during object creation, after setting all properties.
function distanceSelectMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to distanceSelectMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in saveMorphingSubstrate.
function saveMorphingSubstrate_Callback(hObject, eventdata, handles)
% hObject    handle to saveMorphingSubstrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUIuserData = get(handles.temporalAnchorGUI,'userdata');
revisedData = GUIuserData.mSubstrate;
revisedData.lastUpdate = datestr(now);
outFileName = ['mSubstr' datestr(now,30) '.mat'];
[file,path] = uiputfile(outFileName,'Save the morphing substrate');
if length(file) == 1 && length(path) == 1
    if file == 0 || path == 0
        okInd = 0;
        disp('Save is cancelled!');
        return;
    end;
end;
save([path file],'revisedData');

% --- Executes on button press in playAbutton.
function playAbutton_Callback(hObject, eventdata, handles)
% hObject    handle to playAbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUIuserData = get(handles.temporalAnchorGUI,'userdata');
xlim = get(handles.sgramAxisA,'xlim');
fs = GUIuserData.mSubstrate.samplintFrequency;
x = GUIuserData.mSubstrate.waveformForSpeakerA;
xNormal = x/max(abs(x))*0.9;
xlimInSample = max(1,round(xlim*fs));
sound(xNormal(xlimInSample(1):xlimInSample(2)),fs);
return;

% --- Executes on button press in playBbutton.
function playBbutton_Callback(hObject, eventdata, handles)
% hObject    handle to playBbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUIuserData = get(handles.temporalAnchorGUI,'userdata');
xlim = get(handles.sgramAxisB,'xlim');
fs = GUIuserData.mSubstrate.samplintFrequency;
x = GUIuserData.mSubstrate.waveformForSpeakerB;
xNormal = x/max(abs(x))*0.9;
xlimInSample = max(1,round(xlim*fs));
sound(xNormal(xlimInSample(1):xlimInSample(2)),fs);
return;
