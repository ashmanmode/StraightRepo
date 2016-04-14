function varargout = morphingRateGUI(varargin)
% MORPHINGRATEGUI M-file for morphingRateGUI.fig
%      MORPHINGRATEGUI, by itself, creates a new MORPHINGRATEGUI or raises
%      the existing
%      singleton*.
%
%      H = MORPHINGRATEGUI returns the handle to a new MORPHINGRATEGUI or the handle to
%      the existing singleton*.
%
%      MORPHINGRATEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MORPHINGRATEGUI.M with the given input arguments.
%
%      MORPHINGRATEGUI('Property','Value',...) creates a new MORPHINGRATEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before morphingRateGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to morphingRateGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help morphingRateGUI

% Last Modified by GUIDE v2.5 15-Mar-2009 22:26:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @morphingRateGUI_OpeningFcn, ...
    'gui_OutputFcn',  @morphingRateGUI_OutputFcn, ...
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

%   Revision information
%   13/Oct./2009 bug fix for add/remove temporal anchors
%   21/April/2012 revision for compatibility with R2011a
%   24/April/2012 revision for unnecessary modification

% --- Executes just before morphingRateGUI is made visible.
function morphingRateGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to morphingRateGUI (see VARARGIN)

% Choose default command line output for morphingRateGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% User defined initialization
set(handles.morphingGUIbase,'units','normalized');
mSubstrate = get(hObject,'userdata');
if ~isempty(mSubstrate)
    mSubstrate.creationDate = datestr(now,30);
else
    [file,path] = uigetfile('*.mat','Select file with morphing substrate.');
    if length(file) == 1 && length(path) == 1
        if file == 0 || path == 0
            disp('Load is cancelled!');
            return;
        end;
    end;
    %pathReg = regexprep(path,'\s','\\ ');
    %eval(['load ' pathReg file]);
    load([path file]);
    mSubstrate = revisedData;
    mSubstrate.substrateDirectory = path;
    mSubstrate.substrateFile = file;
end;
%handles
%mSubstrate.spectrogramAxis = subplot(handles.Spectrogram);
%imagesc(log(mSubstrate.STRAIGHTspectrogramOfSpeakerA));axis('xy')
mSubstrate.currentHandles = handles;
mSubstrate.currentKey = 'none';
set(hObject,'userdata',mSubstrate);
setupDisplay(hObject,handles,'A');

%locateTopLeftOfGUI(Top,Left,GUIHandle)
TandemSTRAIGHThandler('locateTopLeftOfGUI',65,70,handles.morphingGUIbase);

%----------- assign callback to attribute button ------
set(handles.SpeakerPanel,'SelectionChangeFcn',@speakerPanel_callback);
set(handles.SpeakerPanel,'userdata',handles);
set(handles.ViewerFunctionPanel,'SelectionChangeFcn',@ViewerFunctionPanel_callback);
set(handles.ViewerFunctionPanel,'userdata',handles);
%----------- set viewer to monitor mode at first ------
set(handles.slider1,'enable','off');
set(handles.edit1,'enable','off');
set(handles.PasteButton,'enable','off');
set(handles.spectrogramColormap,'value',2);
%set(handles.timeButton,'userdata',handles);
set(handles.morphingGUIbase,'keyPressFcn',@keyPressCallBack);
set(handles.morphingGUIbase,'KeyReleaseFcn',@keyReleaseCallBack);
set(handles.morphingGUIbase,'WindowButtonMotionFcn',@defaultButtonMotionCallBack);
%handles
%syncGUIStatus(handles)


% UIWAIT makes morphingRateGUI wait for user response (see UIRESUME)
% uiwait(handles.morphingGUIbase);


% --- Outputs from this function are returned to the command line.
function varargout = morphingRateGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sValue = get(hObject,'Value');
set(handles.edit1,'string',num2str(sValue,'%6.3f'));
mSubstrate = get(handles.morphingGUIbase,'userdata');
if isfield(mSubstrate,'groupHandle');
    knobHandle = mSubstrate.currentMultiSlider;
    groupHandle = mSubstrate.groupHandle;
    userData = get(groupHandle,'userdata');
    knobYdata = get(knobHandle,'ydata');
    ydata = get(groupHandle,'ydata');
    delta = sValue-ydata(userData.anchorIndex);
    ydata = max(0,min(1,ydata+delta));
    knobYdata(userData.activeIndex) = ydata;
    set(groupHandle,'ydata',ydata);
    set(knobHandle,'ydata',knobYdata);
    if get(mSubstrate.currentHandles.bindButton,'value')
    for ii = 1:5
        knobHandle = eval(['mSubstrate.' mSubstrate.knobNames{ii}  '.plot;']);
        set(knobHandle,'ydata',knobYdata);
    end;
end;

end;


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
eValue = str2double(get(hObject,'String'));
set(handles.slider1,'value',eValue);
mSubstrate = get(handles.morphingGUIbase,'userdata');
if isfield(mSubstrate,'groupHandle');
    knobHandle = mSubstrate.currentMultiSlider;
    groupHandle = mSubstrate.groupHandle;
    userData = get(groupHandle,'userdata');
    knobYdata = get(knobHandle,'ydata');
    ydata = get(groupHandle,'ydata');
    delta = eValue-ydata(userData.anchorIndex);
    ydata = max(0,min(1,ydata+delta));
    knobYdata(userData.activeIndex) = ydata;
    set(groupHandle,'ydata',ydata);
    set(knobHandle,'ydata',knobYdata);
    if get(mSubstrate.currentHandles.bindButton,'value')
    for ii = 1:5
        knobHandle = eval(['mSubstrate.' mSubstrate.knobNames{ii}  '.plot;']);
        set(knobHandle,'ydata',knobYdata);
    end;
end;
end;

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- user defined internal function -------
function setupDisplay(hObject,handles,referenceID)

mSubstrate = get(handles.morphingGUIbase,'userdata');
fs = mSubstrate.samplintFrequency;
switch referenceID
    case 'A'
        dBSTRAIGHTspectrogram = 10*log10(mSubstrate.STRAIGHTspectrogramOfSpeakerA);
        referenceTimeAxis = mSubstrate.spectrogramTimeBaseOfSpeakerA;
        timeAnchors = mSubstrate.temporaAnchorOfSpeakerA;
        set(handles.SelectA,'value',1);
        set(handles.SelectB,'value',0);
        referenceTimeDefiningValue = 0;
    case 'B'
        dBSTRAIGHTspectrogram = 10*log10(mSubstrate.STRAIGHTspectrogramOfSpeakerB);
        referenceTimeAxis = mSubstrate.spectrogramTimeBaseOfSpeakerB;
        timeAnchors = mSubstrate.temporaAnchorOfSpeakerB;
        set(handles.SelectA,'value',0);
        set(handles.SelectB,'value',1);
        referenceTimeDefiningValue = 1;
    otherwise
        disp('Assigned reference ID is not known')
        return;
end;
mSubstrate = morphingSubstrateNewAP(mSubstrate,...
    'generate','morphingTimeAxis',referenceTimeDefiningValue);
mSubstrate.referenceTimeAxis = referenceTimeAxis;
%-------------- show spectrogram -----
startTime = referenceTimeAxis(1);
endTime = referenceTimeAxis(end);
highLimit = min(fs/2,6000);
minLevel = max(max(dBSTRAIGHTspectrogram))-75;
mSubstrate.spectrogramAxis = subplot(handles.Spectrogram);
mSubstrate.spectrogramHandle = imagesc([startTime,endTime],[0 fs/2],...
    max(minLevel,dBSTRAIGHTspectrogram));
%colormap(1-gray);
axis('xy');
axis([startTime,endTime 0 highLimit]);
set(gca,'fontsize',12);
ylabelHandle = ylabel('frequency (Hz)');
set(ylabelHandle,'fontsize',14,'fontname','Helvetica');
% --- and set button down callback ---
set(mSubstrate.spectrogramHandle,'ButtonDownFcn',@spectrogramButtonDn_callback);
set(mSubstrate.spectrogramHandle,'userdata',handles);
%-------------- show morphing rate knobs ----
%-------- initialize knobs ----
mSubstrate.plotHandles = {'MorphingRateSpectrum','MorphingRateFrequency',...
    'MorphingRateAperiodicity','MorphingRateF0','MorphingRateTime'};
mSubstrate.knobNames = {'SpectrumKnob','FrequencyKnob','AperiodicityKnob',...
    'F0Knob','TimeKnob'};
numberOfAttributes = 5;
if ~isfield(mSubstrate,'anchorOnMorphingTime')
    disp('No temporal anchor points exit.');
    set(hObject,'userdata',mSubstrate);
    return;
elseif ~isfield(mSubstrate,'morphingKnobs') && ~isfield(mSubstrate,'knobYdata')
    morphingKnobs = 0.5+ ...
        zeros(numberOfAttributes,length(mSubstrate.anchorOnMorphingTime)+2);
    %morphingKnobs = 0.5+ ...
    %    randn(numberOfAttributes,length(mSubstrate.anchorOnMorphingTime))*0.1;
    %elseif ~isfield(mSubstrate,'temporalMorphingRate') % I am thinking. HK 06 Dec. 08
    %    disp('No temporal morphing rate definition exit.');
    %    set(hObject,'userdata',mSubstrate);
    %    return;
elseif ~isfield(mSubstrate,'morphingKnobs') && isfield(mSubstrate,'knobYdata') && ...
        (length(mSubstrate.anchorOnMorphingTime)+2 == length(mSubstrate.knobYdata{1}))
    morphingKnobs = ...
        zeros(numberOfAttributes,length(mSubstrate.anchorOnMorphingTime)+2);
    %fieldNames = {'spectrum';'frequency';'aperiodicity';'F0';'time'};
    for kk = 1:numberOfAttributes
        tmp = mSubstrate.knobYdata{kk};
        morphingKnobs(kk,:) = tmp(1:end);
    end;
elseif ~isfield(mSubstrate,'morphingKnobs') && isfield(mSubstrate,'knobYdata') && ...
        ~(length(mSubstrate.anchorOnMorphingTime)+2 == length(mSubstrate.knobYdata{1}))
    morphingKnobs = 0.5+ ...
        zeros(numberOfAttributes,length(mSubstrate.anchorOnMorphingTime)+2);
end;
%-------- initialize foci -----
mSubstrate.currentAttributeID = 4;
mSubstrate.currentTimeAnchorID = 1;
%-------- display knobs -------
for ii = 1:5
    mSubstrate = ...
        writeMultiSlider(handles,mSubstrate,...
        timeAnchors,startTime,endTime,morphingKnobs,ii);
end;
mSubstrate = multiSliderAxesShaping(mSubstrate,1);
%-------- initialize parameter binding -------
mSubstrate.attributeBindibg = 1;
mSubstrate.temporalBinding = 1;
%-------- set slider value ----
set(handles.slider1,'value',morphingKnobs(mSubstrate.currentAttributeID,...
    mSubstrate.currentTimeAnchorID));
set(handles.edit1,'string',num2str(morphingKnobs(mSubstrate.currentAttributeID,...
    mSubstrate.currentTimeAnchorID),'%6.3f'));

%-------------- finalize ----------
set(hObject,'userdata',mSubstrate);
return;

function escapeToUpperButtonDownFcn(src,evnt)
%disp('escape!');
mutliSliderAxis_callback(get(src,'parent'),evnt);
return;

function mSubstrate = ...
    writeMultiSlider(handles,mSubstrate,timeAnchors,startTime,endTime,morphingKnobs,attributeID)

knobTitles = {'Spec.','Freq.','AP.','F0','Time'};
knobNames = mSubstrate.knobNames;
plotHandles = mSubstrate.plotHandles;
nAnchors = length(mSubstrate.anchorOnMorphingTime);
mRateRange = [0 1]; % This part should be revised. HK 06 Dec. 08
%extendedIndex = [1 1:nAnchors nAnchors];
extendedIndex = [1:nAnchors+2];
extendedTimeAnchor = [startTime timeAnchors(:)' endTime];
lineSpec = '-s';
unitStr = 'units';
unitValue = 'normalized';
eval(['mSubstrate.' knobNames{attributeID} '.axis = ' ...
    'subplot(handles.' plotHandles{attributeID} ');']);
eval(['set(mSubstrate.' knobNames{attributeID} '.axis,unitStr,unitValue);']);
vLinesHandle = plot(timeAnchors(1)*[1 1],mRateRange,'k');
set(vLinesHandle,'ButtonDownFcn',@escapeToUpperButtonDownFcn);
drawmodeStr = 'drawmode';
drawmodeValue = 'fast';
eval(['set(mSubstrate.' knobNames{attributeID} '.axis,drawmodeStr,drawmodeValue);']);
%positionStr = 'position';
%eval(['get(mSubstrate.' knobNames{attributeID} '.axis,positionStr)']);
%plot(timeAnchors(1)*[1 1],mRateRange,'k');
axisUserData.handles = handles;
axisUserData.attributeID = attributeID;
userDataStr = 'userdata';
eval(['set(mSubstrate.' knobNames{attributeID} ...
    '.axis,userDataStr,axisUserData);']);
ButtonDownFcnString = 'ButtonDownFcn';
%plotHandles{attributeID}
eval(['set(mSubstrate.' knobNames{attributeID} ...
    '.axis,ButtonDownFcnString,@mutliSliderAxis_callback);']);
hold on;
for ii = 2:nAnchors
    vLinesHandle = plot(timeAnchors(ii)*[1 1],mRateRange,'k');
    set(vLinesHandle,'ButtonDownFcn',@escapeToUpperButtonDownFcn);
    %if ii ==1 hold on; end;
end;
%drawnow;
set(gca,'fontsize',12)
lineWidthStr = 'linewidth';
lineWidthValue = 2;
eval(['mSubstrate.' knobNames{attributeID} '.plot = ' ...
    'plot(extendedTimeAnchor,morphingKnobs(attributeID,extendedIndex)' ...
    ',lineSpec,lineWidthStr,lineWidthValue);']);
hold off
ButtonDownFcnString = 'ButtonDownFcn';
%set(imageHandle,'ButtonDownFcn',@windowButtonDownCallback);
eval(['set(mSubstrate.' knobNames{attributeID} ...
    '.plot,ButtonDownFcnString,@multiSliderButtonDownCallback);']);
userDataStr = 'userdata';
eval(['set(mSubstrate.' knobNames{attributeID} '.plot,userDataStr,handles);']);
axis([startTime endTime min(mRateRange) max(mRateRange)]);
%yticString = 'ytick';
%xticString = 'xtick';
%idPosition = startTime-(endTime-startTime)/40;
%namePosition = startTime-(endTime-startTime)/5.5;
%text(idPosition,min(mRateRange),'A');
%text(idPosition,max(mRateRange),'B');
%knobNameRoot = knobNames{attributeID};
%hText = text(namePosition,0.5,knobNameRoot(1:end-4));
%set(hText,'fontsize',14);
ylabel(knobTitles{attributeID},'fontsize',14);
ytickValue = [-1 -0.5 0 0.5 1 1.5 2];
ytickLabel = {'2A' '' 'A' '--' 'B' '' '2B'};
%eval(['set(mSubstrate.' knobNames{attributeID} '.axis,yticString,[]);']);
axisHandle = eval(['mSubstrate.' knobNames{attributeID} '.axis']);
set(axisHandle,'ytick',ytickValue,'ytickLabel',ytickLabel,'fontsize',14);
if attributeID ~= 5
    %eval(['set(mSubstrate.' knobNames{attributeID} '.axis,xticString,[]);']);
    set(axisHandle,'xtick',[]);
else
    xlabel('time (s) ','fontsize',18);
end;
return;

function generatePen(src,evnt)
axisUserData = get(src,'userdata');
handles = axisUserData.handles;
mSubstrate = get(handles.morphingGUIbase,'userdata');
currentPoint = get(src,'currentpoint');
axisUserData.xdata = zeros(1000,1);
axisUserData.ydata = zeros(1000,1);
axisUserData.xdata(1) = currentPoint(1,1);
axisUserData.ydata(1) = currentPoint(1,2);
axisUserData.linePoints = 1;
axisUserData.maxLinePoints = 1000;
if isfield(axisUserData,'line')
    if ishandle(axisUserData.line)
        delete(axisUserData.line);
    end;
end;
if isfield(mSubstrate,'groupHandle')
    if ishandle(mSubstrate.groupHandle)
        delete(mSubstrate.groupHandle);
    end;
end;
axisUserData.line = ...
    line('xdata',axisUserData.xdata(1:axisUserData.linePoints),...
    'ydata',axisUserData.ydata(1:axisUserData.linePoints),...
    'color','m','linewidth',2);
set(src,'userdata',axisUserData);
set(axisUserData.line,'ButtonDownFcn',@escapeToUpperButtonDownFcn);
set(handles.morphingGUIbase,'WindowButtonMotionFcn',@penMotionCallback);
set(handles.morphingGUIbase,'WindowButtonUpFcn',@penUpCallback);
%disp('generatePen!');
return;

function penMotionCallback (src,evnt)
mSubstrate = get(src,'userdata');
axisHandle =  eval(['mSubstrate.' ...
    mSubstrate.knobNames{mSubstrate.currentAttributeID} '.axis']);
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

function penUpCallback(src,evnt)
mSubstrate = get(src,'userdata');
handles = mSubstrate.currentHandles;
set(handles.morphingGUIbase,'WindowButtonMotionFcn',@defaultButtonMotionCallBack);
set(handles.morphingGUIbase,'WindowButtonUpFcn','');
axisHandle =  eval(['mSubstrate.' ...
    mSubstrate.knobNames{mSubstrate.currentAttributeID} '.axis']);
plotHandle =  eval(['mSubstrate.' ...
    mSubstrate.knobNames{mSubstrate.currentAttributeID} '.plot']);
axisUserData = get(axisHandle,'userdata');
%return;
%axisPosition = get(gca,'position');
penXdata = axisUserData.xdata(1:axisUserData.linePoints);
penYdata = axisUserData.ydata(1:axisUserData.linePoints);
[penXdataSorted,indexSorted] = sort(penXdata+rand(size(penXdata))*max(abs(penXdata))*0.0001);
penYdataSorted = penYdata(indexSorted);
%xlimit = get(axisHandle,'xlim'); xRange = xlimit(2)-xlimit(1);
%ylimit = get(axisHandle,'ylim'); yRange = ylimit(2)-ylimit(1);
xmin = penXdataSorted(1);
xmax = penXdataSorted(end);
xdata = get(plotHandle,'xdata');
ydata = get(plotHandle,'ydata');
nDataPoints = length(xdata);
activeIndexBase = 1:nDataPoints;
activeIndex = activeIndexBase((xdata<xmax)&(xdata>xmin));
if isempty(activeIndex)
    return;
end;
ydata(activeIndex) = interp1(penXdataSorted,...
    penYdataSorted,xdata(activeIndex),'linear','extrap');
groupHandle = line('xdata',xdata(activeIndex),...
    'ydata',ydata(activeIndex),'linestyle','-','linewidth',6,...
    'color','g','marker','s');
set(plotHandle,'ydata',ydata);
mSubstrate.groupHandle = groupHandle;
handles = mSubstrate.currentHandles;
groupUserData.activeIndex = activeIndex;
groupUserData.handles = handles;
groupUserData.anchorIndex = 1;
set(groupHandle,'ButtonDownFcn',@groupButtonDnFcn);
set(groupHandle,'userdata',groupUserData);
set(handles.morphingGUIbase,'WindowButtonUpFcn',@groupButtonUpFcn);
set(handles.timeSeriesButton,'value',1);
set(handles.timeInvariantButton,'value',0);
set(handles.PasteButton,'enable','on');
mSubstrate.currentMultiSlider = plotHandle;
if isfield(axisUserData,'line')
    if ishandle(axisUserData.line)
        delete(axisUserData.line);
    end;
end;
set(axisHandle,'userdata',axisUserData);
set(handles.morphingGUIbase,'userdata',mSubstrate);
return;

function mutliSliderAxis_callback(src,evnt)
%disp('multiSliderAxis!')
axisUserData = get(src,'userdata');
handles = axisUserData.handles;
mSubstrate = get(axisUserData.handles.morphingGUIbase,'userdata');
if strcmp(mSubstrate.currentKey,'alt') ...
        && (mSubstrate.currentAttributeID == axisUserData.attributeID)
    generatePen(src,evnt);
    return;
else
    mSubstrate = multiSliderAxesShaping(mSubstrate,axisUserData.attributeID);
end;
set(handles.morphingGUIbase,'userdata',mSubstrate);
defaultButtonMotionCallBack(handles.morphingGUIbase,evnt)


function timeButton_callback(src,evnt)
disp('here!')
handles = get(src,'userdata')
mSubstrate = get(handles.morphingGUIbase,'userdata');
mSubstrate = multiSliderAxesShaping(src,mSubstrate,5);
set(handles.morphingGUIbase,'userdata',mSubstrate);

%%%%--- finally, myrbbos seems not necessary. It was accidental mulfunction

function finalRectangle = myrbbox(mSubstrate)
%axisUserData = get(gca,'userdata');
%handles = axisUserData.handles;
handles = mSubstrate.currentHandles;
currentPoint = get(gca,'currentpoint');
hold on;
mSubstrate.rbboxHandle = plot(currentPoint(1,1)*[1 1 1 1 1],currentPoint(1,2)*[1 1 1 1 1],...
    'k--','linewidth',2);
hold off
%set(handles.morphingGUIbase,'userdata',mSubstrate);
set(handles.morphingGUIbase,'WindowButtonMotionFcn',@myrbbox_mouseMove_callback);
set(handles.morphingGUIbase,'WindowButtonUpFcn',@myrbbox_mouseUp_callback);
cycleCounter = 1;
mSubstrate.mouseMoving = 1;
drawnow
set(handles.morphingGUIbase,'userdata',mSubstrate);
pause(0.02);
while mSubstrate.mouseMoving == 1
    if ~ishghandle(handles.morphingGUIbase);break;end;
    tmpMSubstrate = get(handles.morphingGUIbase,'userdata');
    mSubstrate.mouseMoving = tmpMSubstrate.mouseMoving;
    cycleCounter = cycleCounter+1;
    pause(0.001);
    %if rem(cycleCounter,100) == 0;disp(cycleCounter);end;
end;
%currentPoint = get(gca,'currentpoint');
%disp('out from waiting')
xData = get(mSubstrate.rbboxHandle,'xdata');
yData = get(mSubstrate.rbboxHandle,'ydata');
finalRectangle = [min(xData) min(yData) abs(xData(2)-xData(1)) abs(yData(3)-yData(1))];
%set(handles.morphingGUIbase,'WindowButtonMotionFcn',@defaultButtonMotionCallBack);
set(handles.morphingGUIbase,'WindowButtonUpFcn','');
return;

function myrbbox_mouseMove_callback(src,event)
%disp('myrbbox_mouseMove_callback');
mSubstrate = get(src,'userdata');
handles = mSubstrate.currentHandles;
if ~ishghandle(handles.morphingGUIbase);return;end;
%axisUserData = get(gca,'userdata');
%handles = axisUserData.handles;
mSubstrate = get(handles.morphingGUIbase,'userdata');
currentPoint = get(gca,'currentpoint');
xData = get(mSubstrate.rbboxHandle,'xdata');
yData = get(mSubstrate.rbboxHandle,'ydata');
set(mSubstrate.rbboxHandle,'xdata',[xData(1) currentPoint(1,1) currentPoint(1,1) xData(4) xData(5)], ...
    'yData',[yData(1) yData(2) currentPoint(1,2) currentPoint(1,2) yData(5)]);
drawnow;
set(handles.morphingGUIbase,'userdata',mSubstrate);
return;

function myrbbox_mouseUp_callback(src,event)
mSubstrate = get(src,'userdata');
handles = mSubstrate.currentHandles;
if ~ishghandle(handles.morphingGUIbase);return;end;
%axisUserData = get(gca,'userdata');
%handles = axisUserData.handles;
mSubstrate = get(handles.morphingGUIbase,'userdata');
set(mSubstrate.rbboxHandle,'visible','off');
set(handles.morphingGUIbase,'WindowButtonUpFcn','');
set(handles.morphingGUIbase,'WindowButtonMotionFcn',@defaultButtonMotionCallBack);
mSubstrate.mouseMoving = 0;
set(handles.morphingGUIbase,'userdata',mSubstrate);
return;

%%%%--- finally, myrbbos seems not necessary. It was accidental mulfunction
%   This is the end of unnecessary part...

function mSubstrate = multiSliderAxesShaping(mSubstrate,targetID)

if mSubstrate.currentAttributeID == targetID
    %currentPoint = get(gca,'currentpoint');
    %figureCurrentPoint = get(mSubstrate.currentHandles.morphingGUIbase,'currentpoint')
    %get(gca)
    axisPosition = get(gca,'position');
    %%finalRectangle = myrbbox(mSubstrate); %rbbox;%([currentPoint(1,1:2) 0 0]);
    %disp('Yeah!');
    finalRectangle = rbbox;
    normalizedRectangle = ...
    [(finalRectangle(1:2)-axisPosition(1:2))./axisPosition(3:4) ...
        finalRectangle(3:4)./axisPosition(3:4)]; % This is for builtin
    %    rbbox
    xlimit = get(gca,'xlim');
    xRange = xlimit(2)-xlimit(1);
    ylimit = get(gca,'ylim');
    yRange = ylimit(2)-ylimit(1);
    %%normalizedRectangle = ...
    %    [(finalRectangle(1:2)-[xlimit(1) ylimit(1)])./[xRange yRange] ...
    %    finalRectangle(3:4)./[xRange yRange]];
    plotHandle = eval(['mSubstrate.' mSubstrate.knobNames{targetID} '.plot']);
    xmin = normalizedRectangle(1)*xRange+xlimit(1);
    xmax = (normalizedRectangle(1)+normalizedRectangle(3))*xRange+xlimit(1);
    ymin = normalizedRectangle(2)*yRange+ylimit(1);
    ymax = (normalizedRectangle(2)+normalizedRectangle(4))*yRange+ylimit(1);
    xdataStr = 'xdata';
    ydataStr = 'ydata';
    %xdata = eval(['get(mSubstrate.' mSubstrate.knobNames{targetID} '.plot,xdataStr);']);
    xdata = get(plotHandle,'xdata');
    %ydata = eval(['get(mSubstrate.' mSubstrate.knobNames{targetID} '.plot,ydataStr);']);
    ydata = get(plotHandle,'ydata');
    nDataPoints = length(xdata);
    activeIndexBase = 1:nDataPoints;
    activeIndex = activeIndexBase((xdata<xmax)&(xdata>xmin)&...
        (ydata<ymax)&(ydata>ymin));
    if isempty(activeIndex)
        return;
    end;
    groupHandle = line('xdata',xdata(activeIndex),...
        'ydata',ydata(activeIndex),'linestyle','-','linewidth',6,...
        'color','g','marker','s');
    mSubstrate.groupHandle = groupHandle;
    handles = mSubstrate.currentHandles;
    groupUserData.activeIndex = activeIndex;
    groupUserData.handles = handles;
    groupUserData.anchorIndex = 1;
    set(groupHandle,'ButtonDownFcn',@groupButtonDnFcn);
    set(groupHandle,'userdata',groupUserData);
    set(handles.morphingGUIbase,'WindowButtonUpFcn',@groupButtonUpFcn);
    set(handles.timeSeriesButton,'value',1);
    set(handles.timeInvariantButton,'value',0);
    set(handles.PasteButton,'enable','on');
    mSubstrate.currentMultiSlider = plotHandle;
    return;
end;
baseLineSkip = 0.0632;
skipExpand = 0.1758;
transitionRate = 0.7;
for transitionRate = 0:1/5:1
    %axisPosition = [0.1372    0.0755    0.6147    0.0490];
    %axisPosition = [0.0711    0.0755    0.6823    0.0490];
    axisPosition = [0.0598    0.0755    0.6990    0.0490];
    for ii = 5:-1:1
        if ii == targetID %mSubstrate.currentAttributeID
            eval(['currentPlot = mSubstrate.' mSubstrate.knobNames{ii} '.axis;']);
            set(currentPlot,...
                'position',[axisPosition(1:3) axisPosition(4)+skipExpand*transitionRate]);
            axisPosition(2) = axisPosition(2)+baseLineSkip+skipExpand*transitionRate;
        elseif ii == mSubstrate.currentAttributeID
            eval(['currentPlot = mSubstrate.' mSubstrate.knobNames{ii} '.axis;']);
            set(currentPlot,...
                'position',[axisPosition(1:3) axisPosition(4)+skipExpand*(1-transitionRate)]);
            axisPosition(2) = axisPosition(2)+baseLineSkip+skipExpand*(1-transitionRate);
        else
            eval(['currentPlot = mSubstrate.' mSubstrate.knobNames{ii} '.axis;']);
            set(currentPlot,'position',axisPosition);
            axisPosition(2) = axisPosition(2)+baseLineSkip;
        end;
        if transitionRate == 1
            knobHandle = eval(['mSubstrate.' mSubstrate.knobNames{ii} '.plot']);
            if ii == targetID
                set(knobHandle,'ButtonDownFcn',@multiSliderButtonDownCallback)
            else
                set(knobHandle,'ButtonDownFcn',@escapeToUpperButtonDownFcn)
            end;
        end;
    end;
    drawnow;
    %pause(0.05);
end;
mSubstrate.currentAttributeID = targetID;

function multiSliderButtonDownCallback(src,evnt)
%tic;
handles = get(src,'userdata');
mSubstrate = get(handles.morphingGUIbase,'userdata');
mSubstrate.currentAxis = get(src,'parent');
axisUserData = get(get(src,'parent'),'userdata');
if (mSubstrate.currentAttributeID == axisUserData.attributeID) ...
        && strcmp(mSubstrate.currentKey,'alt')
    mutliSliderAxis_callback(get(src,'parent'),evnt);
    return;
end;
currentPoint = get(mSubstrate.currentAxis,'currentpoint');
xdata = get(src,'xdata');
ydata = get(src,'ydata');
[dmy,currentTimeIndex] = min(abs(xdata-currentPoint(1,1)));
mSubstrate.currentTimeAnchorID = ...
    max(1,min(length(currentTimeIndex)-2,currentTimeIndex-1));
mSubstrate.xdataID = currentTimeIndex;
%xAxis = [xdata(currentTimeIndex) currentPoint(1,1)];
%yAxis = [ydata(currentTimeIndex) currentPoint(1,2)];
%mSubstrate.link = line('XData',xAxis,'YData',yAxis,...
%                'Marker','p','color','b','linewidth',1);drawnow;
mSubstrate.positionMarker = line('xdata',[1 1]*xdata(currentTimeIndex), ...
    'ydata',[0 1],'linewidth',4,'color','g');
mSubstrate.currentMultiSlider = src;
set(src,'linewidth',4,'color','g');
%set(handles.morphingGUIbase,'pointer','circle')
setPointerShape(3);
set(handles.morphingGUIbase,'WindowButtonUpFcn',@windowButtonUpCallback);
set(handles.morphingGUIbase,'WindowButtonMotionFcn',@windowButtonMoveCallback);
set(handles.morphingGUIbase,'userdata',mSubstrate);
%toc

function windowButtonMoveCallback(src,evnt)
mSubstrate = get(src,'userdata');
handles = mSubstrate.currentHandles;
knobNames = mSubstrate.knobNames;
%   explanation on currentpoint attribute of axis somewhat different.
%   This discrepancy may cause problem. Better to check.
%   I have checked. It's OK. See Figure properties section.
currentPoint = get(mSubstrate.currentAxis,'currentpoint');
xdata = get(mSubstrate.currentMultiSlider,'xdata');
ydata = get(mSubstrate.currentMultiSlider,'ydata');
%xAxis = get(mSubstrate.link,'xdata');
%yAxis = get(mSubstrate.link,'ydata');
%set(mSubstrate.link,'xdata',[xAxis(1) currentPoint(1,1)],...
%    'ydata',[ydata(mSubstrate.xdataID) currentPoint(1,2)]);%drawnow
switch get(handles.timeInvariantButton,'value')
    case 1
        ydata = ydata*0+max(0,min(1,currentPoint(1,2)));
    case 0
        ydata(mSubstrate.xdataID) = ...
            max(0,min(1,currentPoint(1,2)));
end;
set(mSubstrate.currentMultiSlider,'ydata',ydata);
ydataStr = 'ydata';
switch get(handles.bindButton,'value')
    case 1
        for ii = 1:5
            eval(['set(mSubstrate.' knobNames{ii} '.plot,ydataStr,ydata);']);
        end;
end;
set(handles.edit1,'string',num2str(currentPoint(1,2),'%8.4f'));
set(handles.slider1,'value',max(0,min(1,currentPoint(1,2))));
%mSubstrate = get(handles.morphingGUIbase,'userdata');

function windowButtonUpCallback(src,envt)
mSubstrate = get(src,'userdata');
handles = mSubstrate.currentHandles;
set(mSubstrate.currentMultiSlider,'linewidth',2,'color','b');
set(handles.morphingGUIbase,'pointer','arrow')
set(handles.morphingGUIbase,'WindowButtonUpFcn','');
set(handles.morphingGUIbase,'WindowButtonMotionFcn',@defaultButtonMotionCallBack);
set(handles.PasteButton,'enable','off');
set(handles.slider1,'enable','off');
set(handles.edit1,'enable','off');
set(handles.PasteButton,'value',0);
set(handles.MonitorButton,'value',1);
if ishandle(mSubstrate.positionMarker)
delete(mSubstrate.positionMarker);
end;
if isfield(mSubstrate,'groupHandle')
    if ishandle(mSubstrate.groupHandle)
    delete(mSubstrate.groupHandle);
    end;
    mSubstrate=rmfield(mSubstrate,'groupHandle');
    set(src,'userdata',mSubstrate);
end;

%set(groupHandle,'ButtonDownFcn',@groupButtonDnFcn);
%set(handles.morphingGUIbase,'WindowButtonUpFcn',@groupButtonUpFcn);
%set(handles.morphingGUIbase,'WindowButtonMotionFcn',@groupButtonMotionFcn);

function groupButtonDnFcn(src,evnt)
userData = get(src,'userdata');
%src
handles = userData.handles;
useData.active = 1;
currentPoint = get(gca,'currentpoint');
xdata = get(src,'xdata');
[dummy,anchorIndex] = min(abs(xdata-currentPoint(1,1)));
userData.anchorIndex = anchorIndex;
%set(handles.morphingGUIbase,'pointer','circle')
setPointerShape(3);
set(handles.morphingGUIbase,'WindowButtonMotionFcn',@groupButtonMotionFcn);
set(src,'userdata',userData);
return;

function groupButtonUpFcn(src,evnt)
mSubstrate = get(src,'userdata');
handles = mSubstrate.currentHandles;
set(handles.morphingGUIbase,'pointer','arrow');
set(handles.morphingGUIbase,'WindowButtonUpFcn','');
set(handles.morphingGUIbase,'WindowButtonMotionFcn',@defaultButtonMotionCallBack);
set(handles.PasteButton,'enable','off');
set(handles.slider1,'enable','off');
set(handles.edit1,'enable','off');
set(handles.PasteButton,'value',0);
set(handles.MonitorButton,'value',1);
if isfield(mSubstrate,'groupHandle')
    if ishandle(mSubstrate.groupHandle)
    delete(mSubstrate.groupHandle);
    end;
    mSubstrate=rmfield(mSubstrate,'groupHandle');
    set(src,'userdata',mSubstrate);
end;
return;

function groupButtonMotionFcn(src,evnt)
mSubstrate = get(src,'userdata');
knobHandle = mSubstrate.currentMultiSlider;
handles = mSubstrate.currentHandles;
groupHandle = mSubstrate.groupHandle;
userData = get(groupHandle,'userdata');
currentPoint = get(gca,'currentpoint');
ydata = get(groupHandle,'ydata');
delta = currentPoint(1,2)-ydata(userData.anchorIndex);
ydata = max(0,min(1,ydata+delta));
set(groupHandle,'ydata',ydata);
activeIndex = userData.activeIndex;
knobYdata = get(knobHandle,'ydata');
knobYdata(activeIndex) = ydata;
set(knobHandle,'ydata',knobYdata);
if get(mSubstrate.currentHandles.bindButton,'value')
    for ii = 1:5
        knobHandle = eval(['mSubstrate.' mSubstrate.knobNames{ii}  '.plot;']);
        set(knobHandle,'ydata',knobYdata);
    end;
end;
set(handles.edit1,'string',num2str(currentPoint(1,2),'%8.4f'));
set(handles.slider1,'value',max(0,min(1,currentPoint(1,2))));
return;

function speakerPanel_callback(src,evnt)
%disp('speaker panel!')
handles = get(src,'userdata');
mSubstrate = get(handles.morphingGUIbase,'userdata');
switch get(handles.SelectA,'value')
    case 1
        setupDisplay(handles.morphingGUIbase,handles,'A');
    case 0
        setupDisplay(handles.morphingGUIbase,handles,'B');
end;

function ViewerFunctionPanel_callback(src,evnt)
disp('viewer function changed.')
handles = get(src,'userdata');
mSubstrate = get(handles.morphingGUIbase,'userdata');
switch get(handles.MonitorButton,'value')
    case 0 % Paste mode
        set(handles.morphingGUIbase,'pointer','fleur')
        set(handles.edit1,'enable','on');
        set(handles.slider1,'enable','on');
    case 1 % Monitor mode
        set(handles.morphingGUIbase,'pointer','arrow')
        set(handles.edit1,'enable','off');
        set(handles.slider1,'enable','off');
end;
return

% --- Executes on button press in updateMorphingRateButton.
function updateMorphingRateButton_Callback(hObject, eventdata, handles)
% hObject    handle to updateMorphingRateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mRateFields = {'spectrum' 'frequency' 'aperiodicity' 'F0' 'time'};

mSubstrate = get(handles.morphingGUIbase,'userdata');
knobNames = mSubstrate.knobNames;
xdataStr = 'xdata';
ydataStr = 'ydata';
referenceTime = mSubstrate.morphingTimeAxis;
for ii = 1:5
    eval(['xdata = get(mSubstrate.' knobNames{ii} '.plot,xdataStr);']);
    eval(['ydata = get(mSubstrate.' knobNames{ii} '.plot,ydataStr);']);
    timeFunction = interp1(xdata,ydata,referenceTime);
    eval(['mRate.' mRateFields{ii} '=timeFunction;']);
    knobYdata{ii} = ydata;
end;
mSubstrate = morphingSubstrateNewAP(mSubstrate,'set','temporalMorphingRate',mRate);
mSubstrate.knobYdata = knobYdata;
if isfield(mSubstrate,'menuHandle') && ishandle(mSubstrate.menuHandle)
    userData = get(mSubstrate.menuHandle,'userdata');
    %userData.mSubstrate = mSubstrate;
    %userData.mSubstrate.knobYdata = knobYdata;
    userData.mSubstrate = ...
        updateBasedOnGUISetting(mSubstrate,userData.mSubstrate);
    set(mSubstrate.menuHandle,'userdata',userData);
    %MorphingMenu('selected','on');
    figure(mSubstrate.menuHandle);
else
    disp(['menuHandle in mSubstrate is not valid or missing' ])
end;

function updatedSubstrate = updateBasedOnGUISetting(GUISubstrate,MenuSubstrate)
updatedSubstrate = MenuSubstrate; % default is simple copy.
updatedSubstrate.knobYdata = GUISubstrate.knobYdata;
updatedSubstrate.temporalMorphingRate = GUISubstrate.temporalMorphingRate;
updatedSubstrate.morphingTimeAxis = GUISubstrate.morphingTimeAxis;
updatedSubstrate.lastUpdate = GUISubstrate.lastUpdate;
updatedSubstrate.currentKey = GUISubstrate.currentKey;
return


% --- Executes on button press in zoomInButton.
function zoomInButton_Callback(hObject, eventdata, handles)
% hObject    handle to zoomInButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mSubstrate = get(handles.morphingGUIbase,'userdata');
zoomInXaxis(mSubstrate,handles);
return;

function zoomInXaxis(mSubstrate,handles)
% --- zoom in spectrogram
xLimit = get(mSubstrate.spectrogramAxis,'xlim');
xCenter = (xLimit(1)+xLimit(2))/2;
xLength = xLimit(2)-xLimit(1);
newXLimit = [xCenter-xLength/2/sqrt(2)  xCenter+xLength/2/sqrt(2)];
set(mSubstrate.spectrogramAxis,'xlim',newXLimit);
for ii = 1:5
    currentHandle = eval(['handles.' mSubstrate.plotHandles{ii}]);
    set(currentHandle,'xlim',newXLimit);
end;
return;

% --- Executes on button press in zoomOutButton.
function zoomOutButton_Callback(hObject, eventdata, handles)
% hObject    handle to zoomOutButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mSubstrate = get(handles.morphingGUIbase,'userdata');
xLimit = get(mSubstrate.spectrogramAxis,'xlim');
xCenter = (xLimit(1)+xLimit(2))/2;
xLength = xLimit(2)-xLimit(1);
dataLength = ...
    mSubstrate.referenceTimeAxis(end)-mSubstrate.referenceTimeAxis(1);
newLength = min(dataLength,xLength*sqrt(2));
newXLimit = [max(mSubstrate.referenceTimeAxis(1),xCenter-newLength/2) ...
    min(mSubstrate.referenceTimeAxis(end),xCenter+newLength/2)];
set(mSubstrate.spectrogramAxis,'xlim',newXLimit);
for ii = 1:5
    currentHandle = eval(['handles.' mSubstrate.plotHandles{ii}]);
    set(currentHandle,'xlim',newXLimit);
end;
return;

% --- Executes on button press in fullZoomOutButton.
function fullZoomOutButton_Callback(hObject, eventdata, handles)
% hObject    handle to fullZoomOutButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mSubstrate = get(handles.morphingGUIbase,'userdata');
newXLimit = ...
    [mSubstrate.referenceTimeAxis(1) mSubstrate.referenceTimeAxis(end)];
set(mSubstrate.spectrogramAxis,'xlim',newXLimit);
for ii = 1:5
    currentHandle = eval(['handles.' mSubstrate.plotHandles{ii}]);
    set(currentHandle,'xlim',newXLimit);
end;

function spectrogramButtonDn_callback(src,evnt)
%disp('Sgram is clicked!')
handles = get(src,'userdata');
mSubstrate = get(handles.morphingGUIbase,'userdata');
set(handles.morphingGUIbase,'WindowButtonUpFcn',@sgramButtonUpCallback);
set(handles.morphingGUIbase,'WindowButtonMotionFcn',@sgramButtonMoveCallback);
%set(handles.morphingGUIbase,'pointer','crosshair');
setPointerShape(3);
currentPoint = get(gca,'currentpoint');
mSubstrate.timeHook = currentPoint(1,1);
set(handles.morphingGUIbase,'userdata',mSubstrate);
return;

function sgramButtonUpCallback(src,evnt)
mSubstrate = get(src,'userdata');
handles = mSubstrate.currentHandles;
set(handles.morphingGUIbase,'WindowButtonUpFcn','');
set(handles.morphingGUIbase,'WindowButtonMotionFcn',@defaultButtonMotionCallBack);
set(handles.morphingGUIbase,'pointer','arrow');
return;

function sgramButtonMoveCallback(src,evnt)
mSubstrate = get(src,'userdata');
handles = mSubstrate.currentHandles;
currentPoint = get(handles.Spectrogram,'currentpoint');
displacement = currentPoint(1,1)-mSubstrate.timeHook;
xLimit = get(mSubstrate.spectrogramAxis,'xlim');
newXLimit = xLimit-displacement;
if (newXLimit(1)>mSubstrate.referenceTimeAxis(1)) & ...
        (newXLimit(2)<mSubstrate.referenceTimeAxis(end))
    set(mSubstrate.spectrogramAxis,'xlim',newXLimit);
    for ii = 1:5
        currentHandle = eval(['handles.' mSubstrate.plotHandles{ii}]);
        set(currentHandle,'xlim',newXLimit);
    end;
end;
return;


% --- Executes on selection change in spectrogramColormap.
function spectrogramColormap_Callback(hObject, eventdata, handles)
% hObject    handle to spectrogramColormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%mSubstrate = get(handles.morphingGUIbase,'userdata');
colorMapID = get(hObject,'value');
switch colorMapID
    case 1
        set(handles.morphingGUIbase,'colormap',1-gray);
    case 2
        set(handles.morphingGUIbase,'colormap',jet);
end;
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

function defaultButtonMotionCallBack(src,evnt)
mSubstrate = get(src,'userdata');
handles = mSubstrate.currentHandles;
axisHandle = eval(['mSubstrate.' mSubstrate.knobNames{mSubstrate.currentAttributeID} '.axis']);
currentPoint = get(axisHandle,'currentpoint');
yLim = get(axisHandle,'yLim');
xLim = get(axisHandle,'xLim');
tightInset = get(axisHandle,'TightInset');
if (currentPoint(1,2)>yLim(1)) & (currentPoint(1,2)<yLim(2))
    if  (currentPoint(1,1)<xLim(1)) & (currentPoint(1,1)>xLim(1)-tightInset(1))
        switch mSubstrate.currentKey
            case 'none'
                %setPointerShape(1);
                setPointerShape(999);
            case 'shift'
                %setPointerShape(2);
                setPointerShape(999);
            case 'control'
                %setPointerShape(3);
                setPointerShape(999);
            case 'alt'
                setPointerShape(999);
        end;
    elseif (currentPoint(1,1)>xLim(1)) & (currentPoint(1,1)<xLim(2))
        %toolId = get(handles.PenButton1,'value');
        minimumProximity = checkObjectProximity(src,...
            handles,axisHandle,currentPoint);
        if (minimumProximity < 22) & ~strcmp(mSubstrate.currentKey,'alt')
            setPointerShape(4)
            return;
        end;
        if strcmp(mSubstrate.currentKey,'alt')
            setPointerShape(6);
        else
            setPointerShape(5);
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
%minimumProximity = 50; % dummy
mSubstrate = get(src,'userdata');
knobHandle = eval(['mSubstrate.' ...
    mSubstrate.knobNames{mSubstrate.currentAttributeID} '.plot']);
x = currentPoint(1,1);
y = currentPoint(1,2);
xData = get(knobHandle,'xdata');
yData = get(knobHandle,'ydata');
if isfield(mSubstrate,'groupHandle')
    if ishandle(mSubstrate.groupHandle)
        xdataAnchor = get(mSubstrate.groupHandle,'xdata');
        ydataAnchor = get(mSubstrate.groupHandle,'ydata');
    end;
end;
xLim = get(axisHandle,'xLim');
yLim = get(axisHandle,'yLim');
yScale = get(axisHandle,'yScale');
axisUnits = get(axisHandle,'Units');
set(axisHandle,'Units','pixels');
axisPosition = get(axisHandle,'position');
set(axisHandle,'Units',axisUnits);
xDistanceInPix = (xData-x)/(xLim(2)-xLim(1))*axisPosition(3);
yDistanceInPix = (yData-y)/(yLim(2)-yLim(1))*axisPosition(4);
distanceSqure = min(xDistanceInPix.^2+yDistanceInPix.^2);
if length(xData) > 1
    xp = x/(xLim(2)-xLim(1))*axisPosition(3);
    yp = y/(yLim(2)-yLim(1))*axisPosition(4);
    x1 = max(xData(xData<=x)/(xLim(2)-xLim(1))*axisPosition(3));
    x2 = min(xData(xData>x)/(xLim(2)-xLim(1))*axisPosition(3));
    index1 = max(find(xData<=x));
    y1 = yData(index1)/(yLim(2)-yLim(1))*axisPosition(4);
    y2 = yData(index1+1)/(yLim(2)-yLim(1))*axisPosition(4);
    distanceSqure2 = proximityToSegment(x1,x2,y1,y2,xp,yp)^2;
    distanceSqure = min(distanceSqure,distanceSqure2);
end;
if isfield(mSubstrate,'groupHandle')
    if ishandle(mSubstrate.groupHandle)
        xData = xdataAnchor;
        yData = ydataAnchor;
        xDistanceInPix = (xData-x)/(xLim(2)-xLim(1))*axisPosition(3);
        yDistanceInPix = (yData-y)/(yLim(2)-yLim(1))*axisPosition(4);
        distanceSqure3 = min(xDistanceInPix.^2+yDistanceInPix.^2);
        if (x>=min(xData)) && (x<max(xData))
            if length(xData) > 1
                xp = x/(xLim(2)-xLim(1))*axisPosition(3);
                yp = y/(yLim(2)-yLim(1))*axisPosition(4);
                x1 = max(xData(xData<=x)/(xLim(2)-xLim(1))*axisPosition(3));
                x2 = min(xData(xData>x)/(xLim(2)-xLim(1))*axisPosition(3));
                index1 = max(find(xData<=x));
                y1 = yData(index1)/(yLim(2)-yLim(1))*axisPosition(4);
                y2 = yData(index1+1)/(yLim(2)-yLim(1))*axisPosition(4);
                distanceSqure4 = proximityToSegment(x1,x2,y1,y2,xp,yp)^2;
                distanceSqure3 = min(distanceSqure3,distanceSqure4);
            end;
        end;
        distanceSqure = min(distanceSqure,distanceSqure3);
    end;
end;
return;

function keyPressCallBack(src,evnt)
mSubstrate = get(src,'userdata');
%evnt.Key
mSubstrate.currentKey = evnt.Key;
set(src,'userdata',mSubstrate);
defaultButtonMotionCallBack(src,evnt);
return;

function keyReleaseCallBack(src,evnt)
mSubstrate = get(src,'userdata');
mSubstrate.currentKey = 'none';
set(src,'userdata',mSubstrate);
defaultButtonMotionCallBack(src,evnt);
return;

