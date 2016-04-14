function varargout = STRAIGHTmanipulatorGUI(varargin)
% STRAIGHTMANIPULATORGUI M-file for STRAIGHTmanipulatorGUI.fig
%      STRAIGHTMANIPULATORGUI, by itself, creates a new STRAIGHTMANIPULATORGUI or raises the existing
%      singleton*.
%
%      H = STRAIGHTMANIPULATORGUI returns the handle to a new STRAIGHTMANIPULATORGUI or the handle to
%      the existing singleton*.
%
%      STRAIGHTMANIPULATORGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STRAIGHTMANIPULATORGUI.M with the given input arguments.
%
%      STRAIGHTMANIPULATORGUI('Property','Value',...) creates a new STRAIGHTMANIPULATORGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before STRAIGHTmanipulatorGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to STRAIGHTmanipulatorGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help STRAIGHTmanipulatorGUI

% Last Modified by GUIDE v2.5 26-Jan-2010 18:07:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @STRAIGHTmanipulatorGUI_OpeningFcn, ...
    'gui_OutputFcn',  @STRAIGHTmanipulatorGUI_OutputFcn, ...
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


% --- Executes just before STRAIGHTmanipulatorGUI is made visible.
function STRAIGHTmanipulatorGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to STRAIGHTmanipulatorGUI (see VARARGIN)

% Choose default command line output for STRAIGHTmanipulatorGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
%   User defined initialization
STRAIGHTCTLObject = get(handles.STRAIGHTmaniuplatorBase,'userdata');
%set(handles.STRAIGHTmaniuplatorBase,'units','pixels',...
%    'position',[100 50 924 720]);
set(handles.STRAIGHTmaniuplatorBase,'units','normalized');
if ~isempty(STRAIGHTCTLObject)
    STRAIGHTCTLObject.creationDate = datestr(now,30);
    STRAIGHTCTLObject.objectDirectory = 'NA';
    STRAIGHTCTLObject.objectFile = 'NA';
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
    STRAIGHTCTLObject = STRAIGHTobject;
    STRAIGHTCTLObject.objectDirectory = path;
    STRAIGHTCTLObject.objectFile = file;
end;
STRAIGHTCTLObject.currentHandles = handles;
TandemSTRAIGHThandler('locateTopLeftOfGUI',65,50,handles.STRAIGHTmaniuplatorBase);
% ----- initialization ------
%set(handles.penbutton,'value',1);
%set(handles.selectionBoxButton,'value',0);
%set(handles.toolSelectorPanel,'SelectionChangeFcn',@toolSelectorPanel_callback);
%set(handles.toolSelectorPanel,'userdata',handles);
set(handles.transitionLengthPopup,'value',3);
set(handles.spectrogramColormap,'value',2);
set(handles.saveResultsButton,'enable','off');
set(handles.rePlayButton,'enable','off');
set(handles.replayVisibleButton,'enable','off');
set(handles.fileNameText,'string',STRAIGHTCTLObject.dataFileName);
set(hObject,'userdata',STRAIGHTCTLObject);
setupDisplay(hObject,handles)
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes STRAIGHTmanipulatorGUI wait for user response (see UIRESUME)
% uiwait(handles.STRAIGHTmaniuplatorBase);


% --- Outputs from this function are returned to the command line.
function varargout = STRAIGHTmanipulatorGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% ---- User defined functions
function setupDisplay(hObject,handles)
%        AperiodicityDisplay: 217.0043
%            DurationDisplay: 212.0043
%                SizeDisplay: 207.0043
%                  F0Display: 202.0043
%               PowerDisplay: 197.0043

axisNames = {'PowerDisplay' 'F0Display' 'SizeDisplay' ...
    'DurationDisplay' 'AperiodicityDisplay'};
knobNames = {'PowerKnob' 'F0Knob' 'SizeKnob' ...
    'DurationKnob' 'AperiodicityKnob'};
STRAIGHTCTLObject = get(handles.STRAIGHTmaniuplatorBase,'userdata');
STRAIGHTCTLObject.axisNames = axisNames;
STRAIGHTCTLObject.knobNames = knobNames;
STRAIGHTCTLObject.currentAxisID = 1;
STRAIGHTCTLObject.SpectrogramKnob = showSpectrogram(STRAIGHTCTLObject,handles);
STRAIGHTCTLObject.PowerKnob = showPowerDisplay(STRAIGHTCTLObject,handles);
STRAIGHTCTLObject.F0Knob = showF0Display(STRAIGHTCTLObject,handles);
STRAIGHTCTLObject.SizeKnob = showSizeDisplay(STRAIGHTCTLObject,handles);
STRAIGHTCTLObject.DurationKnob = showDurationDisplay(STRAIGHTCTLObject,handles);
STRAIGHTCTLObject.AperiodicityKnob = showAperiodicityDisplay(STRAIGHTCTLObject,handles);
focusID = 2;
STRAIGHTCTLObject = multiSliderAxesShaping(STRAIGHTCTLObject,focusID);
%set(STRAIGHTCTLObject.F0Knob,'ButtonDownFcn',@F0KnobButtonDnCallback);
set(STRAIGHTCTLObject.F0Knob,'userdata',handles);
%set(STRAIGHTCTLObject.PowerKnob,'ButtonDownFcn',@genericKnobButtonDnCallback);
set(STRAIGHTCTLObject.PowerKnob,'userdata',handles);
%set(STRAIGHTCTLObject.SizeKnob,'ButtonDownFcn',@genericKnobButtonDnCallback);
set(STRAIGHTCTLObject.SizeKnob,'userdata',handles);
%set(STRAIGHTCTLObject.DurationKnob,'ButtonDownFcn',@genericKnobButtonDnCallback);
set(STRAIGHTCTLObject.DurationKnob,'userdata',handles);
%set(STRAIGHTCTLObject.AperiodicityKnob,'ButtonDownFcn',@genericKnobButtonDnCallback);
set(STRAIGHTCTLObject.AperiodicityKnob,'userdata',handles);
%spectrogramButtonDn_callback
set(STRAIGHTCTLObject.SpectrogramKnob,'ButtonDownFcn',@spectrogramButtonDn_callback);
set(STRAIGHTCTLObject.SpectrogramKnob,'userdata',handles);
%  finalize display setup
STRAIGHTCTLObject.currentKey = 'none';
%set(handles.STRAIGHTmaniuplatorBase,'WindowButtonDownFcn',@STRAIGHTmaniuplatorBase_Callback);
set(handles.STRAIGHTmaniuplatorBase,'KeyPressFcn',@keyPressCallBack);
set(handles.STRAIGHTmaniuplatorBase,'KeyReleaseFcn',@keyReleaseCallBack);
set(handles.STRAIGHTmaniuplatorBase,'WindowButtonMotionFcn',@defaultButtonMotionCallBack);
set(handles.pathIndicator,'string',['Datafile: ' STRAIGHTCTLObject.objectFile ...
    '  in: '  STRAIGHTCTLObject.objectDirectory]);
%set(handles.fileNameIndicator,'string',STRAIGHTCTLObject.objectFile);
set(handles.originalFileName,'string',STRAIGHTCTLObject.dataFileName);
set(handles.STRAIGHTmaniuplatorBase,'userdata',STRAIGHTCTLObject);

function keyPressCallBack(src,evnt)
STRAIGHTCTLObject = get(src,'userdata');
%evnt.Key
STRAIGHTCTLObject.currentKey = evnt.Key;
set(src,'userdata',STRAIGHTCTLObject);
defaultButtonMotionCallBack(src,evnt);
return;

function keyReleaseCallBack(src,evnt)
STRAIGHTCTLObject = get(src,'userdata');
STRAIGHTCTLObject.currentKey = 'none';
set(src,'userdata',STRAIGHTCTLObject);
defaultButtonMotionCallBack(src,evnt);
return;

function defaultButtonMotionCallBack(src,evnt)
STRAIGHTCTLObject = get(src,'userdata');
handles = STRAIGHTCTLObject.currentHandles;
axisHandle = eval(['handles.' STRAIGHTCTLObject.axisNames{STRAIGHTCTLObject.currentAxisID}]);
currentPoint = get(axisHandle,'currentpoint');
yLim = get(axisHandle,'yLim');
xLim = get(axisHandle,'xLim');
tightInset = get(axisHandle,'TightInset');
tmpHandle = get(handles.STRAIGHTmaniuplatorBase,'userdata');
sgramImageHandle = tmpHandle.SpectrogramKnob;
sgramHandle = handles.Spectrogram;
sgramCurrentPont = get(sgramHandle,'currentpoint');
sgramXlim = get(sgramHandle,'xLim');
sgramYlim = get(sgramHandle,'yLim');
sgramTightInset = get(sgramHandle,'TightInset');
if (currentPoint(1,2)>yLim(1)) && (currentPoint(1,2)<yLim(2))
    if  (currentPoint(1,1)<xLim(1)) && (currentPoint(1,1)>xLim(1)-tightInset(1))
        switch STRAIGHTCTLObject.currentKey
            case 'none'
                setPointerShape(1);
            case 'shift'
                setPointerShape(2);
            case 'control'
                setPointerShape(3);
            case 'alt'
                setPointerShape(999);
        end;
    elseif (currentPoint(1,1)>xLim(1)) && (currentPoint(1,1)<xLim(2))
        %toolId = get(handles.PenButton1,'value');
        minimumProximity = checkObjectProximity(src,...
            handles,axisHandle,currentPoint);
        if (minimumProximity < 22) && ~strcmp(STRAIGHTCTLObject.currentKey,'alt')
            setPointerShape(4)
            return;
        end;
        switch get(handles.PenButton1,'value')
            case 1
                setPointerShape(6);
            case 0
                setPointerShape(5);
        end;
    else
        setPointerShape(999);
    end;
elseif (sgramCurrentPont(1,2)>sgramYlim(1)) && (sgramCurrentPont(1,2)<sgramYlim(2))
    if  (sgramCurrentPont(1,1)<sgramXlim(1)) && (sgramCurrentPont(1,1)>sgramXlim(1)-sgramTightInset(1))
        if 1 == 1
        switch STRAIGHTCTLObject.currentKey
            case 'none'
                setPointerShape(999);
            case 'shift'
                setPointerShape(999);
            case 'control'
                setPointerShape(999);
            case 'alt'
                setPointerShape(999);
        end;
        end;
    elseif (sgramCurrentPont(1,1)>sgramXlim(1)) && (sgramCurrentPont(1,1)<sgramXlim(2))
        switch STRAIGHTCTLObject.currentKey
            case 'none'
                setPointerShape(4);
            case 'alt'
                setPointerShape(5);
            otherwise
                setPointerShape(999);
        end;
    else
        setPointerShape(999);
    end; 
else
    setPointerShape(999);
end;
return;

function distanceSqure = ...
    checkObjectProximity(src,handles,axisHandle,currentPoint)
STRAIGHTCTLObject = get(src,'userdata');
knobHandle = eval(['STRAIGHTCTLObject.' ...
    STRAIGHTCTLObject.knobNames{STRAIGHTCTLObject.currentAxisID}]);
x = currentPoint(1,1);
y = currentPoint(1,2);
xData = get(knobHandle,'xdata');
yData = get(knobHandle,'ydata');
%xData(1:5)
%yData(1:5)
axisUserdata = get(axisHandle,'userdata');
if isfield(axisUserdata,'anchorHandle')
    xdataAnchor = get(axisUserdata.anchorHandle,'xdata');
    ydataAnchor = get(axisUserdata.anchorHandle,'ydata');
end;
xLim = get(axisHandle,'xLim');
yLim = get(axisHandle,'yLim');
yScale = get(axisHandle,'yScale');
axisUnits = get(axisHandle,'Units');
set(axisHandle,'Units','pixels');
axisPosition = get(axisHandle,'position');
set(axisHandle,'Units',axisUnits);
xDistanceInPix = (xData-x)/(xLim(2)-xLim(1))*axisPosition(3);
switch yScale
    case 'linear'
        yDistanceInPix = (yData-y)/(yLim(2)-yLim(1))*axisPosition(4);
    case 'log'
        yDistanceInPix = log(yData/y)/log(yLim(2)/yLim(1))*axisPosition(4);
end;
distanceSqure = min(xDistanceInPix.^2+yDistanceInPix.^2);
if length(xData) > 1
    xp = x/(xLim(2)-xLim(1))*axisPosition(3);
    x1 = max(xData(xData<=x)/(xLim(2)-xLim(1))*axisPosition(3));
    x2 = min(xData(xData>x)/(xLim(2)-xLim(1))*axisPosition(3));
    index1 = max(find(xData<=x));
    switch yScale
        case 'linear'
            yp = y/(yLim(2)-yLim(1))*axisPosition(4);
            y1 = yData(index1)/(yLim(2)-yLim(1))*axisPosition(4);
            y2 = yData(index1+1)/(yLim(2)-yLim(1))*axisPosition(4);
        case 'log'
            yp = log(y)/log(yLim(2)/yLim(1))*axisPosition(4);
            y1 = log(yData(index1))/log(yLim(2)/yLim(1))*axisPosition(4);
            y2 = log(yData(index1+1))/log(yLim(2)/yLim(1))*axisPosition(4);
    end;
    distanceSqure2 = proximityToSegment(x1,x2,y1,y2,xp,yp)^2;
    distanceSqure = min(distanceSqure,distanceSqure2);
end;
if isfield(axisUserdata,'anchorHandle') 
    yData = ydataAnchor; xData = xdataAnchor;
    xDistanceInPix = (xData-x)/(xLim(2)-xLim(1))*axisPosition(3);
    switch yScale
        case 'linear'
            yDistanceInPix = (yData-y)/(yLim(2)-yLim(1))*axisPosition(4);
        case 'log'
            yDistanceInPix = log(yData/y)/log(yLim(2)/yLim(1))*axisPosition(4);
    end;
    distanceSqureAnchor = min(xDistanceInPix.^2+yDistanceInPix.^2);
    if ~isempty(distanceSqureAnchor)
        distanceSqure = min(distanceSqure,distanceSqureAnchor);
    end;
    if ~isempty(xData)
    if (x>=min(xData)) && (x<max(xData))
        if length(xData) > 1
            xp = x/(xLim(2)-xLim(1))*axisPosition(3);
            x1 = max(xData(xData<=x)/(xLim(2)-xLim(1))*axisPosition(3));
            x2 = min(xData(xData>x)/(xLim(2)-xLim(1))*axisPosition(3));
            index1 = max(find(xData<=x));
            switch yScale
                case 'linear'
                    yp = y/(yLim(2)-yLim(1))*axisPosition(4);
                    y1 = yData(index1)/(yLim(2)-yLim(1))*axisPosition(4);
                    y2 = yData(index1+1)/(yLim(2)-yLim(1))*axisPosition(4);
                case 'log'
                    yp = log(y)/log(yLim(2)/yLim(1))*axisPosition(4);
                    y1 = log(yData(index1))/log(yLim(2)/yLim(1))*axisPosition(4);
                    y2 = log(yData(index1+1))/log(yLim(2)/yLim(1))*axisPosition(4);
            end;
            distanceSqure2 = proximityToSegment(x1,x2,y1,y2,xp,yp)^2;
            distanceSqure = min(distanceSqure,distanceSqure2);
        end;
    end;
    end;
end;
return;

function SpectrogramKnob = showSpectrogram(STRAIGHTCTLObject,handles)
fs = STRAIGHTCTLObject.samplingFrequency;
logSpectrogram = ...
    10*log10(STRAIGHTCTLObject.SpectrumStructure.spectrogramSTRAIGHT);
timeAxis = STRAIGHTCTLObject.SpectrumStructure.temporalPositions;
subplot(handles.Spectrogram);
upperFrequency = min(6000,fs/2);
maximumLevel = max(max(logSpectrogram));
spectrogramDynamicRange = 75; % in dB
trimmedLogSpectrogram = ...
    max(maximumLevel-spectrogramDynamicRange,logSpectrogram);
SpectrogramKnob = imagesc([timeAxis(1) timeAxis(end)],[0 fs/2],...
    trimmedLogSpectrogram);
axis('xy');
axis([timeAxis(1) timeAxis(end) 0 upperFrequency]);
%textXLocation = timeAxis(1)-(timeAxis(end)-timeAxis(1))*0.13;
%textYLocation = upperFrequency/2;
%text(textXLocation,textYLocation,'Sgram')
ylabel({'Spectrogram' 'frequency (Hz)'},'fontsize',12);
get(SpectrogramKnob);
return;

function PowerKnob = showPowerDisplay(STRAIGHTCTLObject,handles)
fs = STRAIGHTCTLObject.samplingFrequency;
logPower = ...
    10*log10(sum(STRAIGHTCTLObject.SpectrumStructure.spectrogramSTRAIGHT));
timeAxis = STRAIGHTCTLObject.SpectrumStructure.temporalPositions;
subplot(handles.PowerDisplay);
%set(handles.PowerDisplay,'drawmode','fast');
set(handles.PowerDisplay,'units','normalized');
maxLevel = max(logPower);
spectrogramDynamicRange = 65; % in dB
PowerKnob = plot(timeAxis,logPower,'linewidth',2);grid on;
axis([timeAxis(1) timeAxis(end) maxLevel-spectrogramDynamicRange maxLevel+20]);
%textXLocation = timeAxis(1)-(timeAxis(end)-timeAxis(1))*0.13;
%textYLocation = maxLevel-spectrogramDynamicRange/2+10;
%text(textXLocation,textYLocation,'Level')
ylabel({'Level' '(rel. dB)'},'fontsize',12);
return;

function F0Knob = showF0Display(STRAIGHTCTLObject,handles)
fs = STRAIGHTCTLObject.samplingFrequency;
f0Candidates = STRAIGHTCTLObject.refinedF0Structure.f0CandidatesMap;
timeAxis = STRAIGHTCTLObject.refinedF0Structure.temporalPositions;
subplot(handles.F0Display);
%set(handles.F0Display,'drawmode','fast');
set(handles.F0Display,'units','normalized');
f0Trajectory = STRAIGHTCTLObject.refinedF0Structure.f0;
scoreTrajectory = STRAIGHTCTLObject.refinedF0Structure.periodicityLevel;
if isfield(STRAIGHTCTLObject.refinedF0Structure,'vuv')
    vuv = STRAIGHTCTLObject.refinedF0Structure.vuv>0.5;
    averageF0 = exp(mean(log(f0Trajectory(vuv>0.5))));
    if isempty(averageF0) || isnan(averageF0)
        averageF0 = exp(mean(log(f0Trajectory)));
    end;
else
    averageF0 = exp(mean(log(f0Trajectory(scoreTrajectory>1.4))));
end;
%averageF0 = exp(mean(log(f0Trajectory(scoreTrajectory>1.4))));
f0CandidateHandle = plot(timeAxis,f0Candidates','.');
set(f0CandidateHandle,'ButtonDownFcn',@escapeToUpperButtonDownFcn);
hold on
F0Knob = plot(timeAxis,f0Trajectory,'linewidth',2);grid on;
%tmpF0 = f0Trajectory;
%tmpF0(scoreTrajectory<1.4) = tmpF0(scoreTrajectory<1.4)*nan;
%plot(timeAxis,tmpF0,'k','linewidth',2);
hold off
axis([timeAxis(1) timeAxis(end) averageF0*[1/3.7 2]]);
ytickValue = [40 60 80 100 120 140 160 180 200 250 300 400 600 800 1000]';
ytickLabel = num2str(ytickValue,4);
set(handles.F0Display,'ytick',ytickValue,'ytickLabel',ytickLabel,'yscale','log');
%textXLocation = timeAxis(1)-(timeAxis(end)-timeAxis(1))*0.13;
%textYLocation = averageF0*(1/3.7*2);
%text(textXLocation,textYLocation,'F0')
ylabel({'F0' '(Hz)'},'fontsize',12);
return;

function SizeKnob = showSizeDisplay(STRAIGHTCTLObject,handles)
fs = STRAIGHTCTLObject.samplingFrequency;
timeAxis = STRAIGHTCTLObject.SpectrumStructure.temporalPositions;
sizeMagnifier = timeAxis*0+1;
subplot(handles.SizeDisplay);
%set(handles.SizeDisplay,'drawmode','fast');
set(handles.SizeDisplay,'units','normalized');
maxSize = 1.4;
minSize = 1/1.4;
SizeKnob = semilogy(timeAxis,sizeMagnifier,'linewidth',2);grid on;
axis([timeAxis(1) timeAxis(end) minSize/1.1 maxSize*1.1]);
ytickValue = [1/3 1/2 1/1.5 1/1.4 1/1.3 1/1.2 1/1.1 1 1.1 1.2 1.3 1.4 1.5 2 3]';
ytickLabel = {'1/3' ; '1/2' ; '1/1.5' ; ...
    '1/1.4'; '1/1.3'; '1/1.2'; '1/1.1'; '1' ; '1.1'; '1.2'; '1.3'; '1.4'; '1.5' ; '2' ;  '3'};
set(handles.SizeDisplay,'ytick',ytickValue,'ytickLabel',ytickLabel,'yscale','log');
%textXLocation = timeAxis(1)-(timeAxis(end)-timeAxis(1))*0.13;
%textYLocation = 1;
%text(textXLocation,textYLocation,'Size')
ylabel({'Size' '(ratio)'},'fontsize',12);
return;

function DurationKnob = showDurationDisplay(STRAIGHTCTLObject,handles)
fs = STRAIGHTCTLObject.samplingFrequency;
timeAxis = STRAIGHTCTLObject.SpectrumStructure.temporalPositions;
DurationMagnifier = timeAxis*0+1;
subplot(handles.DurationDisplay);
%set(handles.DurationDisplay,'drawmode','fast');
set(handles.DurationDisplay,'units','normalized');
%maxDuration = 3;
%minDuration = 1/3;
maxDuration = 10;
minDuration = 1/10;
DurationKnob = semilogy(timeAxis,DurationMagnifier,'linewidth',2);grid on;
axis([timeAxis(1) timeAxis(end) minDuration/1.1 maxDuration*1.1]);
ytickValue = [1/10 1/5 1/3 1/2 1/1.5 1 1.5 2 3 5 10]';
ytickLabel = {'1/10'; '1/5'; '1/3' ; '1/2' ; '1/1.5' ; '1' ;  '1.5' ; '2' ;  '3'; '5' ; '10'};
set(handles.DurationDisplay,'ytick',ytickValue,'ytickLabel',ytickLabel,'yscale','log');
%textXLocation = timeAxis(1)-(timeAxis(end)-timeAxis(1))*0.13;
%textYLocation = 1;
%text(textXLocation,textYLocation,'Duration')
ylabel({'Duration' '(ratio)'},'fontsize',12);
return;

function AperiodicityKnob = showAperiodicityDisplay(STRAIGHTCTLObject,handles)
fs = STRAIGHTCTLObject.samplingFrequency;
timeAxis = STRAIGHTCTLObject.SpectrumStructure.temporalPositions;
AperiodicityMagnifier = timeAxis*0+1;
subplot(handles.AperiodicityDisplay);
%set(handles.AperiodicityDisplay,'drawmode','fast');
set(handles.AperiodicityDisplay,'units','normalized');
maxAperiodicity = 3;
minAperiodicity = 1/3;
AperiodicityKnob = semilogy(timeAxis,AperiodicityMagnifier,'linewidth',2);grid on;
axis([timeAxis(1) timeAxis(end) minAperiodicity/1.1 maxAperiodicity*1.1]);
ytickValue = [1/3 1/2 1/1.5 1 1.5 2 3]';
ytickLabel = {'1/3' ; '1/2' ; '1/1.5' ; '1' ;  '1.5' ; '2' ;  '3'};
set(handles.AperiodicityDisplay,'ytick',ytickValue,'ytickLabel',ytickLabel,'yscale','log');
%textXLocation = timeAxis(1)-(timeAxis(end)-timeAxis(1))*0.13;
%textYLocation = 1;
%text(textXLocation,textYLocation,'Aperiodicity')
ylabel({'AP.' '(ratio)'},'fontsize',12);
return;

function verticalAxisMotionCallBack(src,evnt)
%disp(get(src,'tag'));
STRAIGHTCTLObject = get(src,'userdata');
handles = STRAIGHTCTLObject.currentHandles;
axisHandle = eval(['handles.' ...
    STRAIGHTCTLObject.axisNames{STRAIGHTCTLObject.currentAxisID}]);
currentPoint = get(axisHandle,'currentpoint');
yScale = get(axisHandle,'yScale');
switch yScale
    case 'linear'
        displacement = currentPoint(1,2)-STRAIGHTCTLObject.currentY;
        yLimit = get(axisHandle,'ylim');
        newYLimit = yLimit-displacement;
        set(axisHandle,'ylim',newYLimit);
    case 'log'
        displacement = currentPoint(1,2)/STRAIGHTCTLObject.currentY;
        yLimit = get(axisHandle,'ylim');
        newYLimit = yLimit/displacement;
        set(axisHandle,'ylim',newYLimit);
end;
return;

function verticalAxisButtonUpCallBack(src,evnt)
STRAIGHTCTLObject = get(src,'userdata');
handles = STRAIGHTCTLObject.currentHandles;
set(handles.STRAIGHTmaniuplatorBase,'WindowButtonMotionFcn',...
    @defaultButtonMotionCallBack);
set(handles.STRAIGHTmaniuplatorBase,'WindowButtonUpFcn','');
defaultButtonMotionCallBack(src,evnt);
return;

function STRAIGHTCTLObject = multiSliderAxesShaping(STRAIGHTCTLObject,targetID)
axisNames = STRAIGHTCTLObject.axisNames;
handles = STRAIGHTCTLObject.currentHandles;
%---- special function for vertical axis shaping
currentPoint = get(gca,'currentpoint');
xlim = get(gca,'xlim');
if (currentPoint(1,1) < xlim(1)) & (STRAIGHTCTLObject.currentAxisID == targetID)
    yLim = get(gca,'ylim');
    currentY = currentPoint(1,2);
    yScale = get(gca,'yscale');
    switch STRAIGHTCTLObject.currentKey
        case 'control'
            %disp(['Key is :' STRAIGHTCTLObject.currentKey]);
            set(handles.STRAIGHTmaniuplatorBase,'WindowButtonMotionFcn',...
                @verticalAxisMotionCallBack);
            STRAIGHTCTLObject.currentY = currentPoint(1,2);
            set(handles.STRAIGHTmaniuplatorBase,'userdata',STRAIGHTCTLObject);
            set(handles.STRAIGHTmaniuplatorBase,'WindowButtonUpFcn',...
                @verticalAxisButtonUpCallBack);
        case 'shift'
            %disp(['Key is :' STRAIGHTCTLObject.currentKey]);
            switch yScale
                case 'log'
                    newYLim = currentY*[(yLim(1)/currentY)^(1.5) ...
                        (yLim(2)/currentY)^(1.5)];
                    set(gca,'yLim',newYLim);
                case 'linear'
                    newYLim = currentY+[(yLim(1)-currentY)*sqrt(2) ...
                        (yLim(2)-currentY)*sqrt(2)];
                    set(gca,'yLim',newYLim);
            end;
        case 'alt'
            %disp(['Key is :' STRAIGHTCTLObject.currentKey]);
        case 'none'
            switch yScale
                case 'log'
                    newYLim = currentY*[(yLim(1)/currentY)^(1/1.5) ...
                        (yLim(2)/currentY)^(1/1.5)];
                    set(gca,'yLim',newYLim);
                case 'linear'
                    newYLim = currentY+[(yLim(1)-currentY)/sqrt(2) ...
                        (yLim(2)-currentY)/sqrt(2)];
                    set(gca,'yLim',newYLim);
            end;
    end;
    return;
end;
%---- end of special function
if STRAIGHTCTLObject.currentAxisID == targetID
    knobHandle = eval(['STRAIGHTCTLObject.' STRAIGHTCTLObject.knobNames{targetID}]);
    switch targetID
        case 2
            if get(handles.PenButton1,'value') == 1
                STRAIGHTCTLObject = ...
                    generateF0PenHandle(STRAIGHTCTLObject,handles);
            else
                STRAIGHTCTLObject = ...
                    generateActiveF0Handle(STRAIGHTCTLObject,handles);
            end;
            set(knobHandle,'ButtonDownFcn',@F0KnobButtonDnCallback);
        otherwise
            if get(handles.PenButton1,'value') == 1
                STRAIGHTCTLObject = ...
                    genericPenHandle(STRAIGHTCTLObject,handles);
            else
                STRAIGHTCTLObject = ...
                    genericActiveF0Handle(STRAIGHTCTLObject,handles);
            end;
            set(knobHandle,'ButtonDownFcn',@genericKnobButtonDnCallback);
    end;
else
    baseSeparation = 0.010;
    baseHight = 0.0593;
    baseFocusHight = 0.2894;
    baseSkip = 0.0667;
    r = 1;
    for r = 0:1/7:1
        basePosition = [0.08    0.045    0.715    0.0593];
        for ii = 5:-1:1
            axisHandle = eval(['STRAIGHTCTLObject.currentHandles.' axisNames{ii}]);
            if ii == targetID
                basePosition(4) = (1-r)*baseHight+r*baseFocusHight;
                set(axisHandle,'position',basePosition)
                basePosition(2) = basePosition(2)+basePosition(4)+baseSeparation;
            elseif ii == STRAIGHTCTLObject.currentAxisID
                basePosition(4) = r*baseHight+(1-r)*baseFocusHight;
                set(axisHandle,'position',basePosition)
                basePosition(2) = basePosition(2)+basePosition(4)+baseSeparation;
            else
                basePosition(4) = baseHight;
                set(axisHandle,'position',basePosition)
                basePosition(2) = basePosition(2)+basePosition(4)+baseSeparation;
            end;
            %get(axisHandle,'position');
            if ii ~= 5;set(axisHandle,'xticklabel',[]);end;
            if r == 1
                set(axisHandle,'ButtonDownFcn',@displayRefocusCallback);
                userData = get(axisHandle,'userdata');
                userData.handles = handles;
                userData.knobID = ii;
                set(axisHandle,'userdata',userData);
                knobHandle = eval(['STRAIGHTCTLObject.' STRAIGHTCTLObject.knobNames{ii}]);
                if ii ~= targetID
                    set(knobHandle,'ButtonDownFcn',@escapeToUpperButtonDownFcn);
                    if isfield(userData,'anchorHandle')
                        set(userData.anchorHandle,'ButtonDownFcn',@escapeToUpperButtonDownFcn);
                    end;
                else
                    switch targetID
                        case 2
                            set(knobHandle,'ButtonDownFcn',@F0KnobButtonDnCallback);
                            if isfield(userData,'anchorHandle')
                                set(userData.anchorHandle,'ButtonDownFcn',@F0anchorButtonDnFcn);
                            end;
                        otherwise
                            set(knobHandle,'ButtonDownFcn',@genericKnobButtonDnCallback);
                            if isfield(userData,'anchorHandle')
                                set(userData.anchorHandle,'ButtonDownFcn',@genericAnchorButtonDnFcn);
                            end;
                   end;
                end;
                if ii == 5 % This part should be revised when AP treatment is OK
                    set(axisHandle,'ButtonDownFcn','');
                    set(knobHandle,'ButtonDownFcn','');
                end;
            end;
        end;
        drawnow;
    end;
end;
STRAIGHTCTLObject.currentAxisID = targetID;
set(handles.output,'userdata',STRAIGHTCTLObject);
if isfield(STRAIGHTCTLObject,'axisNames')
    defaultButtonMotionCallBack(handles.output,1);
end;
return;

function escapeToUpperButtonDownFcn(src,evnt)
displayRefocusCallback(get(src,'parent'),evnt);
return;

function STRAIGHTCTLObject = genericPenHandle(STRAIGHTCTLObject,handles)
currentID = STRAIGHTCTLObject.currentAxisID;
%axisPosition = get(gca,'position');
F0userdata = get(gca,'userdata');
currentPoint = get(gca,'currentpoint');
F0userdata.xdata = currentPoint(1,1);
F0userdata.ydata = currentPoint(1,2);
if isfield(F0userdata,'line')
    set(F0userdata.line,'color','c','linewidth',1);
end;
F0userdata = updateLineList(F0userdata);
F0userdata.line = ...
    line('xdata',F0userdata.xdata,'ydata',F0userdata.ydata,...
    'color','m','linewidth',2);
set(handles.output,'WindowButtonMotionFcn',@genericWindowButtonMotionCallback);
set(handles.output,'WindowButtonUpFcn',@genericWindowButtonUpCallback);
set(eval(['STRAIGHTCTLObject.' STRAIGHTCTLObject.knobNames{currentID}]),'userdata',handles);
%plotHandle = STRAIGHTCTLObject.F0Knob;%
set(gca,'userdata',F0userdata);
%set(handles.output,'pointer','crosshair')
setPointerShape(6); % pencil shape
return;

function genericWindowButtonUpCallback(src,evnt)
userdata = get(src,'userdata');
handles = userdata.currentHandles;
currentID = userdata.currentAxisID;
set(handles.output,'WindowButtonMotionFcn',@defaultButtonMotionCallBack);
set(handles.output,'WindowButtonUpFcn','');
set(handles.output,'pointer','arrow')
switch get(handles.PenButton1,'value')
    case 1
        makeNewGenericPenHandle(handles,currentID);
    case 0
        %makeNewPenHandle(handles);
end;
genericAnchorMotion_callback(handles.output,1)
return;

function STRAIGHTCTLObject = genericActiveF0Handle(STRAIGHTCTLObject,handles)
axisPosition = get(gca,'position');
currentID = STRAIGHTCTLObject.currentAxisID;
userdata = get(eval(['handles.' STRAIGHTCTLObject.axisNames{currentID}]),'userdata');
if isfield(userdata,'line')
    set(userdata.line,'color','c','linewidth',1);
end;
finalRectangle = rbbox;
normalizedRectangle = ...
    [(finalRectangle(1:2)-axisPosition(1:2))./axisPosition(3:4) ...
    finalRectangle(3:4)./axisPosition(3:4)];
%plotHandle = STRAIGHTCTLObject.F0Knob;%
%eval(['mSubstrate.' mSubstrate.knobNames{targetID} '.plot']);
xlimit = get(gca,'xlim');
ylimit = get(gca,'ylim');
xRange = xlimit(2)-xlimit(1);
switch currentID
    case {2,3,4,5}
        yRange = log(ylimit(2))-log(ylimit(1));
    case {1}
        yRange = ylimit(2)-ylimit(1);
end;
xmin = normalizedRectangle(1)*xRange+xlimit(1);
xmax = (normalizedRectangle(1)+normalizedRectangle(3))*xRange+xlimit(1);
switch currentID
    case {2,3,4,5}
        ymin = exp(normalizedRectangle(2)*yRange+log(ylimit(1)));
        ymax = exp((normalizedRectangle(2)+normalizedRectangle(4))*yRange+log(ylimit(1)));
    case {1}
        ymin = normalizedRectangle(2)*yRange+ylimit(1);
        ymax = (normalizedRectangle(2)+normalizedRectangle(4))*yRange+ylimit(1);
end;
userData = get(gca,'userdata');
userData.limitBox = [xmin xmax ymin ymax];
set(gca,'userdata',userData);
makeNewGenericPenHandle(handles,currentID);
return;

function makeNewGenericPenHandle(handles,currentID)
STRAIGHTCTLObject = get(handles.STRAIGHTmaniuplatorBase,'userdata');
AxisUserdata = get(eval(['handles.' STRAIGHTCTLObject.axisNames{currentID}]),'userdata');
%F0userdata = get(handles.F0Display,'userdata');
if isfield(AxisUserdata,'anchorHandle')
    if ishandle(AxisUserdata.anchorHandle)
        delete(AxisUserdata.anchorHandle);
        AxisUserdata = rmfield(AxisUserdata,'anchorHandle');
    end;
end;
knobHandle = eval(['STRAIGHTCTLObject.' STRAIGHTCTLObject.knobNames{currentID}]);
xdataKnob = get(knobHandle,'xdata');
ydataKnob = get(knobHandle,'ydata');
gotCurrentObject = gco;
if isempty(gotCurrentObject)
    gotCurrentObject = handles.F0Display;
end;
if (gotCurrentObject ~= STRAIGHTCTLObject.F0Knob) || ...
        strcmp(STRAIGHTCTLObject.currentKey,'alt')
    if get(handles.PenButton1,'value') == 1
        [xdataPenSort,indexSorted] = sort(AxisUserdata.xdata);
        ydataPenSort = AxisUserdata.ydata(indexSorted);
        indexAnchor = 1:length(xdataKnob);
        indexAnchor = indexAnchor((xdataKnob>=xdataPenSort(1))&...
            (xdataKnob<=xdataPenSort(end)));
        xdataAnchor = xdataKnob(indexAnchor);
        for ii = 2:length(xdataPenSort)
            if xdataPenSort(ii) == xdataPenSort(ii-1)
                xdataPenSort(ii-1) = 0;
            end;
        end;
        ydataPenSort = ydataPenSort(xdataPenSort>0);
        xdataPenSort = xdataPenSort(xdataPenSort>0);
        ydataAnchor = interp1(xdataPenSort,ydataPenSort,xdataAnchor,'linear','extrap');
    else
        if isfield(AxisUserdata,'limitBox')
            limitBox = AxisUserdata.limitBox;
            xdataAnchor = xdataKnob((xdataKnob>=limitBox(1))&...
                ((xdataKnob<=limitBox(2))));
            ydataAnchor = ydataKnob((xdataKnob>=limitBox(1))&...
                ((xdataKnob<=limitBox(2))));
        else
            return;
        end;
    end;
else
    xdataAnchor = xdataKnob;
    ydataAnchor = ydataKnob;
end;
AxisUserdata.anchorHandle = line('xdata',xdataAnchor,'ydata',ydataAnchor,...
    'linewidth',5,'color','g');
set(AxisUserdata.anchorHandle,'ButtonDownFcn',@genericAnchorButtonDnFcn);
%set(STRAIGHTCTLObject.F0Knob,'ButtonDownFcn',@F0anchorButtonDnFcn);
%set(handles.STRAIGHTmaniuplatorBase,'userdata',STRAIGHTCTLObject);
AxisUserdata.handles = handles;
anchorUserData.handles = handles;
set(AxisUserdata.anchorHandle,'userdata',anchorUserData);
set(eval(['handles.' STRAIGHTCTLObject.axisNames{currentID}]),'userdata',AxisUserdata);
set(handles.saveResultsButton,'enable','off');
set(handles.rePlayButton,'enable','off');
set(handles.replayVisibleButton,'enable','off');
return;

function STRAIGHTCTLObject = generateF0PenHandle(STRAIGHTCTLObject,handles)
%disp('Pen is generated')
axisPosition = get(gca,'position');
F0userdata = get(gca,'userdata');
currentPoint = get(gca,'currentpoint');
F0userdata.xdata = currentPoint(1,1);
F0userdata.ydata = currentPoint(1,2);
if isfield(F0userdata,'line')
    set(F0userdata.line,'color','c','linewidth',1);
end;
F0userdata = updateLineList(F0userdata);
F0userdata.line = ...
    line('xdata',F0userdata.xdata,'ydata',F0userdata.ydata,...
    'color','m','linewidth',2);
set(handles.output,'WindowButtonMotionFcn',@F0WindowButtonMotionCallback);
set(handles.output,'WindowButtonUpFcn',@F0WindowButtonUpCallback);
set(STRAIGHTCTLObject.F0Knob,'userdata',handles);
%plotHandle = STRAIGHTCTLObject.F0Knob;%
set(gca,'userdata',F0userdata);
%set(handles.output,'pointer','crosshair')
setPointerShape(6); % pencil shape
return;

function F0userdata = updateLineList(F0userdata)
if ~isfield(F0userdata,'line')
    return;
else
    if ~isfield(F0userdata,'linesInLineList')
        %display('line lis is created')
        F0userdata.linesInLineList = 1;
        F0userdata.lineList(F0userdata.linesInLineList).lastLine = F0userdata.line;
    else
        %display('line lis is updated')
        F0userdata.linesInLineList = F0userdata.linesInLineList+1;
        F0userdata.lineList(F0userdata.linesInLineList).lastLine = F0userdata.line;
    end;
end;

function F0KnobButtonDnCallback(src,evnt)
handles = get(src,'userdata');
STRAIGHTCTLObject = get(handles.STRAIGHTmaniuplatorBase,'userdata');
switch STRAIGHTCTLObject.currentKey
    case 'alt'
        displayRefocusCallback(get(src,'parent'),evnt);
        return;
end;
makeNewPenHandle(handles);
STRAIGHTCTLObject = get(handles.STRAIGHTmaniuplatorBase,'userdata');
handles = STRAIGHTCTLObject.currentHandles;
F0userdata = get(handles.F0Display,'userdata');
if isfield(F0userdata,'anchorHandle')
    if ishandle(F0userdata.anchorHandle)
        if isfield(F0userdata,'line')
            set(F0userdata.line,'color','c','linewidth',1);
        end;
        F0anchorButtonDnFcn(F0userdata.anchorHandle,1); % 1 is a dummy
    end;
end;
%F0anchorButtonDnFcn()
return

function genericKnobButtonDnCallback(src,evnt)
handles = get(src,'userdata');
%STRAIGHTCTLObject = get(handles.STRAIGHTmaniuplatorBase,'userdata');
STRAIGHTCTLObject = get(handles.STRAIGHTmaniuplatorBase,'userdata');
switch STRAIGHTCTLObject.currentKey
    case 'alt'
        displayRefocusCallback(get(src,'parent'),evnt);
        return;
end;
currentAxisHandle = gca;
userData = get(currentAxisHandle,'userdata');
for ii = 1:5
    if currentAxisHandle == eval(['handles.' STRAIGHTCTLObject.axisNames{ii}]);
        currentAxis = ii;
    end;
end;
knobHandle = ...
    eval(['STRAIGHTCTLObject.' STRAIGHTCTLObject.knobNames{currentAxis}]);
xdataKnob = get(knobHandle,'xdata');
ydataKnob = get(knobHandle,'ydata');
if isfield(userData,'anchorHandle')
    delete(userData.anchorHandle);
end;
userData.anchorHandle = ...
    line('xdata',xdataKnob,'ydata',ydataKnob,'linewidth',5,'color','g');
set(currentAxisHandle,'userdata',userData);
anchorUserData.handles = handles;
anchorUserData.currentAxis = currentAxis;
set(userData.anchorHandle,'userdata',anchorUserData);
set(userData.anchorHandle,'ButtonDownFcn',@genericAnchorButtonDnFcn);
genericAnchorButtonDnFcn(userData.anchorHandle,1);
return;

function genericAnchorButtonDnFcn(src,evnt)
userData = get(src,'userdata');
%anchorUserData = get(userData.anchorHandle,'userdata');
handles = userData.handles;
STRAIGHTCTLObject = get(handles.STRAIGHTmaniuplatorBase,'userdata');
switch STRAIGHTCTLObject.currentKey
    case 'alt'
        displayRefocusCallback(get(src,'parent'),evnt);
        return;
end;
set(handles.STRAIGHTmaniuplatorBase,'WindowButtonMotionFcn',@genericAnchorMotion_callback)
set(handles.STRAIGHTmaniuplatorBase,'WindowButtonUpFcn',@genericAnchorUp_callback)
%set(handles.STRAIGHTmaniuplatorBase,'pointer','circle');
setPointerShape(3); % hand shape
return;

function genericAnchorUp_callback(src,evnt)
STRAIGHTCTLObject = get(src,'userdata');
handles = STRAIGHTCTLObject.currentHandles;
currentAxisID = STRAIGHTCTLObject.currentAxisID;
axisHandle = eval(['handles.' STRAIGHTCTLObject.axisNames{currentAxisID}]);
axisUserData = get(axisHandle,'userdata');
xdataAnchor = get(axisUserData.anchorHandle,'xdata');
ydataAnchor = get(axisUserData.anchorHandle,'ydata');
switch currentAxisID
    case 1 % Power
    case 3 % Size
    case 4 % Duration
    case 5 % Aperiodicity
end;
set(handles.STRAIGHTmaniuplatorBase,'WindowButtonMotionFcn',@defaultButtonMotionCallBack)
set(handles.STRAIGHTmaniuplatorBase,'WindowButtonUpFcn','')
set(handles.STRAIGHTmaniuplatorBase,'pointer','arrow');
set(handles.saveResultsButton,'enable','off');
set(handles.rePlayButton,'enable','off');
set(handles.replayVisibleButton,'enable','off');
return;

function genericAnchorMotion_callback(src,evnt)
STRAIGHTCTLObject = get(src,'userdata');
handles = STRAIGHTCTLObject.currentHandles;
currentAxisID = STRAIGHTCTLObject.currentAxisID;
axisHandle = eval(['handles.' STRAIGHTCTLObject.axisNames{currentAxisID}]);
knobHandle = eval(['STRAIGHTCTLObject.' STRAIGHTCTLObject.knobNames{currentAxisID}]);
DisplayUserdata = get(axisHandle,'userdata');
currentPoint = get(axisHandle,'currentpoint');
xdataAnchor = get(DisplayUserdata.anchorHandle,'xdata');
if ~isempty(xdataAnchor)
    ydataAnchor = get(DisplayUserdata.anchorHandle,'ydata');
    [dummy,xpickIndex] = min(abs(xdataAnchor-currentPoint(1,1)));
    switch currentAxisID
        case {2,3,4,5}
            ydataAnchor = exp((log(currentPoint(1,2))-log(ydataAnchor(xpickIndex)))+log(ydataAnchor));
        case {1}
            ydataAnchor = (currentPoint(1,2)-ydataAnchor(xpickIndex))+ydataAnchor;
    end;
    set(DisplayUserdata.anchorHandle,'xdata',xdataAnchor,'ydata',ydataAnchor);
    timeF0 = STRAIGHTCTLObject.refinedF0Structure.temporalPositions;
    %xStartIndex = find(timeF0==xdataAnchor(1));
    %xEndIndex = find(timeF0==xdataAnchor(end));
    xdataKnob = get(knobHandle,'xdata');
    ydataKnob = get(knobHandle,'ydata');
    transitionPopupString = get(handles.transitionLengthPopup,'string');
    transitionWidth = eval(transitionPopupString{...
        get(handles.transitionLengthPopup,'value')})/1000;
    timePrefix = xdataKnob((xdataKnob>xdataAnchor(1)-transitionWidth)&...
        (xdataKnob<=xdataAnchor(1)));
    timeBody = xdataKnob((xdataKnob>xdataAnchor(1))&...
        (xdataKnob<xdataAnchor(end)));
    timePostfix= xdataKnob((xdataKnob>=xdataAnchor(end))&...
        (xdataKnob<xdataAnchor(end)+transitionWidth));
    ydataAnchor = ydataAnchor(:)';
    if  ~isempty(timeBody)
        ydataKnob((xdataKnob>xdataAnchor(1))&...
            (xdataKnob<xdataAnchor(end))) = ydataAnchor(2:end-1);
    end;
    if ~isempty(timePrefix)
        ydataPrefix = ydataKnob((xdataKnob>xdataAnchor(1)-transitionWidth)&...
            (xdataKnob<=xdataAnchor(1)));
        switch currentAxisID
            case {2,3,4,5}
                edge = log(ydataAnchor(1))-log(ydataPrefix(end));
                ydataPrefix = exp(log(ydataPrefix)+...
                    edge*(0.5+0.5*cos(pi*(timePrefix-xdataAnchor(1))/transitionWidth)));
            case {1}
                edge = ydataAnchor(1)-ydataPrefix(end);
                ydataPrefix = ydataPrefix+...
                    edge*(0.5+0.5*cos(pi*(timePrefix-xdataAnchor(1))/transitionWidth));
        end;
        ydataKnob((xdataKnob>xdataAnchor(1)-transitionWidth)&...
            (xdataKnob<=xdataAnchor(1))) = ydataPrefix;
    end;
    if ~isempty(timePostfix)
        ydataPostfix = ydataKnob((xdataKnob<xdataAnchor(end)+transitionWidth)&...
            (xdataKnob>=xdataAnchor(end)));
        switch currentAxisID
            case {2,3,4,5}
                edge = log(ydataAnchor(end))-log(ydataPostfix(1));
                ydataPostfix = exp(log(ydataPostfix)+...
                    edge*(0.5+0.5*cos(pi*(timePostfix-xdataAnchor(end))/transitionWidth)));
            case {1}
                edge = ydataAnchor(end)-ydataPostfix(1);
                ydataPostfix = ydataPostfix+...
                    edge*(0.5+0.5*cos(pi*(timePostfix-xdataAnchor(end))/transitionWidth));
        end;
        ydataKnob((xdataKnob<xdataAnchor(end)+transitionWidth)&...
            (xdataKnob>=xdataAnchor(end))) = ydataPostfix;
    end;
    set(knobHandle,'ydata',ydataKnob);
end;
return;

function STRAIGHTCTLObject = generateActiveF0Handle(STRAIGHTCTLObject,handles)
axisPosition = get(gca,'position');
F0userdata = get(handles.F0Display,'userdata');
if isfield(F0userdata,'line')
    set(F0userdata.line,'color','c','linewidth',1);
end;
finalRectangle = rbbox;
normalizedRectangle = ...
    [(finalRectangle(1:2)-axisPosition(1:2))./axisPosition(3:4) ...
    finalRectangle(3:4)./axisPosition(3:4)];
%plotHandle = STRAIGHTCTLObject.F0Knob;%
%eval(['mSubstrate.' mSubstrate.knobNames{targetID} '.plot']);
xlimit = get(gca,'xlim');
xRange = xlimit(2)-xlimit(1);
ylimit = get(gca,'ylim');
yRange = log(ylimit(2))-log(ylimit(1));
xmin = normalizedRectangle(1)*xRange+xlimit(1);
xmax = (normalizedRectangle(1)+normalizedRectangle(3))*xRange+xlimit(1);
ymin = exp(normalizedRectangle(2)*yRange+log(ylimit(1)));
ymax = exp((normalizedRectangle(2)+normalizedRectangle(4))*yRange+log(ylimit(1)));
userData = get(gca,'userdata');
userData.limitBox = [xmin xmax ymin ymax];
set(gca,'userdata',userData);
makeNewPenHandle(handles);
return;

function displayRefocusCallback(src,evnt)
userData = get(src,'userData');
targetID = userData.knobID;
handles = userData.handles;
STRAIGHTCTLObject = get(handles.STRAIGHTmaniuplatorBase,'userdata');
STRAIGHTCTLObject = multiSliderAxesShaping(STRAIGHTCTLObject,targetID);
if isfield(STRAIGHTCTLObject,'activeHandle')
    if ~isempty(STRAIGHTCTLObject.activeHandle)
        switch userData.knobID
            case 2
                set(handles.STRAIGHTmaniuplatorBase,...
                    'WindowButtonUpFcn',@F0WindowButtonUpCallback);
                set(handles.STRAIGHTmaniuplatorBase,...
                    'WindowButtonMotionFcn',@F0WindowButtonMotionCallback);
                set(handles.STRAIGHTmaniuplatorBase,'userdata',STRAIGHTCTLObject);
                F0WindowButtonMotionCallback(src,evnt);
            otherwise
                set(handles.STRAIGHTmaniuplatorBase,...
                    'WindowButtonUpFcn',@genericWindowButtonUpCallback);
                set(handles.STRAIGHTmaniuplatorBase,...
                    'WindowButtonMotionFcn',@genericWindowButtonMotionCallback);
                set(handles.STRAIGHTmaniuplatorBase,'userdata',STRAIGHTCTLObject);
                genericWindowButtonMotionCallback(src,evnt);
        end;
    end;
end;
%set(handles.STRAIGHTmaniuplatorBase,'userdata',STRAIGHTCTLObject);

function F0WindowButtonUpCallback(src,evnt)
%disp('F0WindowButtonUpCallback')
STRAIGHTCTLObject = get(src,'userdata');
handles = STRAIGHTCTLObject.currentHandles;
set(src,'WindowButtonUpFcn','')
set(src,'WindowButtonMotionFcn',@defaultButtonMotionCallBack)
set(handles.output,'pointer','arrow')
switch get(handles.PenButton1,'value')
    case 1
        makeNewPenHandle(handles);
    case 0
        %makeNewPenHandle(handles);
end;
F0anchorMotion_Callback(handles.output,1);
defaultButtonMotionCallBack(src,evnt);
return;

function makeNewPenHandle(handles)
STRAIGHTCTLObject = get(handles.STRAIGHTmaniuplatorBase,'userdata');
F0userdata = get(handles.F0Display,'userdata');
if isfield(F0userdata,'anchorHandle')
    if ishandle(F0userdata.anchorHandle)
        delete(F0userdata.anchorHandle);
        F0userdata = rmfield(F0userdata,'anchorHandle');
    end;
end;
xdataF0knob = get(STRAIGHTCTLObject.F0Knob,'xdata');
ydataF0knob = get(STRAIGHTCTLObject.F0Knob,'ydata');
gotCurrentObject = gco;
if isempty(gotCurrentObject)
    gotCurrentObject = handles.F0Display;
end;
if (gotCurrentObject ~= STRAIGHTCTLObject.F0Knob) || ...
        strcmp(STRAIGHTCTLObject.currentKey,'alt')
    %disp('line 727')
    %get(gco,'userdata')
    if get(handles.PenButton1,'value') == 1
        [xdataPenSort,indexSorted] = sort(F0userdata.xdata);
        ydataPenSort = F0userdata.ydata(indexSorted);
        indexAnchor = 1:length(xdataF0knob);
        indexAnchor = indexAnchor((xdataF0knob>=xdataPenSort(1))&...
            (xdataF0knob<=xdataPenSort(end)));
        xdataAnchor = xdataF0knob(indexAnchor);
        for ii = 2:length(xdataPenSort)
            if xdataPenSort(ii) == xdataPenSort(ii-1)
                xdataPenSort(ii-1) = 0;
            end;
        end;
        ydataPenSort = ydataPenSort(xdataPenSort>0);
        xdataPenSort = xdataPenSort(xdataPenSort>0);
        ydataAnchor = interp1(xdataPenSort,ydataPenSort,xdataAnchor,'linear','extrap');
    else
        if isfield(F0userdata,'limitBox')
            limitBox = F0userdata.limitBox;
            xdataAnchor = xdataF0knob((xdataF0knob>=limitBox(1))&...
                ((xdataF0knob<=limitBox(2))));
            ydataAnchor = ydataF0knob((xdataF0knob>=limitBox(1))&...
                ((xdataF0knob<=limitBox(2))));
        else
            return;
        end;
    end;
else
    xdataAnchor = xdataF0knob;
    ydataAnchor = ydataF0knob;
end;
F0userdata.anchorHandle = line('xdata',xdataAnchor,'ydata',ydataAnchor,...
    'linewidth',5,'color','g');
set(F0userdata.anchorHandle,'ButtonDownFcn',@F0anchorButtonDnFcn);
%set(STRAIGHTCTLObject.F0Knob,'ButtonDownFcn',@F0anchorButtonDnFcn);
%set(handles.STRAIGHTmaniuplatorBase,'userdata',STRAIGHTCTLObject);
set(F0userdata.anchorHandle,'userdata',handles);
set(handles.F0Display,'userdata',F0userdata);
set(handles.saveResultsButton,'enable','off');
set(handles.rePlayButton,'enable','off');
set(handles.replayVisibleButton,'enable','off');
return;

function F0anchorButtonDnFcn(src,evnt)
handles = get(src,'userdata');
STRAIGHTCTLObject = get(handles.STRAIGHTmaniuplatorBase,'userdata');
%get(get(get(src,'parent'),'parent'),'tag')
switch STRAIGHTCTLObject.currentKey
    case 'alt'
        axisHandle = eval(['handles.' ...
            STRAIGHTCTLObject.axisNames{STRAIGHTCTLObject.currentAxisID}]);
        displayRefocusCallback(axisHandle,evnt);
        return;
end;
set(handles.STRAIGHTmaniuplatorBase,'WindowButtonUpFcn',@F0anchorUp_Callback);
set(handles.STRAIGHTmaniuplatorBase,'WindowButtonMotionFcn',@F0anchorMotion_Callback);
%set(handles.STRAIGHTmaniuplatorBase,'pointer','circle');
setPointerShape(3); % hand shape
F0anchorMotion_Callback(handles.output,1);
return;

function F0anchorUp_Callback(src,evnt)
STRAIGHTCTLObject = get(src,'userdata');
handles = STRAIGHTCTLObject.currentHandles;
F0userdata = get(handles.F0Display,'userdata');
%if ishandle(F0userdata.anchorHandle)
%delete(F0userdata.anchorHandle);
%end;
%F0userdata = rmfield(F0userdata,'anchorHandle');
set(handles.F0Display,'userdata',F0userdata);
set(src,'WindowButtonUpFcn','')
set(src,'WindowButtonMotionFcn',@defaultButtonMotionCallBack)
set(handles.output,'pointer','arrow')
set(handles.saveResultsButton,'enable','off');
set(handles.rePlayButton,'enable','off');
set(handles.replayVisibleButton,'enable','off');
return;

function F0anchorMotion_Callback(src,evnt)
STRAIGHTCTLObject = get(src,'userdata');
handles = STRAIGHTCTLObject.currentHandles;
F0userdata = get(handles.F0Display,'userdata');
currentPoint = get(handles.F0Display,'currentpoint');
xdataAnchor = get(F0userdata.anchorHandle,'xdata');
if ~isempty(xdataAnchor)
    ydataAnchor = get(F0userdata.anchorHandle,'ydata');
    [dummy,xpickIndex] = min(abs(xdataAnchor-currentPoint(1,1)));
    ydataAnchor = exp((log(currentPoint(1,2))-log(ydataAnchor(xpickIndex)))+log(ydataAnchor));
    set(F0userdata.anchorHandle,'xdata',xdataAnchor,'ydata',ydataAnchor);
    timeF0 = STRAIGHTCTLObject.refinedF0Structure.temporalPositions;
    %xStartIndex = find(timeF0==xdataAnchor(1));
    %xEndIndex = find(timeF0==xdataAnchor(end));
    xdataKnob = get(STRAIGHTCTLObject.F0Knob,'xdata');
    ydataKnob = get(STRAIGHTCTLObject.F0Knob,'ydata');
    transitionPopupString = get(handles.transitionLengthPopup,'string');
    transitionWidth = eval(transitionPopupString{...
        get(handles.transitionLengthPopup,'value')})/1000;
    timePrefix = xdataKnob((xdataKnob>xdataAnchor(1)-transitionWidth)&...
        (xdataKnob<=xdataAnchor(1)));
    timeBody = xdataKnob((xdataKnob>xdataAnchor(1))&...
        (xdataKnob<xdataAnchor(end)));
    timePostfix= xdataKnob((xdataKnob>=xdataAnchor(end))&...
        (xdataKnob<xdataAnchor(end)+transitionWidth));
    ydataAnchor = ydataAnchor(:)';
    if  ~isempty(timeBody)
        ydataKnob((xdataKnob>xdataAnchor(1))&...
            (xdataKnob<xdataAnchor(end))) = ydataAnchor(2:end-1);
    end;
    if ~isempty(timePrefix)
        ydataPrefix = ydataKnob((xdataKnob>xdataAnchor(1)-transitionWidth)&...
            (xdataKnob<=xdataAnchor(1)));
        edge = log(ydataAnchor(1))-log(ydataPrefix(end));
        ydataPrefix = exp(log(ydataPrefix)+...
            edge*(0.5+0.5*cos(pi*(timePrefix-xdataAnchor(1))/transitionWidth)));
        ydataKnob((xdataKnob>xdataAnchor(1)-transitionWidth)&...
            (xdataKnob<=xdataAnchor(1))) = ydataPrefix;
    end;
    if ~isempty(timePostfix)
        ydataPostfix = ydataKnob((xdataKnob<xdataAnchor(end)+transitionWidth)&...
            (xdataKnob>=xdataAnchor(end)));
        edge = log(ydataAnchor(end))-log(ydataPostfix(1));
        ydataPostfix = exp(log(ydataPostfix)+...
            edge*(0.5+0.5*cos(pi*(timePostfix-xdataAnchor(end))/transitionWidth)));
        ydataKnob((xdataKnob<xdataAnchor(end)+transitionWidth)&...
            (xdataKnob>=xdataAnchor(end))) = ydataPostfix;
    end;
    if ~isempty(ydataKnob)
        set(STRAIGHTCTLObject.F0Knob,'ydata',ydataKnob);
    end;
end;
return;

function F0WindowButtonMotionCallback(src,evnt)
%disp('F0WindowButtonMotionCallback')
userdata = get(src,'userdata');
handles = userdata.currentHandles;
currentPoint = get(handles.F0Display,'currentpoint');
F0userdata = get(handles.F0Display,'userdata');
F0userdata.xdata = [F0userdata.xdata currentPoint(1,1)];
F0userdata.ydata = [F0userdata.ydata currentPoint(1,2)];
set(F0userdata.line,'xdata',F0userdata.xdata,'ydata',F0userdata.ydata);
set(handles.F0Display,'userdata',F0userdata);
return;

function genericWindowButtonMotionCallback(src,evnt)
%disp('F0WindowButtonMotionCallback')
userdata = get(src,'userdata');
currentID = userdata.currentAxisID;
handles = userdata.currentHandles;
displayHandle = eval(['handles.' userdata.axisNames{currentID}]);
currentPoint = get(displayHandle,'currentpoint');
displayUserdata = get(displayHandle,'userdata');
displayUserdata.xdata = [displayUserdata.xdata currentPoint(1,1)];
displayUserdata.ydata = [displayUserdata.ydata currentPoint(1,2)];
set(displayUserdata.line,'xdata',displayUserdata.xdata,'ydata',displayUserdata.ydata);
set(displayHandle,'userdata',displayUserdata);
return;

function toolSelectorPanel_callback(src,evnt)
handles = get(src,'userdata');
targetID = 2;
STRAIGHTCTLObject = get(handles.STRAIGHTmaniuplatorBase,'userdata');
%STRAIGHTCTLObject = multiSliderAxesShaping(STRAIGHTCTLObject,targetID);
%set(handles.STRAIGHTmaniuplatorBase,'userdata',STRAIGHTCTLObject)
return;
handles = get(src,'userdata');
targetID = 2;
STRAIGHTCTLObject = get(handles.STRAIGHTmaniuplatorBase,'userdata');
if STRAIGHTCTLObject.currentAxisID == targetID
    switch targetID
        case 2
            if get(handles.PenButton1,'value') == 1
                STRAIGHTCTLObject = ...
                    generateF0PenHandle(STRAIGHTCTLObject,handles);
            else
                STRAIGHTCTLObject = ...
                    generateActiveF0Handle(STRAIGHTCTLObject,handles);
            end;
    end;
end;
set(handles.STRAIGHTmaniuplatorBase,'userdata',STRAIGHTCTLObject);
userData = get(handles.F0Display,'userdata');
%F0anchorMotion_Callback(STRAIGHTCTLObject.,1)
return;

% --- Executes on button press in eraseButton.
function eraseButton_Callback(hObject, eventdata, handles)
% hObject    handle to eraseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTCTLObject = get(handles.output,'userdata');
currentAxisID = STRAIGHTCTLObject.currentAxisID;
knobHandle = eval(['STRAIGHTCTLObject.' STRAIGHTCTLObject.knobNames{currentAxisID}]);
switch currentAxisID
    case 1 % Power
        logPower = ...
            10*log10(sum(STRAIGHTCTLObject.SpectrumStructure.spectrogramSTRAIGHT));
        set(knobHandle,'ydata',logPower);
    case 2 % F0
        f0 = STRAIGHTCTLObject.refinedF0Structure.f0;
        set(STRAIGHTCTLObject.F0Knob,'ydata',f0);
        F0userdata = get(handles.F0Display,'userdata');
        if 1 == 2
            if isfield(F0userdata,'linesInLineList')
                for ii = F0userdata.linesInLineList:-1:1
                    delete(F0userdata.lineList(ii).lastLine);
                end;
                F0userdata = rmfield(F0userdata,'lineList');
                F0userdata = rmfield(F0userdata,'linesInLineList');
            end;
            if isfield(F0userdata,'line')
                delete(F0userdata.line);
                F0userdata = rmfield(F0userdata,'line');
            end;
            set(handles.F0Display,'userdata',F0userdata);
        end;
    case 3 % Size
        sizeMagnifier = ...
            STRAIGHTCTLObject.SpectrumStructure.temporalPositions*0+1;
        set(knobHandle,'ydata',sizeMagnifier);
    case 4 % Duration
        durationMagnifier = ...
            STRAIGHTCTLObject.SpectrumStructure.temporalPositions*0+1;
        set(knobHandle,'ydata',durationMagnifier);
    case 5 % Aperiodicity
        aperiodicityMagnifier = ...
            STRAIGHTCTLObject.SpectrumStructure.temporalPositions*0+1;
        set(knobHandle,'ydata',aperiodicityMagnifier);
end
axisHandle = eval(['handles.' STRAIGHTCTLObject.axisNames{currentAxisID}]);
axisUserData = get(axisHandle,'userdata');
if isfield(axisUserData,'linesInLineList')
    for ii = axisUserData.linesInLineList:-1:1
        delete(axisUserData.lineList(ii).lastLine);
    end;
    axisUserData = rmfield(axisUserData,'lineList');
    axisUserData = rmfield(axisUserData,'linesInLineList');
end;
if isfield(axisUserData,'line')
    delete(axisUserData.line);
    axisUserData = rmfield(axisUserData,'line');
end;
set(axisHandle,'userdata',axisUserData);
set(handles.saveResultsButton,'enable','off');
set(handles.rePlayButton,'enable','off');
set(handles.replayVisibleButton,'enable','off');
set(hObject,'KeyPressFcn',@uiKeyPress);
return;

% --- Executes on selection change in transitionLengthPopup.
function transitionLengthPopup_Callback(hObject, eventdata, handles)
% hObject    handle to transitionLengthPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'KeyPressFcn',@uiKeyPress);
% Hints: contents = get(hObject,'String') returns transitionLengthPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from transitionLengthPopup


% --- Executes during object creation, after setting all properties.
function transitionLengthPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to transitionLengthPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SynthesizeButton.
function SynthesizeButton_Callback(hObject, eventdata, handles)
% hObject    handle to SynthesizeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTobject = get(handles.output,'userdata');
STRAIGHTobject.manipulationMetaData.SynthesisDate = datestr(now,30);
fs = STRAIGHTobject.samplingFrequency;
%------ F0 modification ----
modifiedF0 = get(STRAIGHTobject.F0Knob,'ydata');
AperiodicityStructure = STRAIGHTobject.AperiodicityStructure;
AperiodicityStructure.f0 = modifiedF0(:);
%------ power modification -----
modifiedPower = get(STRAIGHTobject.PowerKnob,'ydata');
logPower = ...
    10*log10(sum(STRAIGHTobject.SpectrumStructure.spectrogramSTRAIGHT));
powerModifier = 10.0.^((modifiedPower-logPower)/10);
%------ spectral axis (size) modification ----
nFrames = length(modifiedF0);
SpectrumStructure = STRAIGHTobject.SpectrumStructure;
baseFrequency = (0:size(SpectrumStructure.spectrogramSTRAIGHT,1)-1)/...
    (size(SpectrumStructure.spectrogramSTRAIGHT,1)-1)/2*fs;
sizeModifier = get(STRAIGHTobject.SizeKnob,'ydata');
for ii = 1:nFrames
    SpectrumStructure.spectrogramSTRAIGHT(:,ii) = powerModifier(ii)*interp1( ...
        baseFrequency,SpectrumStructure.spectrogramSTRAIGHT(:,ii),...
        baseFrequency*sizeModifier(ii),'linear',SpectrumStructure.spectrogramSTRAIGHT(end,ii));
end;
%figure;plot(STRAIGHTobject.AperiodicityStructure.f0);hold all;
%plot(modifiedF0);
%hold off;
%----- duration modification ----
durationModifier = get(STRAIGHTobject.DurationKnob,'ydata');
AperiodicityStructure.temporalPositions = ...
    modifyTimeBase(AperiodicityStructure.temporalPositions,durationModifier);
SpectrumStructure.temporalPositions = ...
    AperiodicityStructure.temporalPositions;
%----- synthesis body -----
set(gcf,'Pointer','watch');drawnow;
STRAIGHTobject.SynthesisStructure = ...
    exGeneralSTRAIGHTsynthesisR2(AperiodicityStructure,SpectrumStructure);
    %exTandemSTRAIGHTsynthNx(AperiodicityStructure,SpectrumStructure);
set(gcf,'Pointer','arrow');drawnow;
%----- playback sound ----
outputSignal = STRAIGHTobject.SynthesisStructure.synthesisOut/ ...
    max(abs(STRAIGHTobject.SynthesisStructure.synthesisOut))*0.95;
sound(outputSignal,STRAIGHTobject.samplingFrequency);
set(handles.rePlayButton,'enable','on');
set(handles.replayVisibleButton,'enable','on');
set(handles.saveResultsButton,'enable','on');
%----- assign metadata ----
manipulationMetaData.originalSTRAIGHTobject = ...
    STRAIGHTobject.dataFileName;
STRAIGHTobject.manipulationMetaData = manipulationMetaData;
STRAIGHTobject.manipulationMetaData.originalPath = ...
    STRAIGHTobject.dataDirectory;
if isfield(STRAIGHTobject,'objectFile')
    STRAIGHTobject.manipulationMetaData.objectFile = ...
        STRAIGHTobject.objectFile;
    STRAIGHTobject.manipulationMetaData.objectDirectory = ...
        STRAIGHTobject.objectDirectory;
end;
STRAIGHTobject.manipulationMetaData.temporalPositions = ...
    STRAIGHTobject.SpectrumStructure.temporalPositions;
STRAIGHTobject.manipulationMetaData.modifiedTemporalPositions = ...
    SpectrumStructure.temporalPositions;
STRAIGHTobject.manipulationMetaData.durationModifier = durationModifier;
STRAIGHTobject.manipulationMetaData.modifiedF0 = modifiedF0;
STRAIGHTobject.manipulationMetaData.sizeModifier = sizeModifier;
STRAIGHTobject.manipulationMetaData.powerModifier = powerModifier;
set(handles.output,'userdata',STRAIGHTobject);
set(hObject,'KeyPressFcn',@uiKeyPress);

function updatedTemporalPositions = ...
    modifyTimeBase(temporalPositions,durationModifier)
segmentDurations = diff(temporalPositions);
durationModifierReal = (durationModifier(1:end-1)+durationModifier(2:end))/2;
updatedTemporalPositions = ...
    cumsum([temporalPositions(1); segmentDurations(:).*durationModifierReal(:)])';
return;

function ideleWindowMotion_callback(src,evnt)
STRAIGHTobject = get(src,userdata);
handles = STRAIGHTobject.currentHandles;
currentID = STRAIGHTobject.currentAxisID;
displayHandle = eval(['handles.' userdata.axisNames{currentID}]);
currentPoint = get(displayHandle,'currentpoint');
displayUserdata = get(displayHandle,'userdata');
displayUserdata.xdata = [displayUserdata.xdata currentPoint(1,1)];
displayUserdata.ydata = [displayUserdata.ydata currentPoint(1,2)];
return;


% --- Executes on button press in rePlayButton.
function rePlayButton_Callback(hObject, eventdata, handles)
% hObject    handle to rePlayButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTobject = get(handles.output,'userdata');
outputSignal = STRAIGHTobject.SynthesisStructure.synthesisOut/ ...
    max(abs(STRAIGHTobject.SynthesisStructure.synthesisOut))*0.95;
sound(outputSignal,STRAIGHTobject.samplingFrequency);
set(hObject,'KeyPressFcn',@uiKeyPress);

% --- Executes on button press in saveResultsButton.
function saveResultsButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveResultsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTobject = get(handles.output,'userdata');
manipulationMetaData = STRAIGHTobject.manipulationMetaData;
manipulationMetaData.SynthesisStructure = STRAIGHTobject.SynthesisStructure;
outFileName = ['modSynth' datestr(now,30) '.mat'];
[file,path] = uiputfile(outFileName,'Save the modification record');
if length(file) == 1 && length(path) == 1
    if file == 0 || path == 0
        okInd = 0;
        disp('Save is cancelled!');
        return;
    end;
end;
%pathReg = regexprep(path,'\s','\\ ');
%eval(['save ' pathReg file ' STRAIGHTobject']);
save([path file],'manipulationMetaData');
if ~isempty(strfind(file,'.mat'))
    lastPosition = strfind(file,'.mat');
    lastPosition = lastPosition(end);
    fileRoot = file(1:lastPosition-1);
else
    fileRoot = fileRoot;
end
outputSignal = STRAIGHTobject.SynthesisStructure.synthesisOut/ ...
    max(abs(STRAIGHTobject.SynthesisStructure.synthesisOut))*0.95;
audiowrite([path fileRoot '.wav'],outputSignal,STRAIGHTobject.samplingFrequency);
set(hObject,'KeyPressFcn',@uiKeyPress);

% --- Executes on button press in zoomInButton.
function zoomInButton_Callback(hObject, eventdata, handles)
% hObject    handle to zoomInButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTCTLObject = get(handles.STRAIGHTmaniuplatorBase,'userdata');
zoomInXaxis(STRAIGHTCTLObject,handles);
set(hObject,'KeyPressFcn',@uiKeyPress);
return;

function zoomInXaxis(CTRLObject,handles)
axisNames = CTRLObject.axisNames;
xLimit = get(handles.Spectrogram,'xlim');
xCenter = (xLimit(1)+xLimit(2))/2;
xLength = xLimit(2)-xLimit(1);
newXLimit = [xCenter-xLength/2/sqrt(2)  xCenter+xLength/2/sqrt(2)];
set(handles.Spectrogram,'xlim',newXLimit);
for ii = 1:5
    currentHandle = eval(['handles.' axisNames{ii}]);
    set(currentHandle,'xlim',newXLimit);
end;
return;

% --- Executes on button press in zoomOutButton.
function zoomOutButton_Callback(hObject, eventdata, handles)
% hObject    handle to zoomOutButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTCTLObject = get(handles.STRAIGHTmaniuplatorBase,'userdata');
timeAxis = STRAIGHTCTLObject.SpectrumStructure.temporalPositions;
axisNames = STRAIGHTCTLObject.axisNames;
xLimit = get(handles.Spectrogram,'xlim');
xCenter = (xLimit(1)+xLimit(2))/2;
xLength = xLimit(2)-xLimit(1);
dataLength = timeAxis(end)-timeAxis(1);
newLength = min(dataLength,xLength*sqrt(2));
newXLimit = [max(timeAxis(1),xCenter-newLength/2) ...
    min(timeAxis(end),xCenter+newLength/2)];
set(handles.Spectrogram,'xlim',newXLimit);
for ii = 1:5
    currentHandle = eval(['handles.' axisNames{ii}]);
    set(currentHandle,'xlim',newXLimit);
end;
set(hObject,'KeyPressFcn',@uiKeyPress);
return;

% --- Executes on button press in fullZoomOutButton.
function fullZoomOutButton_Callback(hObject, eventdata, handles)
% hObject    handle to fullZoomOutButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTCTLObject = get(handles.STRAIGHTmaniuplatorBase,'userdata');
fs = STRAIGHTCTLObject.samplingFrequency;
timeAxis = STRAIGHTCTLObject.SpectrumStructure.temporalPositions;
axisNames = STRAIGHTCTLObject.axisNames;
newXLimit = [timeAxis(1) timeAxis(end)];
set(handles.Spectrogram,'xlim',newXLimit);
set(handles.Spectrogram,'ylim',[0 min([6000,fs/2])]);
for ii = 1:5
    currentHandle = eval(['handles.' axisNames{ii}]);
    set(currentHandle,'xlim',newXLimit);
end;
set(hObject,'KeyPressFcn',@uiKeyPress);


function spectrogramButtonDn_callback(src,evnt)
%disp('Sgram is clicked!')
handles = get(src,'userdata');
STRAIGHTCTLObject = get(handles.STRAIGHTmaniuplatorBase,'userdata');
%handles = STRAIGHTCTLObject.currentHandles;
timeAxis = STRAIGHTCTLObject.SpectrumStructure.temporalPositions;
fs = STRAIGHTCTLObject.samplingFrequency;
axisNames = STRAIGHTCTLObject.axisNames;
switch STRAIGHTCTLObject.currentKey
    case 'alt'
        axisPosition = get(handles.Spectrogram,'position');
        xlimit = get(handles.Spectrogram,'xlim');
        ylimit = get(handles.Spectrogram,'ylim');
        finalRectangle = rbbox;
        normalizedRectangle = ...
            [(finalRectangle(1:2)-axisPosition(1:2))./axisPosition(3:4) ...
            finalRectangle(3:4)./axisPosition(3:4)];
        %normalizedRectangle([1 3]) = sort(normalizedRectangle([1 3]));
        %normalizedRectangle([2 4]) = sort(normalizedRectangle([2 4]));
        xRange = xlimit(2)-xlimit(1);
        yRange = ylimit(2)-ylimit(1);
        xmin = normalizedRectangle(1)*xRange+xlimit(1);
        xmax = (normalizedRectangle(1)+normalizedRectangle(3))*xRange+xlimit(1);
        newXlimit = sort(max(timeAxis(1),min(timeAxis(end),[xmin xmax])));
        ymin = normalizedRectangle(2)*yRange+ylimit(1);
        ymax = (normalizedRectangle(2)+normalizedRectangle(4))*yRange+ylimit(1);
        newYlimit = sort(max(0,min(fs/2,[ymin ymax])));
        if diff(newXlimit) == 0;return;end;
        if diff(newYlimit) == 0;return;end;
        set(handles.Spectrogram,'xlim',newXlimit);
        set(handles.Spectrogram,'ylim',newYlimit);
        for ii = 1:5
            currentHandle = eval(['handles.' axisNames{ii}]);
            set(currentHandle,'xlim',[xmin, xmax]);
        end;
        return;
end;
set(handles.STRAIGHTmaniuplatorBase,'WindowButtonUpFcn',@sgramButtonUpCallback);
set(handles.STRAIGHTmaniuplatorBase,'WindowButtonMotionFcn',@sgramButtonMoveCallback);
%set(handles.STRAIGHTmaniuplatorBase,'pointer','crosshair');
currentPoint = get(gca,'currentpoint');
STRAIGHTCTLObject.timeHook = currentPoint(1,1);
STRAIGHTCTLObject.frequencyHook = currentPoint(1,2);
set(handles.STRAIGHTmaniuplatorBase,'userdata',STRAIGHTCTLObject);
setPointerShape(3); % hand shape
return;

function sgramButtonUpCallback(src,evnt)
STRAIGHTCTLObject = get(src,'userdata');
handles = STRAIGHTCTLObject.currentHandles;
set(handles.STRAIGHTmaniuplatorBase,'WindowButtonUpFcn','');
set(handles.STRAIGHTmaniuplatorBase,'WindowButtonMotionFcn',@defaultButtonMotionCallBack);
set(handles.STRAIGHTmaniuplatorBase,'pointer','arrow');
return;

function sgramButtonMoveCallback(src,evnt)
STRAIGHTCTLObject = get(src,'userdata');
handles = STRAIGHTCTLObject.currentHandles;
fs = STRAIGHTCTLObject.samplingFrequency;
timeAxis = STRAIGHTCTLObject.SpectrumStructure.temporalPositions;
axisNames = STRAIGHTCTLObject.axisNames;
currentPoint = get(handles.Spectrogram,'currentpoint');
displacement = currentPoint(1,1)-STRAIGHTCTLObject.timeHook;
displacementY = currentPoint(1,2)-STRAIGHTCTLObject.frequencyHook;
xLimit = get(handles.Spectrogram,'xlim');
newXLimit = xLimit-displacement;
if newXLimit(1) < timeAxis(1)
    newXLimit = newXLimit+(timeAxis(1)-newXLimit(1));
end;
if newXLimit(2) > timeAxis(end);
    newXLimit = newXLimit+(timeAxis(end)-newXLimit(2));
end;
yLimit = get(handles.Spectrogram,'ylim');
newYLimit = yLimit-displacementY;
%if (newXLimit(1)>timeAxis(1)) & ...
%        (newXLimit(2)<timeAxis(end))
set(handles.Spectrogram,'xlim',newXLimit);
if newYLimit(1) < 0;newYLimit = newYLimit+(0-newYLimit(1));end;
if newYLimit(2) > fs/2;newYLimit = newYLimit+(fs/2-newYLimit(2));end;
set(handles.Spectrogram,'ylim',newYLimit);
for ii = 1:5
    currentHandle = eval(['handles.' axisNames{ii}]);
    set(currentHandle,'xlim',newXLimit);
end;
%end;
return;


% --- Executes on selection change in spectrogramColormap.
function spectrogramColormap_Callback(hObject, eventdata, handles)
% hObject    handle to spectrogramColormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTCTLObject = get(handles.STRAIGHTmaniuplatorBase,'userdata');
colorMapID = get(hObject,'value');
switch colorMapID
    case 1
        set(handles.STRAIGHTmaniuplatorBase,'colormap',1-gray);
    case 2
        set(handles.STRAIGHTmaniuplatorBase,'colormap',jet);
end;
set(hObject,'KeyPressFcn',@uiKeyPress);
% Hints: contents = get(hObject,'String') returns spectrogramColormap contents as cell array
%        contents{get(hObject,'Value')} returns selected item from spectrogramColormap


% --- Executes during object creation, after setting all properties.
function spectrogramColormap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spectrogramColormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function STRAIGHTmaniuplatorBase_Callback(src,evnt)
STRAIGHTCTLObject = get(src,'userdata');
handles = STRAIGHTCTLObject.currentHandles;
get(src)
return;

% --- Executes on button press in playOriginalButton.
function playOriginalButton_Callback(hObject, eventdata, handles)
% hObject    handle to playOriginalButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTCTLObject = get(handles.STRAIGHTmaniuplatorBase,'userdata');
x = STRAIGHTCTLObject.waveform;
maxLevel = max(abs(x(:)));
sound(x/maxLevel*0.95,STRAIGHTCTLObject.samplingFrequency);
set(hObject,'KeyPressFcn',@uiKeyPress);
return;

function uiKeyPress(src,evnt)
switch get(src,'tag')
    case 'STRAIGHTmaniuplatorBase'
        keyPressCallBack(src,evnt);
    otherwise
        uiKeyPress(get(src,'parent'),evnt);
end;
return;


% --- Executes on button press in playVisibleButton.
function playVisibleButton_Callback(hObject, eventdata, handles)
% hObject    handle to playVisibleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTCTLObject = get(handles.STRAIGHTmaniuplatorBase,'userdata');
x = STRAIGHTCTLObject.waveform;
xLimit = get(handles.Spectrogram,'xlim');
fs = STRAIGHTCTLObject.samplingFrequency;
initialIndex = max(1,round(xLimit(1)*fs));
finalIndex = min(length(x),round(xLimit(2)*fs));
x = x(initialIndex:finalIndex);
maxLevel = max(abs(x(:)));
sound(x/maxLevel*0.95,fs);
set(hObject,'KeyPressFcn',@uiKeyPress);


% --- Executes on button press in replayVisibleButton.
function replayVisibleButton_Callback(hObject, eventdata, handles)
% hObject    handle to replayVisibleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTobject = get(handles.output,'userdata');
outputSignal = STRAIGHTobject.SynthesisStructure.synthesisOut;
xLimit = get(handles.Spectrogram,'xlim');
fs = STRAIGHTobject.samplingFrequency;
initialIndex = max(1,round(xLimit(1)*fs));
finalIndex = min(length(outputSignal),round(xLimit(2)*fs));
x = outputSignal(initialIndex:finalIndex);
maxLevel = max(abs(x(:)));
sound(x/maxLevel*0.95,fs);
set(hObject,'KeyPressFcn',@uiKeyPress);
