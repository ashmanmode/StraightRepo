function varargout = frequencyAnchorPointGUI(varargin)
% FREQUENCYANCHORPOINTGUI M-file for frequencyAnchorPointGUI.fig
%      FREQUENCYANCHORPOINTGUI, by itself, creates a new FREQUENCYANCHORPOINTGUI or raises the existing
%      singleton*.
%
%      H = FREQUENCYANCHORPOINTGUI returns the handle to a new FREQUENCYANCHORPOINTGUI or the handle to
%      the existing singleton*.
%
%      FREQUENCYANCHORPOINTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FREQUENCYANCHORPOINTGUI.M with the given input arguments.
%
%      FREQUENCYANCHORPOINTGUI('Property','Value',...) creates a new FREQUENCYANCHORPOINTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before frequencyAnchorPointGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to frequencyAnchorPointGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help frequencyAnchorPointGUI

% Last Modified by GUIDE v2.5 04-Feb-2011 21:58:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @frequencyAnchorPointGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @frequencyAnchorPointGUI_OutputFcn, ...
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


% --- Executes just before frequencyAnchorPointGUI is made visible.
function frequencyAnchorPointGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to frequencyAnchorPointGUI (see VARARGIN)

% Choose default command line output for frequencyAnchorPointGUI
handles.output = hObject;

parentHandles = get(hObject,'userdata');
if isfield(parentHandles,'temporalAnchorGUI') && ...
        ishandle(parentHandles.temporalAnchorGUI)
    frequencyGUIuserData.parentHandles = parentHandles;
    frequencyGUIuserData.temporalAnchorGUI = parentHandles.temporalAnchorGUI;
    temporalAnchorGUIuserData = get(parentHandles.temporalAnchorGUI,'userdata');
    frequencyGUIuserData.mSubstrate = temporalAnchorGUIuserData.mSubstrate;
    frequencyGUIuserData.creationDate = datestr(now,30);
    frequencyGUIuserData.objectDirectory = pwd;
    frequencyGUIuserData.objectFile = 'invokedByMorphingMenu';
    frequencyGUIuserData.currentFocusID = temporalAnchorGUIuserData.currentFocusID;
    frequencyGUIuserData.currentKey = temporalAnchorGUIuserData.currentKey;
    %disp('invokedByMorphingMenu');
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
    frequencyGUIuserData.mSubstrate = revisedData;
    frequencyGUIuserData.objectDirectory = path;
    frequencyGUIuserData.objectFile = file;
    frequencyGUIuserData.currentFocusID = 1;
    frequencyGUIuserData.parentHandles = [];
    frequencyGUIuserData.currentKey = 'none';
    set(handles.updateFrequencyAnchorButton,'enable','off');
end;
frequencyGUIuserData.currentHandles = handles;
set(handles.frequencyAnchorPointGUI,'userdata',frequencyGUIuserData);
set(handles.frequencyAnchorPointGUI,'KeyPressFcn',@keyPressCallBack);
set(handles.frequencyAnchorPointGUI,'KeyReleaseFcn',@keyReleaseCallBack);
set(handles.frequencyAnchorPointGUI,'WindowButtonMotionFcn',@defaultWindowMotionCallback);
createFrequencyAnchorIfItIsNotThere(handles);

%locateTopLeftOfGUI(Top,Left,GUIHandle)
TandemSTRAIGHThandler('locateTopLeftOfGUI',65,70,handles.frequencyAnchorPointGUI);

setUpDisplay(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes frequencyAnchorPointGUI wait for user response (see UIRESUME)
% uiwait(handles.frequencyAnchorPointGUI);


% --- Outputs from this function are returned to the command line.
function varargout = frequencyAnchorPointGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function setUpDisplay(handles)
GUIuserData = get(handles.frequencyAnchorPointGUI,'userdata');
mSubstrate = GUIuserData.mSubstrate;
%if ~isempty(GUIuserData.parentHandles)
%    temporalGUIuserData = get(GUIuserData.parentHandles.temporalAnchorGUI,'userdata');
%else
%    temporalGUIuserData = GUIuserData;
%end;
temporalGUIuserData = GUIuserData;
focusStructure = getFocusInformation(temporalGUIuserData);
focusStructure = showSpectralPlot(focusStructure,handles);
GUIuserData.focusStructure = focusStructure;
set(handles.frequencyAnchorPointGUI,'userdata',GUIuserData);
displayFocusInformation(focusStructure,handles);
assignCallbacks(focusStructure,handles);
return;

function assignCallbacks(focusStructure,handles)
GUIuserData = get(handles.frequencyAnchorPointGUI,'userdata');
mSubstrate = GUIuserData.mSubstrate;
maxIDs = mSubstrate.maximumFrequencyAnchors;
set(handles.spectrumAxis,'userdata',handles);
set(handles.spectrumAxis,'ButtonDownFcn',@spectrumAxisButtonDownCallback);
set(focusStructure.spectrumPlotA,'ButtonDownFcn',@spectrumPlotButtonDownCallback);
set(focusStructure.spectrumPlotB,'ButtonDownFcn',@spectrumPlotButtonDownCallback);
for ii = 1:maxIDs
    set(focusStructure.anchorMarksA(ii),'ButtonDownFcn',@frequencyAnchorButtonDownCallback);
    set(focusStructure.anchorMarksB(ii),'ButtonDownFcn',@frequencyAnchorButtonDownCallback);
    set(focusStructure.anchorLineA(ii),'ButtonDownFcn',@frequencyAnchorButtonDownCallback);
    set(focusStructure.anchorLineB(ii),'ButtonDownFcn',@frequencyAnchorButtonDownCallback);
end;
return;

function frequencyAnchorButtonDownCallback(src,evnt)
handles = get(src,'userdata');
GUIuserData = get(handles.frequencyAnchorPointGUI,'userdata');
mSubstrate = GUIuserData.mSubstrate;
focusStructure = GUIuserData.focusStructure;
currentPoint = get(handles.spectrumAxis,'currentPoint');
x = currentPoint(1,1);
if isfield(mSubstrate,'maximumFrequencyAnchors')
    maxIDs = mSubstrate.maximumFrequencyAnchors;
else
    maxIDs = length(focusStructure.anchorMarksA);
    mSubstrate.maximumFrequencyAnchors = maxIDs;
end;
frequencyID = 1;
for ii = 1:focusStructure.frequencyIDcount
    if src == focusStructure.anchorMarksA(ii)
        frequencyID = ii;currentPlot = 'A';
    elseif src == focusStructure.anchorMarksB(ii)
        frequencyID = ii;currentPlot = 'B';
    elseif src == focusStructure.anchorLineA(ii)
        frequencyID = ii;currentPlot = 'A';
    elseif src == focusStructure.anchorLineB(ii)
        frequencyID = ii;currentPlot = 'B';
    end;
end;
%frequencyID
focusStructure.currentPlot = currentPlot;
focusStructure.frequencyID = frequencyID;
switch GUIuserData.currentKey
    case 'shift' %delete
        if focusStructure.frequencyIDcount == 1
            focusStructure.frequencyIDcount = 0;
            focusStructure.frequencyID = 0;
            mSubstrate.frequencyAnchorOfSpeakerA.counts(focusStructure.focusID) = 0;
            mSubstrate.frequencyAnchorOfSpeakerB.counts(focusStructure.focusID) = 0;
            %focusStructure
        else
            focusStructure.frequencyIDcount = focusStructure.frequencyIDcount-1;
            focusStructure.frequencyID = max(1,min(frequencyID,...
                focusStructure.frequencyIDcount));
            mSubstrate.frequencyAnchorOfSpeakerA.counts(focusStructure.focusID) = ...
                focusStructure.frequencyIDcount;
            mSubstrate.frequencyAnchorOfSpeakerB.counts(focusStructure.focusID) = ...
                focusStructure.frequencyIDcount;
            planeIndex = 1:focusStructure.frequencyIDcount+1;
            %planeIndex(planeIndex~=frequencyID)
            mSubstrate.frequencyAnchorOfSpeakerA.frequency(focusStructure.focusID,...
                1:focusStructure.frequencyIDcount) = ...
                focusStructure.frequencyA(planeIndex(planeIndex~=frequencyID));
            mSubstrate.frequencyAnchorOfSpeakerB.frequency(focusStructure.focusID,...
                1:focusStructure.frequencyIDcount) = ...
                focusStructure.frequencyB(planeIndex(planeIndex~=frequencyID));
            focusStructure.frequencyA(1:focusStructure.frequencyIDcount) = ...
                mSubstrate.frequencyAnchorOfSpeakerA.frequency(focusStructure.focusID,...
                1:focusStructure.frequencyIDcount);
            focusStructure.frequencyB(1:focusStructure.frequencyIDcount) = ...
                mSubstrate.frequencyAnchorOfSpeakerB.frequency(focusStructure.focusID,...
                1:focusStructure.frequencyIDcount);
            %focusStructure
        end;
        GUIuserData.focusStructure = focusStructure;
        GUIuserData.mSubstrate = mSubstrate;
        set(handles.frequencyAnchorPointGUI,'userdata',GUIuserData);
        updateDisplay(focusStructure,handles)
    otherwise % drag
        GUIuserData.currentX = x;
        set(handles.frequencyAnchorPointGUI,...
            'WindowButtonMotionFcn',@frequencyAnchorButtonMotionCallback);
        set(handles.frequencyAnchorPointGUI,...
            'WindowButtonUpFcn',@frequencyAnchorButtonUpCallback);
        %set(handles.frequencyAnchorPointGUI,'userdata',GUIuserData);
        GUIuserData.focusStructure = focusStructure;
        GUIuserData.mSubstrate = mSubstrate;
        set(handles.frequencyAnchorPointGUI,'userdata',GUIuserData);
end;
return;

function frequencyAnchorButtonMotionCallback(src,evnt)
GUIuserData = get(src,'userdata');
mSubstrate = GUIuserData.mSubstrate;
handles = GUIuserData.currentHandles;
currentPoint = get(handles.spectrumAxis,'currentPoint');
xLim = get(handles.spectrumAxis,'xlim');
%displacement = log(GUIuserData.currentX)-log(currentPoint(1,1));
%xLimUpdate = exp(log(xLim)+displacement);
%xLimUpdate = adjustUpdateXlim(xLimUpdate,handles);
%set(handles.spectrumAxis,'xlim',xLimUpdate);
xUpdate = currentPoint(1,1);%exp(log(currentPoint(1,1))-displacement);
focusStructure = GUIuserData.focusStructure;
frequencyID = focusStructure.frequencyID;
switch focusStructure.currentPlot
    case 'A'
        mSubstrate.frequencyAnchorOfSpeakerA.frequency(focusStructure.focusID,frequencyID) = ...
            xUpdate;
        focusStructure.frequencyA(frequencyID) = xUpdate;
    otherwise
        mSubstrate.frequencyAnchorOfSpeakerB.frequency(focusStructure.focusID,frequencyID) = ...
            xUpdate;
        focusStructure.frequencyB(frequencyID) = xUpdate;
end;
GUIuserData.focusStructure = focusStructure;
GUIuserData.mSubstrate = mSubstrate;
set(handles.frequencyAnchorPointGUI,'userdata',GUIuserData);
updateDisplay(focusStructure,handles)
return

function frequencyAnchorButtonUpCallback(src,evnt)
GUIuserData = get(src,'userdata');
handles = GUIuserData.currentHandles;
set(src,'WindowButtonMotionFcn',@defaultWindowMotionCallback);
set(src,'WindowButtonUpFcn','');
defaultWindowMotionCallback(src,evnt);
return;

function spectrumPlotButtonDownCallback(src,evnt)
handles = get(src,'userdata');
GUIuserData = get(handles.frequencyAnchorPointGUI,'userdata');
mSubstrate = GUIuserData.mSubstrate;
focusStructure = GUIuserData.focusStructure;
currentPoint = get(handles.spectrumAxis,'currentPoint');
x = currentPoint(1,1);
maxIDs = mSubstrate.maximumFrequencyAnchors;
switch src
    case focusStructure.spectrumPlotA
        currentPlot = 'A';
        %case focusStructure.spectrumPlotB
    otherwise
        currentPlot = 'B';
end;
%focusStructure.frequencyIDcount
if (focusStructure.frequencyIDcount > 0) && ...
        (focusStructure.frequencyIDcount < maxIDs)
    %disp('here!')
    switch currentPlot
        case 'A'
            frequecyA = [focusStructure.frequencyA(1:focusStructure.frequencyIDcount),x];
            frequecyB = [focusStructure.frequencyB(1:focusStructure.frequencyIDcount),x*1.06];
        otherwise
            frequecyA = [focusStructure.frequencyA(1:focusStructure.frequencyIDcount),x*1.06];
            frequecyB = [focusStructure.frequencyB(1:focusStructure.frequencyIDcount),x];
    end;
    [frequencyAsorted,indexSort] = sort(frequecyA);
    frequencyBsorted = frequecyB(indexSort);
    focusStructure.frequencyA(1:focusStructure.frequencyIDcount+1) = frequencyAsorted;
    focusStructure.frequencyB(1:focusStructure.frequencyIDcount+1) = frequencyBsorted;
    focusStructure.frequencyIDcount = focusStructure.frequencyIDcount+1;
    focusStructure.frequencyID = indexSort(end);
    mSubstrate.frequencyAnchorOfSpeakerA.counts(focusStructure.focusID) = ...
        focusStructure.frequencyIDcount;
    mSubstrate.frequencyAnchorOfSpeakerB.counts(focusStructure.focusID) = ...
        focusStructure.frequencyIDcount;
    mSubstrate.frequencyAnchorOfSpeakerA.frequency(focusStructure.focusID,1:focusStructure.frequencyIDcount) = ...
        focusStructure.frequencyA(1:focusStructure.frequencyIDcount);
    mSubstrate.frequencyAnchorOfSpeakerB.frequency(focusStructure.focusID,1:focusStructure.frequencyIDcount) = ...
        focusStructure.frequencyB(1:focusStructure.frequencyIDcount);
elseif focusStructure.frequencyIDcount == 0
    switch currentPlot
        case 'A'
            focusStructure.frequencyA(1) = x;
            focusStructure.frequencyB(1) = x*1.06;
        otherwise
            focusStructure.frequencyA(1) = x*1.06;
            focusStructure.frequencyB(1) = x;
    end;
    focusStructure.frequencyIDcount = 1;
    focusStructure.frequencyID = 1;
    mSubstrate.frequencyAnchorOfSpeakerA.counts(focusStructure.focusID) = 1;
    mSubstrate.frequencyAnchorOfSpeakerB.counts(focusStructure.focusID) = 1;
    mSubstrate.frequencyAnchorOfSpeakerA.frequency(focusStructure.focusID,1:focusStructure.frequencyIDcount) = ...
        focusStructure.frequencyA(1:focusStructure.frequencyIDcount);
    mSubstrate.frequencyAnchorOfSpeakerB.frequency(focusStructure.focusID,1:focusStructure.frequencyIDcount) = ...
        focusStructure.frequencyB(1:focusStructure.frequencyIDcount);
end;
GUIuserData.focusStructure = focusStructure;
GUIuserData.mSubstrate = mSubstrate;
set(handles.frequencyAnchorPointGUI,'userdata',GUIuserData);
updateDisplay(focusStructure,handles)
return;

function spectrumAxisButtonDownCallback(src,evnt)
handles = get(src,'userdata');
GUIuserData = get(handles.frequencyAnchorPointGUI,'userdata');
xLim = get(src,'xlim');
currentPoint = get(src,'currentPoint');
x = currentPoint(1,1);
if temporalAnchorGUI('isInsidePlot',handles.spectrumAxis,'axis')
    GUIuserData.currentX = x;
    set(handles.frequencyAnchorPointGUI,...
        'WindowButtonMotionFcn',@spectrumAxisButtonMotionCallback);
    set(handles.frequencyAnchorPointGUI,...
        'WindowButtonUpFcn',@spectrumAxisButtonUpCallback);
    set(handles.frequencyAnchorPointGUI,'userdata',GUIuserData);
    return;
else
    switch GUIuserData.currentKey
        case 'shift'
            xLim = exp(log(xLim/x)*sqrt(2)+log(x));
        case 'control'
            GUIuserData.currentX = x;
            set(handles.frequencyAnchorPointGUI,...
                'WindowButtonMotionFcn',@spectrumAxisButtonMotionCallback);
            set(handles.frequencyAnchorPointGUI,...
                'WindowButtonUpFcn',@spectrumAxisButtonUpCallback);
            set(handles.frequencyAnchorPointGUI,'userdata',GUIuserData);
            return;
        otherwise
            xLim = exp(log(xLim/x)/sqrt(2)+log(x));
    end;
end;
xLim = adjustUpdateXlim(xLim,handles);
set(src,'xlim',xLim);
return;

function spectrumAxisButtonMotionCallback(src,evnt)
GUIuserData = get(src,'userdata');
handles = GUIuserData.currentHandles;
currentPoint = get(handles.spectrumAxis,'currentPoint');
xLim = get(handles.spectrumAxis,'xlim');
displacement = log(GUIuserData.currentX)-log(currentPoint(1,1));
xLimUpdate = exp(log(xLim)+displacement);
xLimUpdate = adjustUpdateXlim(xLimUpdate,handles);
set(handles.spectrumAxis,'xlim',xLimUpdate);
return

function spectrumAxisButtonUpCallback(src,evnt)
GUIuserData = get(src,'userdata');
handles = GUIuserData.currentHandles;
set(src,'WindowButtonMotionFcn',@defaultWindowMotionCallback);
set(src,'WindowButtonUpFcn','');
defaultWindowMotionCallback(src,evnt);
return;

function xLim = adjustUpdateXlim(xLim,handles)
GUIuserData = get(handles.frequencyAnchorPointGUI,'userdata');
fs = GUIuserData.mSubstrate.samplintFrequency;
%xLim = max(100,min(fs/2,xLim));
if xLim(1) < 100
    xLim = xLim/xLim(1)*100;
end;
if xLim(2) > fs/2
    xLim = xLim/xLim(2)*fs/2;
end;
if xLim(2)/xLim(1) > (fs/2)/100
    xLim = [100 fs/2];
end;
return;

function createFrequencyAnchorIfItIsNotThere(handles)
GUIuserData = get(handles.frequencyAnchorPointGUI,'userdata');
mSubstrate = GUIuserData.mSubstrate;
if ~isfield(mSubstrate,'frequencyAnchorOfSpeakerA') || ...
        isempty(mSubstrate.frequencyAnchorOfSpeakerA)
    disp('No anchor is there')
    totalTimeAnchors = 1;
    focusStructure.totalTimeAnchors = 1;
    mSubstrate.frequencyAnchorOfSpeakerA.counts = ...
        zeros(totalTimeAnchors,1);
    mSubstrate.frequencyAnchorOfSpeakerB.counts = ...
        zeros(totalTimeAnchors,1);
    mSubstrate.frequencyAnchorOfSpeakerA.frequency = ...
        zeros(totalTimeAnchors,6);
    mSubstrate.frequencyAnchorOfSpeakerB.frequency = ...
        zeros(totalTimeAnchors,6);
    mSubstrate.temporaAnchorOfSpeakerA = ...
        (mSubstrate.spectrogramTimeBaseOfSpeakerA(1) +...
        mSubstrate.spectrogramTimeBaseOfSpeakerA(end))/2;
    mSubstrate.temporaAnchorOfSpeakerB = ...
        (mSubstrate.spectrogramTimeBaseOfSpeakerB(1) +...
        mSubstrate.spectrogramTimeBaseOfSpeakerB(end))/2;
    focusStructure.frequencyIDcount = 0;
    focusStructure.frequencyA = 500+(0:5)*1000;
    focusStructure.frequencyB = 550+(0:5)*1000;
    for ii = 1:totalTimeAnchors
        mSubstrate.frequencyAnchorOfSpeakerA.frequency(ii,:) = ...
            focusStructure.frequencyA;
        mSubstrate.frequencyAnchorOfSpeakerB.frequency(ii,:) = ...
            focusStructure.frequencyB;
    end;
    GUIuserData.mSubstrate = mSubstrate;
    GUIuserData.focusStructure = focusStructure;
end;
mSubstrate.maximumFrequencyAnchors = size(mSubstrate.frequencyAnchorOfSpeakerA.frequency,2);
GUIuserData.mSubstrate = mSubstrate;
set(handles.frequencyAnchorPointGUI,'userdata',GUIuserData);
if isfield(GUIuserData,'temporalAnchorGUI') && ...
        ishandle(GUIuserData.temporalAnchorGUI)
    temporalGUIuserData = get(GUIuserData.temporalAnchorGUI,'userdata');
    temporalGUIuserData.mSubstrate.frequencyAnchorOfSpeakerA = ...
        mSubstrate.frequencyAnchorOfSpeakerA;
    temporalGUIuserData.mSubstrate.frequencyAnchorOfSpeakerB = ...
        mSubstrate.frequencyAnchorOfSpeakerB;
    set(GUIuserData.temporalAnchorGUI,'userdata',temporalGUIuserData);
end;
return;

function focusStructure = getFocusInformation(temporalGUIuserData)
mSubstrate = temporalGUIuserData.mSubstrate;
fs = mSubstrate.samplintFrequency;
timeAnchorA = mSubstrate.temporaAnchorOfSpeakerA;
timeAnchorB = mSubstrate.temporaAnchorOfSpeakerB;
focusID = max(1,min(temporalGUIuserData.currentFocusID-1,length(timeAnchorA)));
anchorTimeA = timeAnchorA(focusID);
anchorTimeB = timeAnchorB(focusID);
[dmmy,frameIDonA] = min(abs(mSubstrate.spectrogramTimeBaseOfSpeakerA-anchorTimeA));
[dmmy,frameIDonB] = min(abs(mSubstrate.spectrogramTimeBaseOfSpeakerB-anchorTimeB));
focusStructure.focusID = focusID;
focusStructure.totalTimeAnchors = length(timeAnchorA);
focusStructure.frameIDonA = frameIDonA;
focusStructure.frameIDonB = frameIDonB;
focusStructure.samplingFrequency = fs;
focusStructure.spectrumA = mSubstrate.STRAIGHTspectrogramOfSpeakerA(:,frameIDonA);
focusStructure.spectrumB = mSubstrate.STRAIGHTspectrogramOfSpeakerB(:,frameIDonB);
focusStructure.fftl = (size(focusStructure.spectrumA,1)-1)*2;
focusStructure.frequencyAxis = (0:size(focusStructure.spectrumA,1)-1)/ ...
    focusStructure.fftl*fs;
focusStructure.timeAxisA = mSubstrate.spectrogramTimeBaseOfSpeakerA;
focusStructure.timeAxisB = mSubstrate.spectrogramTimeBaseOfSpeakerB;
if isfield(mSubstrate,'frequencyAnchorOfSpeakerA') && ...
        ~isempty(mSubstrate.frequencyAnchorOfSpeakerA) && ...
        isfield(mSubstrate.frequencyAnchorOfSpeakerA,'frequency') && ...
        ~isempty(mSubstrate.frequencyAnchorOfSpeakerA.frequency)
    focusStructure.frequencyIDcount = ...
        mSubstrate.frequencyAnchorOfSpeakerA.counts(focusID);
    focusStructure.frequencyA = ...
        mSubstrate.frequencyAnchorOfSpeakerA.frequency(focusID,:);
    focusStructure.frequencyB = ...
        mSubstrate.frequencyAnchorOfSpeakerB.frequency(focusID,:);
    if focusStructure.frequencyIDcount > 0
        focusStructure.frequencyID = 1;
    else
        focusStructure.frequencyID = 0;
    end;
end;
return;

function focusStructure = showSpectralPlot(focusStructure,handles)
axes(handles.spectrumAxis);
set(handles.spectrumAxis,'userdata',handles);
fs = focusStructure.samplingFrequency;
dBSpectrumA = 10*log10(focusStructure.spectrumA);
dBSpectrumB = 10*log10(focusStructure.spectrumB);
spectrumPlotA = ...
    semilogx(focusStructure.frequencyAxis,dBSpectrumA,'b-',...
    'linewidth',2);
hold on;
spectrumPlotB = ...
    semilogx(focusStructure.frequencyAxis,dBSpectrumB,'r-', ...
    'linewidth',2);
grid on;
set(gca,'fontsize',12);
xlabel('frequency (Hz)');
ylabel('relative level (dB)');
maxLevel = max(max(dBSpectrumA),max(dBSpectrumB));
axis([100 fs/2 maxLevel-70 maxLevel+5]);
focusStructure = showFrequencyAnchors(focusStructure,handles);
hold off
focusStructure.handles = handles;
focusStructure.axis = handles.spectrumAxis;
focusStructure.spectrumPlotA = spectrumPlotA;
focusStructure.spectrumPlotB = spectrumPlotB;
set(focusStructure.spectrumPlotA,'userdata',handles);
set(focusStructure.spectrumPlotB,'userdata',handles);
return;

function focusStructure = showFrequencyAnchors(focusStructure,handles)
GUIuserData = get(handles.frequencyAnchorPointGUI,'userdata');
mSubstrate = GUIuserData.mSubstrate;
maxIDs = mSubstrate.maximumFrequencyAnchors;
dBSpectrumA = 10*log10(focusStructure.spectrumA);
dBSpectrumB = 10*log10(focusStructure.spectrumB);
anchorLevelA = interp1(focusStructure.frequencyAxis,dBSpectrumA,...
    focusStructure.frequencyA,'linear','extrap');
anchorLevelB = interp1(focusStructure.frequencyAxis,dBSpectrumB,...
    focusStructure.frequencyB,'linear','extrap');
focusStructure.anchorConnection = zeros(maxIDs,1);
focusStructure.anchorMarksA = zeros(maxIDs,1);
focusStructure.anchorMarksB = zeros(maxIDs,1);
focusStructure.anchorLineA = zeros(maxIDs,1);
focusStructure.anchorLineA = zeros(maxIDs,1);
for ii = 1:maxIDs
    focusStructure.anchorConnection(ii) = ...
        plot([focusStructure.frequencyA(ii) focusStructure.frequencyB(ii)],...
        [anchorLevelA(ii) anchorLevelB(ii)],'g','linewidth',2);
    set(focusStructure.anchorConnection(ii),'userdata',handles);
    focusStructure.anchorMarksA(ii) = ...
        plot(focusStructure.frequencyA(ii),anchorLevelA(ii),'ob',...
        'markerfacecolor','b','markersize',10);
    set(focusStructure.anchorMarksA(ii),'userdata',handles);
    focusStructure.anchorMarksB(ii) = ...
        plot(focusStructure.frequencyB(ii),anchorLevelB(ii),'or',...
        'markerfacecolor','r','markersize',10);
    set(focusStructure.anchorMarksB(ii),'userdata',handles);
    focusStructure.anchorLineA(ii) = ...
        plot(focusStructure.frequencyA(ii)*[1 1],[-1000 1000],'b',...
        'linewidth',1);
    set(focusStructure.anchorLineA(ii),'userdata',handles);
    focusStructure.anchorLineB(ii) = ...
        plot(focusStructure.frequencyB(ii)*[1 1],[-1000 1000],'r',...
        'linewidth',1);
    set(focusStructure.anchorLineB(ii),'userdata',handles);
    if ii > focusStructure.frequencyIDcount
        set(focusStructure.anchorConnection(ii),'visible','off');
        set(focusStructure.anchorMarksA(ii),'visible','off');
        set(focusStructure.anchorMarksB(ii),'visible','off');
        set(focusStructure.anchorLineA(ii),'visible','off');
        set(focusStructure.anchorLineB(ii),'visible','off');
    end;
end;
return;

function focusStructure = updateFrequencyAnchors(focusStructure)
handles = focusStructure.handles;
GUIuserData = get(handles.frequencyAnchorPointGUI,'userdata');
mSubstrate = GUIuserData.mSubstrate;
if isfield(mSubstrate,'maximumFrequencyAnchors')
    maxIDs = mSubstrate.maximumFrequencyAnchors;
else
    maxIDs = size(focusStructure.anchorConnection);
    mSubstrate.maximumFrequencyAnchors = maxIDs;
end;
dBSpectrumA = 10*log10(focusStructure.spectrumA);
dBSpectrumB = 10*log10(focusStructure.spectrumB);
anchorLevelA = interp1(focusStructure.frequencyAxis,dBSpectrumA,...
    focusStructure.frequencyA,'linear','extrap');
anchorLevelB = interp1(focusStructure.frequencyAxis,dBSpectrumB,...
    focusStructure.frequencyB,'linear','extrap');
for ii = 1:maxIDs
    set(focusStructure.anchorConnection(ii),'xdata', ...
        [focusStructure.frequencyA(ii) focusStructure.frequencyB(ii)],...
        'ydata',[anchorLevelA(ii) anchorLevelB(ii)]);
    set(focusStructure.anchorMarksA(ii),'xdata', ...
        focusStructure.frequencyA(ii),'ydata',anchorLevelA(ii));
    set(focusStructure.anchorMarksB(ii),'xdata', ...
        focusStructure.frequencyB(ii),'ydata',anchorLevelB(ii));
    set(focusStructure.anchorLineA(ii),'xdata', ...
        focusStructure.frequencyA(ii)*[1 1]);
    set(focusStructure.anchorLineB(ii),'xdata', ...
        focusStructure.frequencyB(ii)*[1 1]);
    if ii > focusStructure.frequencyIDcount
        set(focusStructure.anchorConnection(ii),'visible','off');
        set(focusStructure.anchorMarksA(ii),'visible','off');
        set(focusStructure.anchorMarksB(ii),'visible','off');
        set(focusStructure.anchorLineA(ii),'visible','off');
        set(focusStructure.anchorLineB(ii),'visible','off');
    else
        set(focusStructure.anchorConnection(ii),'visible','on');
        set(focusStructure.anchorMarksA(ii),'visible','on');
        set(focusStructure.anchorMarksB(ii),'visible','on');
        set(focusStructure.anchorLineA(ii),'visible','on');
        set(focusStructure.anchorLineB(ii),'visible','on');
    end;
    if ii == focusStructure.frequencyID
        set(focusStructure.anchorLineA(ii),'linewidth',2);
        set(focusStructure.anchorLineB(ii),'linewidth',2);
    else
        set(focusStructure.anchorLineA(ii),'linewidth',1);
        set(focusStructure.anchorLineB(ii),'linewidth',1);
    end
end;
return;

function displayFocusInformation(focusStructure,handles)
timeAnchorIDstring = ['Anchor ID#: ' num2str(focusStructure.focusID) ...
    ' in ' num2str(focusStructure.totalTimeAnchors)];
set(handles.anchorIDtext,'string',timeAnchorIDstring);
timeOnAString = ...
    ['Time A: ' num2str(focusStructure.timeAxisA(focusStructure.frameIDonA),'%-10.3f') ...
    ' s (ID: ' num2str(focusStructure.frameIDonA,'%-10d') ')'];
set(handles.timeOnAtext,'string',timeOnAString);
timeOnBString = ...
    ['Time B: ' num2str(focusStructure.timeAxisB(focusStructure.frameIDonB),'%-10.3f') ...
    ' s (ID: ' num2str(focusStructure.frameIDonB,'%-10d') ')'];
set(handles.timeOnBtext,'string',timeOnBString);
if focusStructure.frequencyIDcount > 0
    frequencyAnchorIDstring = ['Anchor ID#: ' num2str(focusStructure.frequencyID) ...
        ' in ' num2str(focusStructure.frequencyIDcount)];
    set(handles.frequencyAnchorIDtext,'string',frequencyAnchorIDstring);
    %frequencyAtext
    anchorAfrequencyString = ...
        ['A: ' num2str(focusStructure.frequencyA(focusStructure.frequencyID),'%-8.1f') ...
        ' Hz'];
    set(handles.frequencyAtext,'string',anchorAfrequencyString);
    anchorBfrequencyString = ...
        ['B: ' num2str(focusStructure.frequencyB(focusStructure.frequencyID),'%-8.1f') ...
        ' Hz'];
    set(handles.frequencyBtext,'string',anchorBfrequencyString);
else
    frequencyAnchorIDstring = ['Anchor ID#: ' num2str(0) ' in ' num2str(0)];
    set(handles.frequencyAnchorIDtext,'string',frequencyAnchorIDstring);
    set(handles.frequencyAtext,'string','A: ------- Hz');
    set(handles.frequencyBtext,'string','B: ------- Hz');
end;
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
%disp('key released')
set(src,'userdata',GUIuserData);
if isfield(GUIuserData,'temporalAnchorGUI') && ...
        ishandle(GUIuserData.temporalAnchorGUI)
    temporalAnchorGUIuserData = get(GUIuserData.temporalAnchorGUI,'userdata');
    %disp(temporalAnchorGUIuserData.currentKey);
    temporalAnchorGUIuserData.currentKey = 'none';
    set(GUIuserData.temporalAnchorGUI,'userdata',temporalAnchorGUIuserData);
    temporalAnchorGUI('defaultWindowMotionCallback',GUIuserData.temporalAnchorGUI,evnt);
end;
set(src,'userdata',GUIuserData);
defaultWindowMotionCallback(src,evnt);
return;

function defaultWindowMotionCallback(src,evnt)
GUIuserData = get(src,'userdata');
handles = GUIuserData.currentHandles;
if temporalAnchorGUI('isInsidePlot',handles.spectrumAxis,'axis')
    if isOnFrequencyAnchor(GUIuserData.focusStructure.anchorMarksA)
        switch GUIuserData.currentKey
            case 'shift'
                setPointerShape(7);
            otherwise
                setPointerShape(5);
        end;
    elseif isOnFrequencyAnchor(GUIuserData.focusStructure.anchorMarksB)
        switch GUIuserData.currentKey
            case 'shift'
                setPointerShape(7);
            otherwise
                setPointerShape(5);
        end;
    elseif closeToSpecificLogxLine(GUIuserData.focusStructure.spectrumPlotA) < 5
        setPointerShape(8);
    elseif closeToSpecificLogxLine(GUIuserData.focusStructure.spectrumPlotB) < 5
        setPointerShape(8);
    else
%        switch GUIuserData.currentKey
%            case 'shift'
%                setPointerShape(2);
%            case 'control'
%                setPointerShape(3);
%            otherwise
%                setPointerShape(1);
%        end;
        setPointerShape(3);
    end
elseif temporalAnchorGUI('isInsidePlot',handles.spectrumAxis,'fringe')
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

function answerValue = isOnFrequencyAnchor(frequencyAnchorHandle)
axisHandle = get(frequencyAnchorHandle(1),'parent');
handles = get(frequencyAnchorHandle(1),'userdata');
GUIuserData = get(handles.frequencyAnchorPointGUI,'userdata');
answerValue = 0;
if ~temporalAnchorGUI('isInsidePlot',axisHandle,'axis')
    return;
end;
for ii = 1:GUIuserData.focusStructure.frequencyIDcount
    xData = get(frequencyAnchorHandle(ii),'xdata');
    yData = get(frequencyAnchorHandle(ii),'ydata');
    xLim = get(axisHandle,'xLim');
    yLim = get(axisHandle,'yLim');
    currentPoint = get(axisHandle,'currentPoint');
    x = currentPoint(1,1);
    y = currentPoint(1,2);
    axisUnits = get(axisHandle,'Units');
    set(axisHandle,'Units','pixels');
    axisPosition = get(axisHandle,'position');
    set(axisHandle,'Units',axisUnits);
    xp = log(x)/log(xLim(2)/xLim(1))*axisPosition(3);
    x1 = log(xData)/log(xLim(2)/xLim(1))*axisPosition(3);
    yp = y/(yLim(2)-yLim(1))*axisPosition(4);
    y1 = yData/(yLim(2)-yLim(1))*axisPosition(4);
    if sqrt((xp-x1)^2+(yp-y1)^2) < 5
        answerValue = 1;
    end;
end;
return

function answerValue = closeToSpecificLogxLine(lineHandle)
answerValue = 100000;
xData = max(0.0001,get(lineHandle,'xdata'));
yData = get(lineHandle,'ydata');
axisHandle = get(lineHandle,'parent');
xLim = get(axisHandle,'xLim');
yLim = get(axisHandle,'yLim');
currentPoint = get(axisHandle,'currentPoint');
x = currentPoint(1,1);
y = currentPoint(1,2);
if ~temporalAnchorGUI('isInsidePlot',axisHandle,'axis')
    return;
end;
axisUnits = get(axisHandle,'Units');
set(axisHandle,'Units','pixels');
axisPosition = get(axisHandle,'position');
set(axisHandle,'Units',axisUnits);
xp = log(x)/log(xLim(2)/xLim(1))*axisPosition(3);
x1 = log(xData)/log(xLim(2)/xLim(1))*axisPosition(3);
yp = y/(yLim(2)-yLim(1))*axisPosition(4);
y1 = yData/(yLim(2)-yLim(1))*axisPosition(4);
for ii = 1:length(x1)-1
    currentDistance = proximityToSegment(x1(ii),x1(ii+1),y1(ii),y1(ii+1),xp,yp);
    if currentDistance < answerValue
        answerValue = currentDistance;
    end;
end;
return;

function focusStructure = getUpdatedFocusInformation(focusStructure,handles)
GUIuserdata = get(handles.frequencyAnchorPointGUI,'userdata');
%if isfield(GUIuserdata,'temporalAnchorGUI')
%    temporalGUIuserData = get(GUIuserdata.temporalAnchorGUI,'userdata');
%else
%    temporalGUIuserData = GUIuserdata;
%end;
temporalGUIuserData = GUIuserdata;
mSubstrate = temporalGUIuserData.mSubstrate;
timeAnchorA = mSubstrate.temporaAnchorOfSpeakerA;
timeAnchorB = mSubstrate.temporaAnchorOfSpeakerB;
focusID = focusStructure.focusID;
anchorTimeA = timeAnchorA(focusID);
anchorTimeB = timeAnchorB(focusID);
[dmmy,frameIDonA] = min(abs(mSubstrate.spectrogramTimeBaseOfSpeakerA-anchorTimeA));
[dmmy,frameIDonB] = min(abs(mSubstrate.spectrogramTimeBaseOfSpeakerB-anchorTimeB));
focusStructure.frameIDonA = frameIDonA;
focusStructure.frameIDonB = frameIDonB;
focusStructure.spectrumA = mSubstrate.STRAIGHTspectrogramOfSpeakerA(:,frameIDonA);
focusStructure.spectrumB = mSubstrate.STRAIGHTspectrogramOfSpeakerB(:,frameIDonB);
if isfield(mSubstrate,'frequencyAnchorOfSpeakerA') && ...
        ~isempty(mSubstrate.frequencyAnchorOfSpeakerA) && ...
        isfield(mSubstrate.frequencyAnchorOfSpeakerA,'frequency') && ...
        ~isempty(mSubstrate.frequencyAnchorOfSpeakerA.frequency)
    focusStructure.frequencyIDcount = ...
        mSubstrate.frequencyAnchorOfSpeakerA.counts(focusID);
    focusStructure.frequencyA = ...
        mSubstrate.frequencyAnchorOfSpeakerA.frequency(focusID,:);
    focusStructure.frequencyB = ...
        mSubstrate.frequencyAnchorOfSpeakerB.frequency(focusID,:);
    if focusStructure.frequencyIDcount > 0
        focusStructure.frequencyID = min(focusStructure.frequencyIDcount, ...
            max(1,focusStructure.frequencyID));
    else
        focusStructure.frequencyID = 0;
    end;
end;
return;

% --- Executes on button press in previousButton.
function previousButton_Callback(hObject, eventdata, handles)
% hObject    handle to previousButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUIuserdata = get(handles.frequencyAnchorPointGUI,'userdata');
focusStructure = GUIuserdata.focusStructure;
mSubstrate = GUIuserdata.mSubstrate;
focusStructure.focusID = max(1,focusStructure.focusID-1);
focusStructure = getUpdatedFocusInformation(focusStructure,handles);
GUIuserdata.focusStructure = focusStructure;
updateDisplay(focusStructure,handles);
set(handles.frequencyAnchorPointGUI,'userdata',GUIuserdata);
return;

% --- Executes on button press in nextButton.
function nextButton_Callback(hObject, eventdata, handles)
% hObject    handle to nextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUIuserdata = get(handles.frequencyAnchorPointGUI,'userdata');
focusStructure = GUIuserdata.focusStructure;
mSubstrate = GUIuserdata.mSubstrate;
focusStructure.focusID = ...
    min(focusStructure.totalTimeAnchors,focusStructure.focusID+1);
focusStructure = getUpdatedFocusInformation(focusStructure,handles);
GUIuserdata.focusStructure = focusStructure;
updateDisplay(focusStructure,handles);
set(handles.frequencyAnchorPointGUI,'userdata',GUIuserdata);
return;

function updateDisplay(focusStructure,handles)
GUIuserdata = get(handles.frequencyAnchorPointGUI,'userdata');
mSubstrate = GUIuserdata.mSubstrate;
dBSpectrumA = 10*log10(focusStructure.spectrumA);
dBSpectrumB = 10*log10(focusStructure.spectrumB);
set(focusStructure.spectrumPlotA,'ydata',dBSpectrumA);
set(focusStructure.spectrumPlotB,'ydata',dBSpectrumB);
maxLevel = max(max(dBSpectrumA),max(dBSpectrumB));
set(focusStructure.axis,'ylim',[maxLevel-70 maxLevel+5]);
focusStructure = updateFrequencyAnchors(focusStructure);
displayFocusInformation(focusStructure,handles);
return;

% --- Executes on button press in previousTimeAbutton.
function previousTimeAbutton_Callback(hObject, eventdata, handles)
% hObject    handle to previousTimeAbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in nextAbutton.
function nextAbutton_Callback(hObject, eventdata, handles)
% hObject    handle to nextAbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in updateFrequencyAnchorButton.
function updateFrequencyAnchorButton_Callback(hObject, eventdata, handles)
% hObject    handle to updateFrequencyAnchorButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUIuserData = get(handles.frequencyAnchorPointGUI,'userdata');
temporalGUIuserData = get(GUIuserData.temporalAnchorGUI,'userdata');
temporalGUIuserData.mSubstrate.frequencyAnchorOfSpeakerA = ...
    GUIuserData.mSubstrate.frequencyAnchorOfSpeakerA;
temporalGUIuserData.mSubstrate.frequencyAnchorOfSpeakerB = ...
    GUIuserData.mSubstrate.frequencyAnchorOfSpeakerB;
set(GUIuserData.temporalAnchorGUI,'userData',temporalGUIuserData);
%temporalAnchorGUI('userdata',GUIuserData.mSubstrate);
figure(GUIuserData.temporalAnchorGUI);
return;

% --- Executes on button press in previousBbutton.
function previousBbutton_Callback(hObject, eventdata, handles)
% hObject    handle to previousBbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in nextBbutton.
function nextBbutton_Callback(hObject, eventdata, handles)
% hObject    handle to nextBbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in lowerButton.
function lowerButton_Callback(hObject, eventdata, handles)
% hObject    handle to lowerButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%display('lower button')
GUIuserdata = get(handles.frequencyAnchorPointGUI,'userdata');
focusStructure = GUIuserdata.focusStructure;
mSubstrate = GUIuserdata.mSubstrate;
%disp([num2str(focusStructure.frequencyIDcount)]);
if focusStructure.frequencyIDcount > 1
    focusStructure.frequencyID = max(1,focusStructure.frequencyID-1);
end;
focusStructure = getUpdatedFocusInformation(focusStructure,handles);
GUIuserdata.focusStructure = focusStructure;
updateDisplay(focusStructure,handles);
set(handles.frequencyAnchorPointGUI,'userdata',GUIuserdata);
return;

% --- Executes on button press in higherButton.
function higherButton_Callback(hObject, eventdata, handles)
% hObject    handle to higherButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%display('higher button')
GUIuserdata = get(handles.frequencyAnchorPointGUI,'userdata');
focusStructure = GUIuserdata.focusStructure;
mSubstrate = GUIuserdata.mSubstrate;
%disp([num2str(focusStructure.frequencyID)]);
if focusStructure.frequencyIDcount > 1
    focusStructure.frequencyID = ...
        min(focusStructure.frequencyIDcount,focusStructure.frequencyID+1);
end;
focusStructure = getUpdatedFocusInformation(focusStructure,handles);
GUIuserdata.focusStructure = focusStructure;
updateDisplay(focusStructure,handles);
set(handles.frequencyAnchorPointGUI,'userdata',GUIuserdata);
return;

% --- Executes on button press in saveMorphingSubstrateButton.
function saveMorphingSubstrateButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveMorphingSubstrateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUIuserData = get(handles.frequencyAnchorPointGUI,'userdata');
revisedData = GUIuserData.mSubstrate;
revisedData.lastUpdate = datestr(now);
revisedData.lastModificationBy = 'frequencyAnchorPointGUI';
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
