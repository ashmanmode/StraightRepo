function varargout = f0ExtractorGUI(varargin)
% F0EXTRACTORGUI M-file for f0ExtractorGUI.fig
%      F0EXTRACTORGUI, by itself, creates a new F0EXTRACTORGUI or raises the existing
%      singleton*.
%
%      H = F0EXTRACTORGUI returns the handle to a new F0EXTRACTORGUI or the handle to
%      the existing singleton*.
%
%      F0EXTRACTORGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in F0EXTRACTORGUI.M with the given input arguments.
%
%      F0EXTRACTORGUI('Property','Value',...) creates a new F0EXTRACTORGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before f0ExtractorGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to f0ExtractorGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help f0ExtractorGUI
% Author Hideki Kawahara
% kawahara@sys.wakayama-u.ac.jp
% Fix dates
% 17/Sept./2015 f0 retouch tool fixed

% Last Modified by GUIDE v2.5 24-Nov-2014 13:21:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @f0ExtractorGUI_OpeningFcn, ...
    'gui_OutputFcn',  @f0ExtractorGUI_OutputFcn, ...
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
end

%   Modified to add playback functionality
%   by Hideki Kawahara
%   24/Nov./2014

% --- Executes just before f0ExtractorGUI is made visible.
function f0ExtractorGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to f0ExtractorGUI (see VARARGIN)

% Choose default command line output for f0ExtractorGUI
handles.output = hObject;

STRAIGHTobject = get(hObject,'userdata');
if ~isempty(STRAIGHTobject) && isfield(STRAIGHTobject,'waveform') && ...
        length(STRAIGHTobject.waveform) > 100
    STRAIGHTobject.creationDate = datestr(now,30);
else
    %    display('No data is given. Please call me with data.');
    [file,path] = uigetfile('*.wav','Select sound file.');
    if length(file) == 1 && length(path) == 1
        if file == 0 || path == 0
            disp('Load is cancelled!');
            return;
        end;
    end;
    [x,fs] = audioread([path file]);
    STRAIGHTobject.creationDate = datestr(now,30);
    STRAIGHTobject.dataDirectory = path;
    STRAIGHTobject.dataFileName = file;
    STRAIGHTobject.samplingFrequency = fs;
    STRAIGHTobject.waveform = x(:,1);
end;
STRAIGHTobject.currentHandles = handles;
%STRAIGHTobject.originalWaveform = STRAIGHTobject.waveform;
%locateTopLeftOfGUI(Top,Left,GUIHandle)
TandemSTRAIGHThandler('locateTopLeftOfGUI',60,40,handles.f0ExtractorGUI);
%handles
%--- configure extractor environment
STRAIGHTobject.f0ExtractorListFile = 'F0extractorsDefinitionList.txt';
STRAIGHTobject = assignF0Extractors(STRAIGHTobject,handles);

STRAIGHTobject = setupInitialDisplay(STRAIGHTobject,handles);
STRAIGHTobject.originalWaveform = STRAIGHTobject.waveform;

%--- set inital status of buttons
set(handles.recalculateButton,'enable','off');
%set(handles.recalculateButton,'visible','off');
set(handles.autoTrackButton,'enable','off');
set(handles.cleanLFnoise,'enable','off');
set(handles.restoreOriginalButton,'enable','off');
set(handles.F0candidateAxis,'visible','off');
set(handles.finishButton,'enable','off');
set(handles.playUnVoicedButton,'enable','off');
set(handles.playVoicedButton,'enable','off');
set(handles.periodicityScoreAxis,'visible','off');
set(handles.automaticLFNoiseCleanerRButton,'Value',1);
set(handles.LFCleanDisableRButton,'Value',0);
set(handles.f0ExtractorGUI,'WindowButtonMotionFcn',@defaultWindowMotionCallback);
set(handles.f0ExtractorGUI,'KeyPressFcn',@keyPressCallBack);
set(handles.f0ExtractorGUI,'KeyReleaseFcn',@keyReleaseCallBack);
STRAIGHTobject.currentKey = 'none';

%handles
set(hObject,'userdata',STRAIGHTobject);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes f0ExtractorGUI wait for user response (see UIRESUME)
% uiwait(handles.f0ExtractorGUI);
end

function keyPressCallBack(src,evnt)
GUIuserData = get(src,'userdata');
GUIuserData.currentKey = evnt.Key;
set(src,'userdata',GUIuserData);
defaultWindowMotionCallback(src,evnt);
return;
end

function keyReleaseCallBack(src,evnt)
GUIuserData = get(src,'userdata');
GUIuserData.currentKey = 'none';
set(src,'userdata',GUIuserData);
defaultWindowMotionCallback(src,evnt);
return;
end

function STRAIGHTobject = assignF0Extractors(STRAIGHTobject,handles)
fid = fopen(STRAIGHTobject.f0ExtractorListFile);
parsedList = textscan(fid,'%q'); % file with quoted words is expected
fclose(fid);
numberOfRecords = length(parsedList{1});
numberOfExtractors = sum(strcmp('#',parsedList{:}));
effectiveExtractors = 0;
itemID = 1;
f0ExtractorNames = cell(numberOfExtractors,1);
f0ExtractorStrings = cell(numberOfExtractors,1);
for ii = 1:numberOfRecords
    if strcmp('#',parsedList{1}{itemID})
        listString = parsedList{1}{itemID+1};
        interfaceName = parsedList{1}{itemID+2};
        functionName = parsedList{1}{itemID+3};
        enableCheck = parsedList{1}{itemID+4};
        switch enableCheck
            case 'on'
                if (exist(functionName) == 2)
                    %disp([listString ' is installed in this system.']);
                    effectiveExtractors = effectiveExtractors+1;
                    f0ExtractorNames{effectiveExtractors} = interfaceName;
                    f0ExtractorStrings{effectiveExtractors} = listString;
                else
                    %disp([listString ' is NOT found!']);
                end;
            case 'off'
            otherwise
        end;
        itemID = itemID+5;
    else
        itemID = itemID+1;
    end;
    if itemID > numberOfRecords
        break;
    end;
end;
f0ExtractorNames = f0ExtractorNames(1:effectiveExtractors);
f0ExtractorStrings = f0ExtractorStrings(1:effectiveExtractors);
if effectiveExtractors > 0
    set(handles.F0extractorPopup,'String',f0ExtractorStrings);
else
    disp('No F0 extractor is available.');
    set(handles.F0extractorPopup,'enable','off');
    return;
end;
STRAIGHTobject.f0ExtractorNames = f0ExtractorNames;
return;
end

function STRAIGHTobject = setupInitialDisplay(STRAIGHTobject,handles)
axes(handles.waveformAxis);
fs = STRAIGHTobject.samplingFrequency;
x = STRAIGHTobject.waveform;
timeAxis = (0:length(x)-1)/fs;
vuvPlusHandle = plot(timeAxis,x*0,'g.-');
hold on;
vuvMinusHandle = plot(timeAxis,x*0,'g.-');
waveformHandle = plot(timeAxis,x);grid on;
hold off;
set(vuvPlusHandle,'visible','off');
set(vuvMinusHandle,'visible','off');
axis([timeAxis(1) timeAxis(end) 1.1*[min(x) max(x)]]);
xlabel('time (s)','fontsize',16);
set(handles.periodicityScoreAxis,'visible','off');
set(handles.F0candidateAxis,'visible','off');
%escapeToParent
STRAIGHTobject.vuvPlusHandle = vuvPlusHandle;
STRAIGHTobject.vuvMinusHandle = vuvMinusHandle;
STRAIGHTobject.waveformHandle = waveformHandle;
return;
end

% --- Outputs from this function are returned to the command line.
function varargout = f0ExtractorGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on selection change in F0extractorPopup.
function F0extractorPopup_Callback(hObject, eventdata, handles)
% hObject    handle to F0extractorPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns F0extractorPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from F0extractorPopup
end

% --- Executes during object creation, after setting all properties.
function F0extractorPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to F0extractorPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end;
end

% --- Executes on button press in calculateButton.
function calculateButton_Callback(hObject, eventdata, handles)
% hObject    handle to calculateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTobject = get(handles.output,'userdata');
set(handles.output,'pointer','watch');
%handles
drawnow;
autoLFClean = get(handles.automaticLFNoiseCleanerRButton,'Value');
f0ExtractorName = ...
    STRAIGHTobject.f0ExtractorNames{get(handles.F0extractorPopup,'value')};
fs = STRAIGHTobject.samplingFrequency;
if autoLFClean
    x = STRAIGHTobject.waveform;
    xClean = blackmanBasedHPF(x,fs,20,1); % This default can be modified 24/April/2013
    xClean = inductionAndLowFrequencyNoizeSuppression(xClean,fs);
    STRAIGHTobject.waveform = xClean;
    set(handles.automaticLFNoiseCleanerRButton,'Value',0);
    set(handles.LFCleanDisableRButton,'Value',1);
    set(handles.restoreOriginalButton,'enable','on');
end;
eval(['f0Structure = ' f0ExtractorName '(STRAIGHTobject.waveform,fs);']);
STRAIGHTobject.f0 = f0Structure.f0;
STRAIGHTobject.periodicityLevel = f0Structure.periodicityLevel;
STRAIGHTobject.temporalPositions = f0Structure.temporalPositions;
STRAIGHTobject.f0CandidatesMap = f0Structure.f0CandidatesMap;
STRAIGHTobject.f0CandidatesScoreMap = f0Structure.f0CandidatesScoreMap;
STRAIGHTobject.f0Structure = f0Structure;
STRAIGHTobject = setupSecondDisplay(STRAIGHTobject,handles);
set(handles.output,'pointer','arrow');
set(handles.output,'userdata',STRAIGHTobject);
set(handles.recalculateButton,'enable','off');
switch f0ExtractorName
    case 'tandemSTRAIGHTF0interface'
        STRAIGHTobject.f0candidatesPowerMap = f0Structure.f0candidatesPowerMap;
        set(handles.output,'userdata',STRAIGHTobject);
        set(handles.autoTrackButton,'enable','on');
end;
set(handles.cleanLFnoise,'enable','on');
set(handles.finishButton,'enable','on');
drawnow;
return;
end

function STRAIGHTobject = setupSecondDisplay(STRAIGHTobject,handles)
set(handles.F0candidateAxis,'visible','on');
axes(handles.F0candidateAxis);
defaultF0Limit = [40 800];
f0Time = STRAIGHTobject.temporalPositions;
f0Plot = semilogy(f0Time,STRAIGHTobject.f0,...
    'color',[0.4 0.85 0.85],'linewidth',6);
grid on;
axis([f0Time(1) f0Time(end) defaultF0Limit]);
hold on;
f0CandidatesPlot = ...
    semilogy(f0Time,STRAIGHTobject.f0CandidatesMap','.','markersize',12);
hold off
set(handles.F0candidateAxis,'xticklabel',[]);
STRAIGHTobject.f0PlotHandle = f0Plot;
STRAIGHTobject.defaultF0Limit = defaultF0Limit;
set(handles.periodicityScoreAxis,'visible','on');
axes(handles.periodicityScoreAxis);
f0CandidatesScoreMap = STRAIGHTobject.f0CandidatesScoreMap;
[scoreHistogram,levels] = hist(f0CandidatesScoreMap(:),20);
scorePlot = plot(f0Time,STRAIGHTobject.periodicityLevel,...
    'linewidth',6,'color',[0.4 0.85 0.85]);
hold on;
candidatesScorePlot = plot(f0Time,f0CandidatesScoreMap','.','markersize',12);
grid on;
defaultScoreLimit = [levels(3) levels(end)+(levels(end)-levels(2))*0.10];
axis([f0Time(1) f0Time(end) defaultScoreLimit]);
set(handles.periodicityScoreAxis,'xticklabel',[]);
hold off;
%--- set handles to userdata of axes and plots
set(handles.waveformAxis,'userdata',handles);
axisUserData.handles = handles;
set(handles.F0candidateAxis,'userdata',axisUserData);
set(handles.periodicityScoreAxis,'userdata',handles);
%--- set button down functions
set(handles.waveformAxis,'ButtonDownFcn',@waveformAxisButtonDownCallback);
set(handles.F0candidateAxis,'ButtonDownFcn',@F0candidateAxisButtonDownCallback);
set(handles.periodicityScoreAxis,'ButtonDownFcn',@periodicityScoreAxisButtonDownCallback);
%--- set return values
STRAIGHTobject.f0CandidatesPlot = f0CandidatesPlot;
STRAIGHTobject.candidatesScorePlot = candidatesScorePlot;
STRAIGHTobject.f0PlotHandle = f0Plot;
STRAIGHTobject.defaultScoreLimit = defaultScoreLimit;
STRAIGHTobject.scorePlotHandle = scorePlot;
%--- set button down functions
set(STRAIGHTobject.waveformHandle,'ButtonDownFcn',@escapeToParent);
set(STRAIGHTobject.f0PlotHandle,'ButtonDownFcn',@escapeToParent);
set(STRAIGHTobject.scorePlotHandle,'ButtonDownFcn',@escapeToParent);
set(STRAIGHTobject.f0CandidatesPlot,'ButtonDownFcn',@escapeToParent);
set(STRAIGHTobject.candidatesScorePlot,'ButtonDownFcn',@escapeToParent);
set(STRAIGHTobject.vuvPlusHandle,'ButtonDownFcn',@escapeToParent);
set(STRAIGHTobject.vuvMinusHandle,'ButtonDownFcn',@escapeToParent);

%set(STRAIGHTobject.f0PlotHandle,'visible','off');
%set(STRAIGHTobject.scorePlotHandle,'visible','off');
%STRAIGHTobject.vuvPlusHandle
%--- align time axis
if isfield(STRAIGHTobject.f0Structure,'vuv')
    refinedData = STRAIGHTobject.f0Structure;
    set(STRAIGHTobject.vuvPlusHandle,'visible','on');
    set(STRAIGHTobject.vuvMinusHandle,'visible','on');
    set(handles.playUnVoicedButton,'enable','on');
    set(handles.playVoicedButton,'enable','on');
    x = STRAIGHTobject.waveform;
    set(STRAIGHTobject.vuvPlusHandle,'xdata',refinedData.temporalPositions, ...
        'ydata',refinedData.vuv*max(x)*1.01,'linewidth',2,'markersize',13);
    set(STRAIGHTobject.vuvMinusHandle,'xdata',refinedData.temporalPositions, ...
        'ydata',refinedData.vuv*min(x)*1.01,'linewidth',2,'markersize',13);
end;
temporalAxis = get(STRAIGHTobject.waveformHandle,'xdata');
xLowerLimit = temporalAxis(1);
xHigherLimit = temporalAxis(end);
xLim = [xLowerLimit xHigherLimit];
set(handles.waveformAxis,'xlim',xLim);
set(handles.F0candidateAxis,'xlim',xLim);
set(handles.periodicityScoreAxis,'xlim',xLim);
return;
end

function escapeToParent(src,evnt)
axisHandle = get(src,'parent');
handles = get(axisHandle,'userdata');
if isfield(handles,'handles') && ~isempty(handles.handles)
    handles = handles.handles;
end;
switch axisHandle
    case handles.waveformAxis
        waveformAxisButtonDownCallback(axisHandle,evnt);
    case handles.F0candidateAxis
        F0candidateAxisButtonDownCallback(axisHandle,evnt);
    case handles.periodicityScoreAxis
        periodicityScoreAxisButtonDownCallback(axisHandle,evnt);
end;
return;
end

function waveformAxisButtonDownCallback(src,evnt)
handles = get(src,'userdata');
GUIuserData = get(handles.f0ExtractorGUI,'userdata');
currentPoint = get(src,'currentPoint');
vuvPlusHandle = GUIuserData.vuvPlusHandle;
vuvMinusHandle = GUIuserData.vuvMinusHandle;
GUIuserData.currentX = currentPoint(1,1);
x = currentPoint(1,1);
xLim = get(src,'xlim');
if temporalAnchorGUI('isInsidePlot',handles.waveformAxis,'axis')
    if (temporalAnchorGUI('closeToSpecificLine',vuvPlusHandle) < 2) || ...
            (temporalAnchorGUI('closeToSpecificLine',vuvMinusHandle) < 2)
        GUIuserData = vuvKnobButtonDownCallback(src,evnt);
    else
        set(handles.f0ExtractorGUI,'WindowButtonMotionFcn',@genericWindowButtonMotionCallback);
        set(handles.f0ExtractorGUI,'WindowButtonUpFcn',@genericWindowButtonUpCallback);
    end;
elseif temporalAnchorGUI('isInsidePlot',handles.waveformAxis,'fringe')
    switch GUIuserData.currentKey
        case 'shift'
            xLim = (xLim-x)*sqrt(2)+x;
        otherwise
            xLim = (xLim-x)/sqrt(2)+x;
    end;
end;
xLim = adjustUpdateXlim(xLim,handles);
set(handles.waveformAxis,'xlim',xLim);
set(handles.F0candidateAxis,'xlim',xLim);
set(handles.periodicityScoreAxis,'xlim',xLim);
set(handles.f0ExtractorGUI,'userdata',GUIuserData);
return;
end

function xLim = adjustUpdateXlim(xLim,handles)
GUIuserData = get(handles.f0ExtractorGUI,'userdata');
temporalAxis = get(GUIuserData.waveformHandle,'xdata');
%xLim = max(100,min(fs/2,xLim));
xLowerLimit = temporalAxis(1);
xHigherLimit = temporalAxis(end);
if xLim(1) < xLowerLimit
    xLim = (xLim-xLim(1))+xLowerLimit;
end;
if xLim(2) > xHigherLimit
    xLim = (xLim-xLim(2))+xHigherLimit;
end;
if (xLim(2)-xLim(1)) > (xHigherLimit-xLowerLimit)
    xLim = [xLowerLimit xHigherLimit];
end;
return;
end

function periodicityScoreAxisButtonDownCallback(src,evnt)
handles = get(src,'userdata');
GUIuserData = get(handles.f0ExtractorGUI,'userdata');
currentPoint = get(src,'currentPoint');
GUIuserData.currentX = currentPoint(1,1);
if temporalAnchorGUI('isInsidePlot',handles.periodicityScoreAxis,'axis')
    set(handles.f0ExtractorGUI,'WindowButtonMotionFcn',@genericWindowButtonMotionCallback);
    set(handles.f0ExtractorGUI,'WindowButtonUpFcn',@genericWindowButtonUpCallback);
end;
set(handles.f0ExtractorGUI,'userdata',GUIuserData);
return;
end

function genericWindowButtonUpCallback(src,evnt)
GUIuserData = get(src,'userdata');
handles = GUIuserData.currentHandles;
set(handles.f0ExtractorGUI,'WindowButtonMotionFcn',@defaultWindowMotionCallback);
set(handles.f0ExtractorGUI,'WindowButtonUpFcn','');
defaultWindowMotionCallback(src,evnt);
return;
end

function genericWindowButtonMotionCallback(src,evnt)
GUIuserData = get(src,'userdata');
handles = GUIuserData.currentHandles;
currentPoint = get(handles.waveformAxis,'currentPoint');
x = currentPoint(1,1);
xLim = get(handles.waveformAxis,'xlim');
displacement = x-GUIuserData.currentX;
xLim = xLim-displacement;
xLim = adjustUpdateXlim(xLim,handles);
set(handles.waveformAxis,'xlim',xLim);
set(handles.F0candidateAxis,'xlim',xLim);
set(handles.periodicityScoreAxis,'xlim',xLim);
set(handles.f0ExtractorGUI,'userdata',GUIuserData);
return
end

function F0candidateAxisButtonDownCallback(src,evnt)
%handles = get(src,'userdata');
axisUserData = get(src,'userdata');
handles = axisUserData.handles;
GUIuserData = get(handles.f0ExtractorGUI,'userdata');
penToolOn = get(handles.penToolButton,'value');
if temporalAnchorGUI('isInsidePlot',handles.F0candidateAxis,'axis')
    switch penToolOn %GUIuserData.currentKey
        case 1 %'alt'
            generatePen(src,evnt);
            return;
        otherwise
            getRectangle(src,evnt);
            return;
    end;
end;
return;
end

function getRectangle(src,evnt)
%handles = get(src,'userdata');
axisUserData = get(src,'userdata');
handles = axisUserData.handles;
GUIuserData = get(handles.f0ExtractorGUI,'userdata');
if isfield(axisUserData,'regionHandle') && ...
        ishandle(axisUserData.regionHandle)
    delete(axisUserData.regionHandle);
end;
if isfield(axisUserData,'line')
    if ishandle(axisUserData.line)
        delete(axisUserData.line);
    end;
end;
if isfield(GUIuserData,'groupHandle')
    if ishandle(GUIuserData.groupHandle)
        delete(GUIuserData.groupHandle);
    end;
end;
axisPosition = get(gca,'position');
finalRectangle = rbbox;
normalizedRectangle = ...
    [(finalRectangle(1:2)-axisPosition(1:2))./axisPosition(3:4) ...
    finalRectangle(3:4)./axisPosition(3:4)];
xlimit = get(gca,'xlim');
xRange = xlimit(2)-xlimit(1);
ylimit = get(gca,'ylim');
yRange = log(ylimit(2)/ylimit(1));
xmin = normalizedRectangle(1)*xRange+xlimit(1);
xmax = (normalizedRectangle(1)+normalizedRectangle(3))*xRange+xlimit(1);
logymin = normalizedRectangle(2)*yRange+log(ylimit(1));
logymax = (normalizedRectangle(2)+normalizedRectangle(4))*yRange+log(ylimit(1));
ymin = exp(logymin);
ymax = exp(logymax);
hold on;
axisUserData.regionHandle = ...
    semilogy([xmin xmax xmax xmin xmin],[ymin ymin ymax ymax ymin],...
    'g','linewidth',3);
set(axisUserData.regionHandle,'ButtonDownFcn',@escapeToParent);
hold off;
set(handles.recalculateButton,'enable','on');
set(src,'userdata',axisUserData);
return;
end

function generatePen(src,evnt)
axisUserData = get(src,'userdata');
handles = axisUserData.handles;
GUIuserData = get(handles.f0ExtractorGUI,'userdata');
currentPoint = get(src,'currentpoint');
axisUserData.xdata = zeros(1000,1);
axisUserData.ydata = zeros(1000,1);
axisUserData.xdata(1) = currentPoint(1,1);
axisUserData.ydata(1) = currentPoint(1,2);
axisUserData.linePoints = 1;
axisUserData.maxLinePoints = 1000;
if isfield(axisUserData,'regionHandle') && ...
        ishandle(axisUserData.regionHandle)
    delete(axisUserData.regionHandle);
end;
if isfield(axisUserData,'line')
    if ishandle(axisUserData.line)
        delete(axisUserData.line);
    end;
end;
if isfield(GUIuserData,'groupHandle')
    if ishandle(GUIuserData.groupHandle)
        delete(GUIuserData.groupHandle);
    end;
end;
axisUserData.line = ...
    line('xdata',axisUserData.xdata(1:axisUserData.linePoints),...
    'ydata',axisUserData.ydata(1:axisUserData.linePoints),...
    'color','m','linewidth',2);
set(src,'userdata',axisUserData);
set(axisUserData.line,'ButtonDownFcn',@escapeToUpperButtonDownFcn);
set(handles.f0ExtractorGUI,'WindowButtonMotionFcn',@penMotionCallback);
set(handles.f0ExtractorGUI,'WindowButtonUpFcn',@penUpCallback);
%disp('generatePen!');
return;
end

function escapeToUpperButtonDownFcn(src,evnt)
%disp('escape!');
F0candidateAxisButtonDownCallback(get(src,'parent'),evnt);
return;
end

function penMotionCallback (src,evnt)
GUIuserData = get(src,'userdata');
handles = GUIuserData.currentHandles;
axisHandle = handles.F0candidateAxis;
currentPoint = get(axisHandle,'currentpoint');
axisUserData = get(axisHandle,'userdata');
axisUserData.linePoints = ...
    min(axisUserData.maxLinePoints,axisUserData.linePoints+1);
axisUserData.xdata(axisUserData.linePoints) = currentPoint(1,1);
axisUserData.ydata(axisUserData.linePoints) = currentPoint(1, 2);
set(axisUserData.line,'xdata',axisUserData.xdata(1:axisUserData.linePoints),...
    'ydata',axisUserData.ydata(1:axisUserData.linePoints));
set(axisHandle,'userdata',axisUserData);
return;
end

function penUpCallback(src,evnt)
GUIuserData = get(src,'userdata');
handles = GUIuserData.currentHandles;
set(handles.f0ExtractorGUI,'WindowButtonMotionFcn',@defaultWindowMotionCallback);
set(handles.f0ExtractorGUI,'WindowButtonUpFcn','');
axisHandle = handles.F0candidateAxis;
axisUserData = get(axisHandle,'userdata');
penXdata = axisUserData.xdata(1:axisUserData.linePoints);
penYdata = axisUserData.ydata(1:axisUserData.linePoints);
[penXdataSorted,indexSorted] = sort(penXdata+rand(size(penXdata))*max(abs(penXdata))*0.0001);
penYdataSorted = penYdata(indexSorted);
groupHandle = line('xdata',penXdataSorted,...
    'ydata',penYdataSorted,'linestyle','-','linewidth',6,'color','g');
GUIuserData.groupHandle = groupHandle;
groupUserData.handles = handles;
set(groupHandle,'ButtonDownFcn',@escapeToUpperButtonDownFcn);
set(groupHandle,'userdata',groupUserData);
set(handles.f0ExtractorGUI,'WindowButtonUpFcn','');%@groupButtonUpFcn);
if isfield(axisUserData,'line')
    if ishandle(axisUserData.line)
        delete(axisUserData.line);
    end;
end;
set(axisHandle,'userdata',axisUserData);
set(handles.f0ExtractorGUI,'userdata',GUIuserData);
set(handles.recalculateButton,'enable','on');
return;
end

% --- Executes on button press in autoTrackButton.
function autoTrackButton_Callback(hObject, eventdata, handles)
% hObject    handle to autoTrackButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUIuserData = get(handles.f0ExtractorGUI,'userdata') ;
%axisUserData = get(handles.F0candidateAxis,'userdata') ;
x = GUIuserData.waveform;
refinedData = autoF0Tracking(GUIuserData,x);
refinedData.vuv = refineVoicingDecision(x,refinedData);
GUIuserData.f0 = refinedData.f0;
GUIuserData.vuv = refinedData.vuv;
GUIuserData.periodicityLevel = refinedData.periodicityLevel;
set(GUIuserData.vuvPlusHandle,'xdata',refinedData.temporalPositions, ...
    'ydata',refinedData.vuv*max(x)*1.01,'linewidth',2);
set(GUIuserData.vuvMinusHandle,'xdata',refinedData.temporalPositions, ...
    'ydata',refinedData.vuv*min(x)*1.01,'linewidth',2);
set(GUIuserData.f0PlotHandle,'ydata',GUIuserData.f0);
set(GUIuserData.scorePlotHandle,'ydata',GUIuserData.periodicityLevel);
set(handles.f0ExtractorGUI,'userdata',GUIuserData);
set(handles.autoTrackButton,'enable','off');
return;
end

% --- Executes on button press in recalculateButton.
function recalculateButton_Callback(hObject, eventdata, handles)
% hObject    handle to recalculateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUIuserData = get(handles.f0ExtractorGUI,'userdata');
axisUserData = get(handles.F0candidateAxis,'userdata');
if isfield(GUIuserData,'groupHandle') && ...
        ishandle(GUIuserData.groupHandle)
    xData = get(GUIuserData.groupHandle,'xdata');
    yData = get(GUIuserData.groupHandle,'ydata');
    temporalPositions = get(GUIuserData.f0PlotHandle,'xdata');
    f0CandidatesMap = GUIuserData.f0CandidatesMap;
    f0CandidatesScoreMap = GUIuserData.f0CandidatesScoreMap;
    baseIndex = min(1:length(temporalPositions),size(f0CandidatesScoreMap,2));
    if isfield(GUIuserData,'substitutionMask') && ...
            length(GUIuserData.substitutionMask) == length(temporalPositions)
        substitutionMask = GUIuserData.substitutionMask;
    else
        substitutionMask = zeros(length(temporalPositions),1);
    end;
    activeIndex = ...
        baseIndex((temporalPositions>min(xData))&(temporalPositions<max(xData)));
    if ~isempty(activeIndex) && (length(activeIndex) > 3)
        extendedPen = interp1(xData,log(yData),temporalPositions,'linear','extrap');
        safeF0CandidatesMap = f0CandidatesMap;
        safeF0CandidatesMap(isnan(safeF0CandidatesMap)) = 1;
        safeF0CandidatesMap(safeF0CandidatesMap<=0) = 1;
        logF0Map = log(safeF0CandidatesMap);
        for ii = activeIndex
            [minimumDistance,bestCandidateIndex] = min(abs(logF0Map(:,ii)-extendedPen(ii)));
            if minimumDistance < log(1.2) %log(sqrt(2)) % fix by HK 17/Sept./2015
                GUIuserData.f0(ii) = f0CandidatesMap(bestCandidateIndex,ii);
                GUIuserData.periodicityLevel(ii) = f0CandidatesScoreMap(bestCandidateIndex,ii);
            else
                GUIuserData.f0(ii) = exp(extendedPen(ii));
                GUIuserData.periodicityLevel(ii) = min(min(GUIuserData.periodicityLevel));
                substitutionMask(ii) = 1;
            end;
        end;
        set(GUIuserData.f0PlotHandle,'ydata',GUIuserData.f0);
        set(GUIuserData.scorePlotHandle,'ydata',GUIuserData.periodicityLevel);
        if sum(substitutionMask) > 0
            GUIuserData.substitutionMask = substitutionMask;
        end;
        set(handles.f0ExtractorGUI,'userdata',GUIuserData);
    end;
    delete(GUIuserData.groupHandle);
end;
if isfield(axisUserData,'regionHandle') && ...
        ishandle(axisUserData.regionHandle)
    xData = get(axisUserData.regionHandle,'xdata');
    yData = get(axisUserData.regionHandle,'ydata');
    temporalPositions = get(GUIuserData.f0PlotHandle,'xdata');
    f0CandidatesMap = GUIuserData.f0CandidatesMap;
    f0CandidatesScoreMap = GUIuserData.f0CandidatesScoreMap;
    baseIndex = min(1:length(temporalPositions),size(f0CandidatesScoreMap,2));
    activeIndex = ...
        baseIndex((temporalPositions>min(xData))&(temporalPositions<max(xData)));
    if ~isempty(activeIndex)
        for ii = activeIndex
            baseCandidate = 1:size(f0CandidatesScoreMap,1);
            activeCandidates = ...
                baseCandidate((f0CandidatesMap(:,ii)>min(yData)) & ...
                (f0CandidatesMap(:,ii)<max(yData)));
            if ~isempty(activeCandidates)
                activef0CandidatesMap = f0CandidatesMap(activeCandidates,ii);
                [bestPeriodicity,bestCandidateIndex] = ...
                    max(f0CandidatesScoreMap(activeCandidates,ii));
                GUIuserData.f0(ii) = ...
                    activef0CandidatesMap(bestCandidateIndex);
                GUIuserData.periodicityLevel(ii) = bestPeriodicity;
            end;
        end;
        set(GUIuserData.f0PlotHandle,'ydata',GUIuserData.f0);
        set(GUIuserData.scorePlotHandle,'ydata',GUIuserData.periodicityLevel);
        set(handles.f0ExtractorGUI,'userdata',GUIuserData);
    end;
    delete(axisUserData.regionHandle);
end;
set(handles.recalculateButton,'enable','off');
return;
end

% --- Executes on button press in finishButton.
function finishButton_Callback(hObject, eventdata, handles)
% hObject    handle to finishButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUIuserData = get(handles.output,'userdata');
if isfield(GUIuserData,'HandleOfCallingRoutine') && ...
        ishandle(GUIuserData.HandleOfCallingRoutine)
    hostSTRAIGHTobject = get(GUIuserData.HandleOfCallingRoutine,'userdata');
    hostSTRAIGHTobject.originalF0Structure = GUIuserData.f0Structure;
    hostSTRAIGHTobject.refinedF0Structure = GUIuserData.f0Structure;
    hostSTRAIGHTobject.refinedF0Structure.f0 = GUIuserData.f0;
    hostSTRAIGHTobject.waveform = GUIuserData.waveform;
    if isfield(GUIuserData,'vuv')
        hostSTRAIGHTobject.refinedF0Structure.vuv = GUIuserData.vuv;
    end;
    hostSTRAIGHTobject.refinedF0Structure.periodicityLevel = ...
        GUIuserData.periodicityLevel;
    hostSTRAIGHTobject = clearAnalysisResults(hostSTRAIGHTobject);
    set(GUIuserData.HandleOfCallingRoutine,'userdata',hostSTRAIGHTobject);
    hostHandles = hostSTRAIGHTobject.currentHandles;
    TandemSTRAIGHThandler('syncGUIStatus',hostHandles);
    figure(GUIuserData.HandleOfCallingRoutine);
end;
close(handles.output);
end

function STRAIGHTobject = clearAnalysisResults(STRAIGHTobject)
if isfield(STRAIGHTobject,'AperiodicityStructure')
    if ~isempty(STRAIGHTobject.AperiodicityStructure)
        STRAIGHTobject.AperiodicityStructure = [];
    end;
end;
if isfield(STRAIGHTobject,'SpectrumStructure')
    if ~isempty(STRAIGHTobject.SpectrumStructure)
        STRAIGHTobject.SpectrumStructure = [];
    end;
end;
if isfield(STRAIGHTobject,'SynthesisStructure')
    if ~isempty(STRAIGHTobject.SynthesisStructure)
        STRAIGHTobject.SynthesisStructure = [];
    end;
end;
return;
end

% --- Executes on button press in fullZoomOutButton.
function fullZoomOutButton_Callback(hObject, eventdata, handles)
% hObject    handle to fullZoomOutButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUIuserData = get(handles.f0ExtractorGUI,'userdata');
temporalAxis = get(GUIuserData.waveformHandle,'xdata');
xLowerLimit = temporalAxis(1);
xHigherLimit = temporalAxis(end);
xLim = [xLowerLimit xHigherLimit];
set(handles.waveformAxis,'xlim',xLim);
set(handles.F0candidateAxis,'xlim',xLim);
set(handles.periodicityScoreAxis,'xlim',xLim);
defaultWindowMotionCallback(handles.f0ExtractorGUI,eventdata);
return;
end

function defaultWindowMotionCallback(src,evnt)
GUIuserData = get(src,'userdata');
handles = GUIuserData.currentHandles;
vuvPlusHandle = GUIuserData.vuvPlusHandle;
vuvMinusHandle = GUIuserData.vuvMinusHandle;
isPenTool = get(handles.penToolButton,'value');
if temporalAnchorGUI('isInsidePlot',handles.waveformAxis,'axis')
    if (temporalAnchorGUI('closeToSpecificLine',vuvPlusHandle) < 2) || ...
            (temporalAnchorGUI('closeToSpecificLine',vuvMinusHandle) < 2)
        setPointerShape(4);
    else
        setPointerShape(3);
    end;
elseif temporalAnchorGUI('isInsidePlot',handles.F0candidateAxis,'axis') && ...
        strcmp('on',get(handles.F0candidateAxis,'visible'))
    switch isPenTool %GUIuserData.currentKey
        case 1 %'alt'
            setPointerShape(6);
        otherwise
            setPointerShape(5);
    end;
elseif temporalAnchorGUI('isInsidePlot',handles.periodicityScoreAxis,'axis') && ...
        strcmp('on',get(handles.periodicityScoreAxis,'visible'))
    setPointerShape(3);
elseif temporalAnchorGUI('isInsidePlot',handles.waveformAxis,'fringe')
    switch GUIuserData.currentKey
        case 'shift'
            setPointerShape(2);
        case 'control'
            setPointerShape(3);
        otherwise
            setPointerShape(1);
    end;
else
    setPointerShape(999);
end;
return;
end

function dummyOut = dummyCallback(handles)
%   This function will never be called.
x = randn(10000,1);
fs = 44100;
option.dummy = 1;
f0Structure1 = tandemSTRAIGHTF0interface(x,fs,option);
f0Structure2 = YegnaF0interface(x,fs,option);
f0Structure3 = NDFF0interface(x,fs,option);
f0Structure4 = oldSTRAIGHTF0interface(x,fs,option);
dummyOut.f0Structure1 = f0Structure1;
dummyOut.f0Structure2 = f0Structure2;
dummyOut.f0Structure3 = f0Structure3;
dummyOut.f0Structure4 = f0Structure4;
return;
end

% --- Executes on button press in cleanLFnoise.
function cleanLFnoise_Callback(hObject, eventdata, handles)
% hObject    handle to cleanLFnoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTobject = get(handles.output,'userdata');
set(handles.output,'pointer','watch');
drawnow;
%autoLFClean = get(handles.automaticLFNoiseCleanerRButton,'Value');
%if autoLFClean
STRAIGHTobject.waveform = removeLFBlackman(STRAIGHTobject.waveform,...
    STRAIGHTobject.samplingFrequency,...
    STRAIGHTobject.f0,STRAIGHTobject.periodicityLevel);
%else
%    STRAIGHTobject.waveform = removeLF(STRAIGHTobject.waveform,...
%        STRAIGHTobject.samplingFrequency,...
%        STRAIGHTobject.f0,STRAIGHTobject.periodicityLevel);
%end;
%STRAIGHTobject = setupSecondDisplay(STRAIGHTobject,handles);
ydata = get(STRAIGHTobject.waveformHandle,'ydata');
if length(ydata) == length(STRAIGHTobject.waveform);
    set(STRAIGHTobject.waveformHandle,'ydata',STRAIGHTobject.waveform);
end;
set(handles.output,'pointer','arrow');
set(handles.output,'userdata',STRAIGHTobject);
set(handles.calculateButton,'enable','on');
set(handles.finishButton,'enable','off');
set(handles.autoTrackButton,'enable','off');
set(handles.restoreOriginalButton,'enable','on');
drawnow;
return;
end

% --- Executes on button press in restoreOriginalButton.
function restoreOriginalButton_Callback(hObject, eventdata, handles)
% hObject    handle to restoreOriginalButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% finishButton
STRAIGHTobject = get(handles.output,'userdata');
STRAIGHTobject.waveform = STRAIGHTobject.originalWaveform;
ydata = get(STRAIGHTobject.waveformHandle,'ydata');
if length(ydata) == length(STRAIGHTobject.waveform);
    set(STRAIGHTobject.waveformHandle,'ydata',STRAIGHTobject.waveform);
end;
set(handles.output,'userdata',STRAIGHTobject);
set(handles.calculateButton,'enable','on');
set(handles.autoTrackButton,'enable','off');
set(handles.cleanLFnoise,'enable','off');
set(handles.finishButton,'enable','off');
end

% --- interactive VUV edit
function GUIuserData = vuvKnobButtonDownCallback(src,evnt)
tempUserData = get(src,'userdata');
GUIuserData = get(tempUserData.f0ExtractorGUI,'userdata');
%handles = GUIuserData.currentHandles;
vuvPlusHandle = GUIuserData.vuvPlusHandle;
vuvMinusHandle = GUIuserData.vuvMinusHandle;
currentPoint = get(src,'currentpoint');
timeAxis = get(vuvPlusHandle,'xdata');
deltaT = timeAxis(2);
yPlus = max(get(vuvPlusHandle,'ydata'));
yPlusData = get(vuvPlusHandle,'ydata');
yMinus = min(get(vuvMinusHandle,'ydata'));
yMinusData = get(vuvMinusHandle,'ydata');
leftIndex = max(find(currentPoint(1,1) > timeAxis));
rightIndex = min(find(currentPoint(1,1) < timeAxis));
if yPlusData(leftIndex) == 0 & yPlusData(rightIndex) > 0
    knobXdata = timeAxis([rightIndex,leftIndex,rightIndex]);
    konbYdataPlus = [yPlus 0 yMinus];
    motionType = 'LLR';
elseif yPlusData(leftIndex) > 0 & yPlusData(rightIndex) == 0
    knobXdata = timeAxis([leftIndex,rightIndex,leftIndex]);
    konbYdataPlus = [yPlus 0 yMinus];
    motionType = 'RLR';
else %yPlusData(leftIndex) == 0 & yPlusData(rightIndex) == 0
    knobXdata = [timeAxis(leftIndex),(timeAxis(leftIndex)+timeAxis(rightIndex))/2,timeAxis(rightIndex)];
    if currentPoint(1,2) > 0
        konbYdataPlus = [yPlusData(leftIndex) currentPoint(1,2) yPlusData(rightIndex)];
    else
        konbYdataPlus = [yMinusData(leftIndex) currentPoint(1,2) yMinusData(rightIndex)];
    end;
    motionType = 'UD';
end;
GUIuserData.vuvKnobHandle = line('xdata',knobXdata,'ydata',konbYdataPlus,'color','m','linewidth',2);
vuvUserData.leftIndex = leftIndex;
vuvUserData.rightIndex = rightIndex;
set(GUIuserData.vuvKnobHandle,'userdata',vuvUserData);
set(tempUserData.f0ExtractorGUI,'WindowButtonUpFcn',@vuvKnobButtonUpCallback);
switch motionType
    case 'LLR'
        set(tempUserData.f0ExtractorGUI,'WindowButtonMotionFcn',@vuvKnobMotionLLRCallback);
    case 'RLR'
        set(tempUserData.f0ExtractorGUI,'WindowButtonMotionFcn',@vuvKnobMotionRLRCallback);
    case 'UD'
        set(tempUserData.f0ExtractorGUI,'WindowButtonMotionFcn',@vuvKnobMotionUDCallback);
end;
return;
end

function vuvKnobMotionLLRCallback(src,evnt)
tempUserData = get(src,'userdata');
handles = tempUserData.currentHandles;
GUIuserData = get(handles.f0ExtractorGUI,'userdata');
currentPoint = get(handles.waveformAxis,'currentpoint');
vuvPlusHandle = GUIuserData.vuvPlusHandle;
vuvMinusHandle = GUIuserData.vuvMinusHandle;
timeAxis = get(vuvPlusHandle,'xdata');
deltaT = timeAxis(2);
yPlus = max(get(vuvPlusHandle,'ydata'));
yPlusData = get(vuvPlusHandle,'ydata');
yMinus = min(get(vuvMinusHandle,'ydata'));
yMinusData = get(vuvMinusHandle,'ydata');
if isfield(GUIuserData,'vuvKnobHandle')
    if ishandle(GUIuserData.vuvKnobHandle)
        knobXdata = get(GUIuserData.vuvKnobHandle,'xdata');
        %vuvUserData = get(GUIuserData.vuvKnobHandle,'userdata');
        oldLeftX = knobXdata(2);
        oldRightX = knobXdata(1);
        deltaX = currentPoint(1,1)-sum(knobXdata(1:2))/2;
        knobXdata = knobXdata+deltaX;
        newLeftX = knobXdata(2);
        newRightX = knobXdata(1);
        leftIndexInside = find((timeAxis-oldLeftX).*(timeAxis-newLeftX)<0);
        rightIndexInside = find((timeAxis-oldRightX).*(timeAxis-newRightX)<0);
        set(GUIuserData.vuvKnobHandle,'xdata',knobXdata);
        if deltaX < 0 && ~isempty(rightIndexInside)
            yPlusData(rightIndexInside) = yPlus;
            yMinusData(rightIndexInside) = yMinus;
            set(vuvPlusHandle,'ydata',yPlusData);
            set(vuvMinusHandle,'ydata',yMinusData);
        elseif deltaX >= 0 && ~isempty(leftIndexInside)
            yPlusData(rightIndexInside) = 0;
            yMinusData(rightIndexInside) = 0;
            set(vuvPlusHandle,'ydata',yPlusData);
            set(vuvMinusHandle,'ydata',yMinusData);
        end;
    end;
end;
return;
end

function vuvKnobMotionRLRCallback(src,evnt)
tempUserData = get(src,'userdata');
handles = tempUserData.currentHandles;
GUIuserData = get(handles.f0ExtractorGUI,'userdata');
currentPoint = get(handles.waveformAxis,'currentpoint');
vuvPlusHandle = GUIuserData.vuvPlusHandle;
vuvMinusHandle = GUIuserData.vuvMinusHandle;
timeAxis = get(vuvPlusHandle,'xdata');
deltaT = timeAxis(2);
yPlus = max(get(vuvPlusHandle,'ydata'));
yPlusData = get(vuvPlusHandle,'ydata');
yMinus = min(get(vuvMinusHandle,'ydata'));
yMinusData = get(vuvMinusHandle,'ydata');
if isfield(GUIuserData,'vuvKnobHandle')
    if ishandle(GUIuserData.vuvKnobHandle)
        knobXdata = get(GUIuserData.vuvKnobHandle,'xdata');
        %vuvUserData = get(GUIuserData.vuvKnobHandle,'userdata');
        oldLeftX = knobXdata(2);
        oldRightX = knobXdata(1);
        deltaX = currentPoint(1,1)-sum(knobXdata(1:2))/2;
        knobXdata = knobXdata+deltaX;
        newLeftX = knobXdata(2);
        newRightX = knobXdata(1);
        leftIndexInside = find((timeAxis-oldLeftX).*(timeAxis-newLeftX)<0);
        rightIndexInside = find((timeAxis-oldRightX).*(timeAxis-newRightX)<0);
        set(GUIuserData.vuvKnobHandle,'xdata',knobXdata);
        if deltaX <= 0 && ~isempty(rightIndexInside)
            yPlusData(rightIndexInside) = 0;
            yMinusData(rightIndexInside) = 0;
            set(vuvPlusHandle,'ydata',yPlusData);
            set(vuvMinusHandle,'ydata',yMinusData);
        elseif deltaX > 0 && ~isempty(leftIndexInside)
            yPlusData(rightIndexInside) = yPlus;
            yMinusData(rightIndexInside) = yMinus;
            set(vuvPlusHandle,'ydata',yPlusData);
            set(vuvMinusHandle,'ydata',yMinusData);
        end;
    end;
end;
return;
end

%vuvUserData.leftIndex = leftIndex;
%vuvUserData.rightIndex = rightIndex;

function vuvKnobMotionUDCallback(src,evnt)
tempUserData = get(src,'userdata');
handles = tempUserData.currentHandles;
GUIuserData = get(handles.f0ExtractorGUI,'userdata');
currentPoint = get(handles.waveformAxis,'currentpoint');
vuvPlusHandle = GUIuserData.vuvPlusHandle;
vuvMinusHandle = GUIuserData.vuvMinusHandle;
timeAxis = get(vuvPlusHandle,'xdata');
deltaT = timeAxis(2);
yPlus = max(get(vuvPlusHandle,'ydata'));
yPlusData = get(vuvPlusHandle,'ydata');
yMinus = min(get(vuvMinusHandle,'ydata'));
yMinusData = get(vuvMinusHandle,'ydata');
if isfield(GUIuserData,'vuvKnobHandle')
    if ishandle(GUIuserData.vuvKnobHandle)
        knobYdata = get(GUIuserData.vuvKnobHandle,'ydata');
        vuvKnobUserData = get(GUIuserData.vuvKnobHandle,'userdata');
        leftIndex = vuvKnobUserData.leftIndex;
        rightIndex = vuvKnobUserData.rightIndex;
        knobYdata(2) = currentPoint(1,2);
        set(GUIuserData.vuvKnobHandle,'ydata',knobYdata);
        isUnvoice = (currentPoint(1,2)>yMinus/2)&(currentPoint(1,2)<yPlus/2);
        if isUnvoice
            yPlusData(leftIndex:rightIndex) = 0;
            yMinusData(leftIndex:rightIndex) = 0;
        else
            yPlusData(leftIndex:rightIndex) = yPlus;
            yMinusData(leftIndex:rightIndex) = yMinus;
        end;
        set(vuvPlusHandle,'ydata',yPlusData);
        set(vuvMinusHandle,'ydata',yMinusData);
    end;
end;
return;
end

function vuvKnobButtonUpCallback(src,evnt)
tempUserData = get(src,'userdata');
%disp('vuvKnobUp')
handles = tempUserData.currentHandles;
GUIuserData = get(handles.f0ExtractorGUI,'userdata');
set(handles.f0ExtractorGUI,'WindowButtonUpFcn','');
set(handles.f0ExtractorGUI,'WindowButtonMotionFcn',@defaultWindowMotionCallback);
if isfield(GUIuserData,'vuvKnobHandle')
    if ishandle(GUIuserData.vuvKnobHandle)
        vuvPlusHandle = GUIuserData.vuvPlusHandle;
        yPlusData = get(vuvPlusHandle,'ydata');
        GUIuserData.vuv = double(yPlusData(:)>0);
        delete(GUIuserData.vuvKnobHandle);
    end;
end;
set(handles.f0ExtractorGUI,'userdata',GUIuserData);
setPointerShape(3);
return;
end


% --- Executes on button press in playAllButton.
function playAllButton_Callback(hObject, eventdata, handles)
% hObject    handle to playAllButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTobject = get(handles.output,'userdata');
fs = STRAIGHTobject.samplingFrequency;
x = STRAIGHTobject.waveform;
player = audioplayer(x/max(abs(x))*0.9,fs);
playblocking(player);
end


% --- Executes on button press in playVisibleButton.
function playVisibleButton_Callback(hObject, eventdata, handles)
% hObject    handle to playVisibleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTobject = get(handles.output,'userdata');
fs = STRAIGHTobject.samplingFrequency;
x = STRAIGHTobject.waveform;
xlim = get(handles.waveformAxis,'xlim');
xLimSample = min(length(x),max(1,round(xlim*fs)));
player = audioplayer(x(xLimSample(1):xLimSample(2))/max(abs(x(xLimSample(1):xLimSample(2))))*0.9,fs);
playblocking(player);
end

% --- Executes on button press in playVoicedButton.
function playVoicedButton_Callback(hObject, eventdata, handles)
% hObject    handle to playVoicedButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTobject = get(handles.output,'userdata');
GUIuserData = get(handles.f0ExtractorGUI,'userdata');
fs = STRAIGHTobject.samplingFrequency;
x = STRAIGHTobject.waveform;
xlim = get(handles.waveformAxis,'xlim');
xLimSample = min(length(x),max(1,round(xlim*fs)));
if isfield(GUIuserData,'vuv')
    temporalAxis = get(GUIuserData.waveformHandle,'xdata');
    temporalPositions = get(GUIuserData.f0PlotHandle,'xdata');
    vuvSample = interp1(temporalPositions,GUIuserData.vuv,temporalAxis,'linear',0);
    xVoice = x.*vuvSample(:);
    player = audioplayer(xVoice(xLimSample(1):xLimSample(2))/max(abs(xVoice(xLimSample(1):xLimSample(2))))*0.9,fs);
    playblocking(player);
end;
end


% --- Executes on button press in playUnVoicedButton.
function playUnVoicedButton_Callback(hObject, eventdata, handles)
% hObject    handle to playUnVoicedButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTobject = get(handles.output,'userdata');
GUIuserData = get(handles.f0ExtractorGUI,'userdata');
fs = STRAIGHTobject.samplingFrequency;
x = STRAIGHTobject.waveform;
xlim = get(handles.waveformAxis,'xlim');
xLimSample = min(length(x),max(1,round(xlim*fs)));
if isfield(GUIuserData,'vuv')
    temporalAxis = get(GUIuserData.waveformHandle,'xdata');
    temporalPositions = get(GUIuserData.f0PlotHandle,'xdata');
    vuvSample = interp1(temporalPositions,GUIuserData.vuv,temporalAxis,'linear',0);
    xVoice = x.*(1-vuvSample(:));
    player = audioplayer(xVoice(xLimSample(1):xLimSample(2))/max(abs(xVoice(xLimSample(1):xLimSample(2))))*0.9,fs);
    playblocking(player);
end;
end
