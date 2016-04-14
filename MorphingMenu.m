function varargout = MorphingMenu(varargin)
% MORPHINGMENU M-file for MorphingMenu.fig
%   Type
%   >> menuHandle = MorphingMenu;
%   to start morphing speech samples. (>>) represetnts the system prompt.
%   You can inspect the morphing substrate currently handled by:
%   >> userData = get(menuHandle,'userdata');
%   >> userData.mSubstrate
%   Please note that the last line does not terminated with ";"
%   This lists contents of the morphing substrate currently handled.
%
%   Then, do what you like.
%
% ========================================================================
%   The following text is a generic help text generated automatically.
%
%      MORPHINGMENU, by itself, creates a new MORPHINGMENU or raises the existing
%      singleton*.
%
%      H = MORPHINGMENU returns the handle to a new MORPHINGMENU or the handle to
%      the existing singleton*.
%
%      MORPHINGMENU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MORPHINGMENU.M with the given input arguments.
%
%      MORPHINGMENU('Property','Value',...) creates a new MORPHINGMENU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MorphingMenu_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MorphingMenu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MorphingMenu
%   Designed and coded with assistance of GUIDE by Hideki Kawahara
%   08/Nov./2008
%   06/Oct./2015 R2015b compatibility fix

% Last Modified by GUIDE v2.5 05-Feb-2011 03:40:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @MorphingMenu_OpeningFcn, ...
    'gui_OutputFcn',  @MorphingMenu_OutputFcn, ...
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


% --- Executes just before MorphingMenu is made visible.
function MorphingMenu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MorphingMenu (see VARARGIN)

% Choose default command line output for MorphingMenu
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
userData = get(handles.MorphingMenuBody,'userdata');
if isempty(userData)
    mSubstrate = morphingSubstrateNewAP;
    menuUserData.mSubstrate = mSubstrate;
    menuUserData.currentHandles = handles;
    set(handles.MorphingMenuBody,'userdata',menuUserData);
end;
set(handles.MorphingMenuBody,'WindowButtonMotionFcn',@defaultWindowMotionCallback);
%locateTopLeftOfGUI(Top,Left,GUIHandle)
TandemSTRAIGHThandler('locateTopLeftOfGUI',45,300,handles.MorphingMenuBody);
syncGUIStatus(handles);

% UIWAIT makes MorphingMenu wait for user response (see UIRESUME)
% uiwait(handles.MorphingMenuBody);


% --- Outputs from this function are returned to the command line.
function varargout = MorphingMenu_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function defaultWindowMotionCallback(src,evnt)
menuUserData = get(src,'userdata');
handles = menuUserData.currentHandles;
set(src,'pointer','arrow');
return;

% --- Executes on button press in LoadWaveformA.
function LoadWaveformA_Callback(hObject, eventdata, handles)
% hObject    handle to LoadWaveformA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uigetfile('*.wav','Select sound file for A.');
if length(file) == 1 && length(path) == 1
    if file == 0 || path == 0
        disp('Load is cancelled!');
        return;
    end;
end;
%[x,fs] = wavread([path file]);
[x,fs] = audioread([path file]);
menuUserData = get(handles.MorphingMenuBody,'userdata');
mSubstrate = menuUserData.mSubstrate;
mSubstrate = morphingSubstrateNewAP(mSubstrate,'set',...
    'samplintFrequency',fs);
mSubstrate = morphingSubstrateNewAP(mSubstrate,'set',...
    'dataDirectoryForSpeakerA',path);
mSubstrate = morphingSubstrateNewAP(mSubstrate,'set',...
    'fileNameForSpeakerA',file);
if ~isfield(mSubstrate,'waveformForSpeakerA')
    mSubstrate.waveformForSpeakerA = [];
end;
mSubstrate = morphingSubstrateNewAP(mSubstrate,'set',...
    'waveformForSpeakerA',x(:,1));
menuUserData.mSubstrate = mSubstrate;
set(handles.MorphingMenuBody,'userdata',menuUserData);
syncGUIStatus(handles);

% --- Executes on button press in LoadWaveformB.
function LoadWaveformB_Callback(hObject, eventdata, handles)
% hObject    handle to LoadWaveformB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uigetfile('*.wav','Select sound file for B.');
if length(file) == 1 && length(path) == 1
    if file == 0 || path == 0
        disp('Load is cancelled!');
        return;
    end;
end;
%[x,fs] = wavread([path file]);
[x,fs] = audioread([path file]);
menuUserData = get(handles.MorphingMenuBody,'userdata');
mSubstrate = menuUserData.mSubstrate;
mSubstrate = morphingSubstrateNewAP(mSubstrate,'set',...
    'samplintFrequency',fs);
mSubstrate = morphingSubstrateNewAP(mSubstrate,'set',...
    'dataDirectoryForSpeakerB',path);
mSubstrate = morphingSubstrateNewAP(mSubstrate,'set',...
    'fileNameForSpeakerB',file);
if ~isfield(mSubstrate,'waveformForSpeakerB')
    mSubstrate.waveformForSpeakerB = [];
end;
mSubstrate = morphingSubstrateNewAP(mSubstrate,'set',...
    'waveformForSpeakerB',x(:,1));
menuUserData.mSubstrate = mSubstrate;
set(handles.MorphingMenuBody,'userdata',menuUserData);
syncGUIStatus(handles);


% --- Executes on button press in AnalyzeB.
function AnalyzeB_Callback(hObject, eventdata, handles)
% hObject    handle to AnalyzeB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuUserData = get(handles.MorphingMenuBody,'userdata');
mSubstrate = menuUserData.mSubstrate;
mSubstrate.creator = get(handles.MorphingMenuBody,'tag');
x = mSubstrate.waveformForSpeakerB;
fs = mSubstrate.samplintFrequency;
if isfield(mSubstrate,'dataDirectoryForSpeakerB')& ...
        isfield(mSubstrate,'fileNameForSpeakerB')
    if ~isempty(mSubstrate.dataDirectoryForSpeakerB)& ...
            ~isempty(mSubstrate.fileNameForSpeakerB)
        STRAIGHTobject.dataDirectory = mSubstrate.dataDirectoryForSpeakerB;
        STRAIGHTobject.dataFileName = mSubstrate.fileNameForSpeakerB;
    end;
end;
STRAIGHTobject.samplingFrequency = fs;
STRAIGHTobject.waveform = x;
STRAIGHTobject.morphingMenu = handles.output;
STRAIGHTobject.speakerID = 'B';
STRAIGHTHandler = TandemSTRAIGHThandler('userdata',STRAIGHTobject);
syncGUIStatus(handles);
return;

if 1 == 2
set(gcf,'Pointer','watch');
drawnow;
r = exF0candidatesTSTRAIGHTGB(x,fs);
f = exSpectrumTSTRAIGHTGB(x,fs,r);
q = aperiodicityRatio(x,r,2);
mSubstrate.f0OfSpeakerB = r.f0;
mSubstrate.f0TimeBaseOfSpeakerB = r.temporalPositions;
mSubstrate.STRAIGHTspectrogramOfSpeakerB = f.spectrogramSTRAIGHT;
mSubstrate.spectrogramTimeBaseOfSpeakerB = f.temporalPositions;
mSubstrate.aperiodicityOfSpeakerB = q;
mSubstrate.aperiodicityTimeBaseOfSpeakerB = q.temporalPositions;
set(gcf,'Pointer','arrow');drawnow;
mSubstrate.creationDate = datestr(now,30);
menuUserData.mSubstrate = mSubstrate;
set(handles.MorphingMenuBody,'userdata',menuUserData);
syncGUIStatus(handles);
end;


% --- Executes on button press in AnalyzeA.
function AnalyzeA_Callback(hObject, eventdata, handles)
% hObject    handle to AnalyzeA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuUserData = get(handles.MorphingMenuBody,'userdata');
mSubstrate = menuUserData.mSubstrate;
mSubstrate.creator = get(handles.MorphingMenuBody,'tag');
x = mSubstrate.waveformForSpeakerA;
fs = mSubstrate.samplintFrequency;
if isfield(mSubstrate,'dataDirectoryForSpeakerA')& ...
        isfield(mSubstrate,'fileNameForSpeakerA')
    if ~isempty(mSubstrate.dataDirectoryForSpeakerA)& ...
            ~isempty(mSubstrate.fileNameForSpeakerA)
        STRAIGHTobject.dataDirectory = mSubstrate.dataDirectoryForSpeakerA;
        STRAIGHTobject.dataFileName = mSubstrate.fileNameForSpeakerA;
    end;
end;
STRAIGHTobject.samplingFrequency = fs;
STRAIGHTobject.waveform = x;
STRAIGHTobject.morphingMenu = handles.output;
STRAIGHTobject.speakerID = 'A';
STRAIGHTHandler = TandemSTRAIGHThandler('userdata',STRAIGHTobject);
syncGUIStatus(handles);
return;

if 1 ==2 
set(gcf,'Pointer','watch');
drawnow;
r = exF0candidatesTSTRAIGHTGB(x,fs);
f = exSpectrumTSTRAIGHTGB(x,fs,r);
q = aperiodicityRatio(x,r,2);
mSubstrate.f0OfSpeakerA = r.f0;
mSubstrate.f0TimeBaseOfSpeakerA = r.temporalPositions;
mSubstrate.STRAIGHTspectrogramOfSpeakerA = f.spectrogramSTRAIGHT;
mSubstrate.spectrogramTimeBaseOfSpeakerA = f.temporalPositions;
mSubstrate.aperiodicityOfSpeakerA = q;
mSubstrate.aperiodicityTimeBaseOfSpeakerA = q.temporalPositions;
set(gcf,'Pointer','arrow');drawnow;
mSubstrate.creationDate = datestr(now,30);
menuUserData.mSubstrate = mSubstrate;
set(handles.MorphingMenuBody,'userdata',menuUserData);
syncGUIStatus(handles);
end;


% --- Executes on button press in LoadLabelB.
function LoadLabelB_Callback(hObject, eventdata, handles)
% hObject    handle to LoadLabelB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uigetfile({'*.txt';'*.lbh';'*.*'},'Select label file for B.');
if length(file) == 1 && length(path) == 1
    if file == 0 || path == 0
        disp('Load is cancelled!');
        return;
    end;
end;
if ~isempty(strfind(file,'.txt'))
    labelB = readAudacityLabel([path file]);
elseif ~isempty(strfind(file,'.lbh'))
    labelB = readMEILabel([path file]);
else
    disp(['File: ' file ' is unknown format.']);
    return;
end;
menuUserData = get(handles.MorphingMenuBody,'userdata');
mSubstrate = menuUserData.mSubstrate;
mSubstrate = morphingSubstrateNewAP(mSubstrate,'set',...
    'temporaAnchorOfSpeakerB',labelB.segment(:,1));
frequencyAnchors = setBlankFrequencyAnchors(labelB);
mSubstrate.frequencyAnchorOfSpeakerB = frequencyAnchors;
menuUserData.mSubstrate = mSubstrate;
set(handles.MorphingMenuBody,'userdata',menuUserData);
syncGUIStatus(handles);


% --- Executes on button press in LoadLabelA.
function LoadLabelA_Callback(hObject, eventdata, handles)
% hObject    handle to LoadLabelA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uigetfile({'*.txt';'*.lbh';'*.*'},'Select label file for A.');
if length(file) == 1 && length(path) == 1
    if file == 0 || path == 0
        disp('Load is cancelled!');
        return;
    end;
end;
if ~isempty(strfind(file,'.txt'))
    labelA = readAudacityLabel([path file]);
elseif ~isempty(strfind(file,'.lbh'))
    labelA = readMEILabel([path file]);
else
    disp(['File: ' file ' is unknown format.']);
    return;
end;
menuUserData = get(handles.MorphingMenuBody,'userdata');
mSubstrate = menuUserData.mSubstrate;
mSubstrate = morphingSubstrateNewAP(mSubstrate,'set',...
    'temporaAnchorOfSpeakerA',labelA.segment(:,1));
frequencyAnchors = setBlankFrequencyAnchors(labelA);
mSubstrate.frequencyAnchorOfSpeakerA = frequencyAnchors;
menuUserData.mSubstrate = mSubstrate;
set(handles.MorphingMenuBody,'userdata',menuUserData);
syncGUIStatus(handles);

% --- Executes on button press in OpenAnchoringInterface.
function OpenAnchoringInterface_Callback(hObject, eventdata, handles)
% hObject    handle to OpenAnchoringInterface (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuUserData = get(handles.MorphingMenuBody,'userdata');
mSubstrate = menuUserData.mSubstrate;
mSubstrate.menuHandle = handles.MorphingMenuBody;
%menuUserData.interfaceGHIhandle = templateGUIforTSmorping(mSubstrate);
%if isfield(menuUserData,'morphingRateGUIhandle')
%    if ishandle(menuUserData.morphingRateGUIhandle)
%        close(menuUserData.morphingRateGUIhandle);
%    end;
%end;
if ~isfield(mSubstrate,'interfaceGHIhandle')
    mSubstrate.interfaceGHIhandle = temporalAnchorGUI('userdata',mSubstrate);
elseif ishandle(mSubstrate.interfaceGHIhandle)
    figure(mSubstrate.interfaceGHIhandle);
else
    mSubstrate.interfaceGHIhandle = temporalAnchorGUI('userdata',mSubstrate);
end;
menuUserData.mSubstrate = mSubstrate;
set(handles.MorphingMenuBody,'userdata',menuUserData);
syncGUIStatus(handles);


% --- Executes on button press in SynthesizeMorphedSpeech.
function SynthesizeMorphedSpeech_Callback(hObject, eventdata, handles)
% hObject    handle to SynthesizeMorphedSpeech (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuUserData = get(handles.MorphingMenuBody,'userdata');
mSubstrate = menuUserData.mSubstrate;
set(gcf,'Pointer','watch');drawnow;
morphedSignal = generateMorphedSpeechNewAP(mSubstrate);
set(gcf,'Pointer','arrow');drawnow;
sound(morphedSignal.outputBuffer/max(abs(morphedSignal.outputBuffer))*0.99,...
    mSubstrate.samplintFrequency);
menuUserData.synthesizedSound = morphedSignal.outputBuffer;
set(handles.MorphingMenuBody,'userdata',menuUserData);
syncGUIStatus(handles);

% --- Executes on button press in SaveMorphedSpeech.
function SaveMorphedSpeech_Callback(hObject, eventdata, handles)
% hObject    handle to SaveMorphedSpeech (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuUserData = get(handles.MorphingMenuBody,'userdata');
mSubstrate = menuUserData.mSubstrate;
if ~isfield(menuUserData,'synthesizedSound')
    disp(['Please synthesize at first']);
    return;
end;
outFileName = ['mrphSpch' datestr(now,30) '.wav'];
[file,path] = uiputfile(outFileName,'Save the morphed speech');
if length(file) == 1 && length(path) == 1
    if file == 0 || path == 0
        okInd = 0;
        disp('Save is cancelled!');
        return;
    end;
end;
outSignal = menuUserData.synthesizedSound;
attenuation = 0.85/max(abs(outSignal));
outSignal = outSignal*attenuation;
%wavwrite(outSignal,mSubstrate.samplintFrequency,16,[path file]);
sudiowrite([path file],outSignal,mSubstrate.samplintFrequency); % 06/Oct./2015 HK
metaInfoFileName = file(1:end-4);
metaData = mSubstrate;
metaData.metaDataCreator = 'MorphingMenu';
metaData.attenuation = attenuation;
metaData = rmfield(metaData,'STRAIGHTspectrogramOfSpeakerA');
metaData = rmfield(metaData,'STRAIGHTspectrogramOfSpeakerB');
metaData = rmfield(metaData,'aperiodicityOfSpeakerA');
metaData = rmfield(metaData,'aperiodicityOfSpeakerB');
if isfield(metaData,'morphedDisplayspectrum')
    metaData = rmfield(metaData,'morphedDisplayspectrum');
end;
if isfield(metaData,'waveformForSpeakerA')
    metaData = rmfield(metaData,'waveformForSpeakerA');
end;
if isfield(metaData,'waveformForSpeakerB')
    metaData = rmfield(metaData,'waveformForSpeakerB');
end;
%pathReg = regexprep(path,'\s','\\ ');
%eval(['save ' pathReg metaInfoFileName ' metaData']);
save([path metaInfoFileName],'metaData');
%syncGUIStatus(handles);

% --- Executes on button press in SaveMorphingSubstrate.
function SaveMorphingSubstrate_Callback(hObject, eventdata, handles)
% hObject    handle to SaveMorphingSubstrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuUserData = get(handles.MorphingMenuBody,'userdata');
revisedData = menuUserData.mSubstrate;
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
%pathReg = regexprep(path,'\s','\\ ');
%eval(['save ' pathReg file ' revisedData']);
save([path file],'revisedData');
syncGUIStatus(handles);

% --- Executes on button press in LoadMorphingSubstrate.
function LoadMorphingSubstrate_Callback(hObject, eventdata, handles)
% hObject    handle to LoadMorphingSubstrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uigetfile('*.mat','Select morphing substrate to load');
if length(file) == 1 && length(path) == 1
    if file == 0 || path == 0
        disp('Load is cancelled!');
        return;
    end;
end;
%pathReg = regexprep(path,'\s','\\ ');
%eval(['load ' pathReg file]);
load([path file]);
if exist('revisedData') ~= 1
    disp(['The file ' file ' is not a morphing substrate']);
    return;
else
    menuUserData = get(handles.MorphingMenuBody,'userdata');
    revisedData.originalSubstratePath = path;
    revisedData.originalSubstrateFile = file;
    menuUserData.mSubstrate = revisedData;
    set(handles.MorphingMenuBody,'userdata',menuUserData);
end;
syncGUIStatus(handles);

% --- Executes on button press in Replay.
function Replay_Callback(hObject, eventdata, handles)
% hObject    handle to Replay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuUserData = get(handles.MorphingMenuBody,'userdata');
mSubstrate = menuUserData.mSubstrate;
if ~isfield(menuUserData,'synthesizedSound')
    disp(['Please synthesize at first']);
else
    sound(menuUserData.synthesizedSound/max(abs(menuUserData.synthesizedSound))*0.99,...
        mSubstrate.samplintFrequency);
end;
syncGUIStatus(handles);

% --- Executes on button press in PlayB.
function PlayB_Callback(hObject, eventdata, handles)
% hObject    handle to PlayB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuUserData = get(handles.MorphingMenuBody,'userdata');
mSubstrate = menuUserData.mSubstrate;
if ~isfield(mSubstrate,'waveformForSpeakerB')
    disp(['Please fetch speech file for B']);
    mSubstrate.waveformForSpeakerB = [];
    menuUserData.mSubstrate = mSubstrate;
    set(handles.MorphingMenuBody,'userdata',menuUserData);
elseif length(mSubstrate.waveformForSpeakerB) > 100
    sound(mSubstrate.waveformForSpeakerB/max(abs(mSubstrate.waveformForSpeakerB))*0.99,...
        mSubstrate.samplintFrequency);
else
    disp(['Please fetch speech file for B']);
end;
syncGUIStatus(handles);

% --- Executes on button press in PlayA.
function PlayA_Callback(hObject, eventdata, handles)
% hObject    handle to PlayA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuUserData = get(handles.MorphingMenuBody,'userdata');
mSubstrate = menuUserData.mSubstrate;
if ~isfield(mSubstrate,'waveformForSpeakerA')
    disp(['Please fetch speech file for A']);
    mSubstrate.waveformForSpeakerA = [];
    menuUserData.mSubstrate = mSubstrate;
    set(handles.MorphingMenuBody,'userdata',menuUserData);
elseif length(mSubstrate.waveformForSpeakerA) > 100
    sound(mSubstrate.waveformForSpeakerA/max(abs(mSubstrate.waveformForSpeakerA))*0.99,...
        mSubstrate.samplintFrequency);
else
    disp(['Please fetch speech file for A']);
end;
syncGUIStatus(handles);

% ---- synchronize status of interface
function syncGUIStatus(handles)

menuUserData = get(handles.MorphingMenuBody,'userdata');
mSubstrate = menuUserData.mSubstrate;
% check for fields and make it active
if ~isfield(mSubstrate,'waveformForSpeakerA')
    mSubstrate.waveformForSpeakerA = [];
    set(handles.PlayA,'enable','off');
    set(handles.AnalyzeA,'enable','off');
    set(handles.LoadLabelA,'enable','off');
elseif length(mSubstrate.waveformForSpeakerA) < 10
    set(handles.PlayA,'enable','off');
    set(handles.AnalyzeA,'enable','off');
    set(handles.LoadLabelA,'enable','off');
else
    set(handles.PlayA,'enable','on');
    set(handles.AnalyzeA,'enable','on');
    set(handles.LoadLabelA,'enable','on');
end;
if ~isfield(mSubstrate,'waveformForSpeakerB')
    mSubstrate.waveformForSpeakerA = [];
    set(handles.PlayB,'enable','off');
    set(handles.AnalyzeB,'enable','off');
    set(handles.LoadLabelB,'enable','off');
elseif length(mSubstrate.waveformForSpeakerB) < 10
    set(handles.PlayB,'enable','off');
    set(handles.AnalyzeB,'enable','off');
    set(handles.LoadLabelB,'enable','off');
else
    set(handles.PlayB,'enable','on');
    set(handles.AnalyzeB,'enable','on');
    set(handles.LoadLabelB,'enable','on');
end;
if length(mSubstrate.STRAIGHTspectrogramOfSpeakerA)* ...
        length(mSubstrate.STRAIGHTspectrogramOfSpeakerB) == 0
    set(handles.SaveMorphingSubstrate,'enable','off');
    set(handles.OpenAnchoringInterface,'enable','off');
    set(handles.SynthesizeMorphedSpeech,'enable','off');
    set(handles.EditMorphingRate,'enable','off');
    set(handles.InitializeMorphingTimeAxis,'enable','off');
    set(handles.EditMorphingRate,'enable','off');
else
    if length(mSubstrate.temporaAnchorOfSpeakerA)* ...
            length(mSubstrate.temporaAnchorOfSpeakerB) ~= 0
        set(handles.InitializeMorphingTimeAxis,'enable','on');
        set(handles.EditMorphingRate,'enable','on');
    end;
    if isfield(mSubstrate,'temporalMorphingRate') && ...
            (isempty(mSubstrate.temporalMorphingRate) ||...
            length(mSubstrate.temporalMorphingRate)<1)
        InitializeMorphingTimeAxis_Callback(...
            handles.InitializeMorphingTimeAxis, 1, handles);
    elseif ~isfield(mSubstrate,'temporalMorphingRate')
        InitializeMorphingTimeAxis_Callback(...
            handles.InitializeMorphingTimeAxis, 1, handles);
    end;
    set(handles.SaveMorphingSubstrate,'enable','on');
    set(handles.OpenAnchoringInterface,'enable','on');
    if isfield(mSubstrate,'morphingTimeAxis')
        if (length(mSubstrate.morphingTimeAxis)* ...
                length(mSubstrate.temporalMorphingRate) ~= 0) && ...
                isfield(mSubstrate,'anchorOnMorphingTime') && ...
                isfield(mSubstrate,'morphingTimeAxis')
            set(handles.SynthesizeMorphedSpeech,'enable','on');
            set(handles.OpenAnchoringInterface,'enable','on');
        end;
    end;
end;
if length(mSubstrate.temporalMorphingRate) == 0
    set(handles.SynthesizeMorphedSpeech,'enable','off');
end;
if ~isfield(menuUserData,'synthesizedSound')
    set(handles.Replay,'enable','off');
    set(handles.SaveMorphedSpeech,'enable','off');
else
    set(handles.Replay,'enable','on');
    set(handles.SaveMorphedSpeech,'enable','on');
end;
if isfield(mSubstrate,'temporaAnchorOfSpeakerA') && ...
        isfield(mSubstrate,'temporaAnchorOfSpeakerB')
if length(mSubstrate.temporaAnchorOfSpeakerA)* ...
            length(mSubstrate.temporaAnchorOfSpeakerB) ~= 0 && ...
        ~isfield(mSubstrate,'anchorOnMorphingTime')
        InitializeMorphingTimeAxis_Callback(...
            handles.InitializeMorphingTimeAxis, 1, handles);
end;
end; % anchorOnMorphingTime
mSubstrate.lastUpdate = datestr(now);
mSubstrate.currentHandleToMenu = handles.MorphingMenuBody;
menuUserData.mSubstrate = mSubstrate;
set(handles.MorphingMenuBody,'userdata',menuUserData);

function frequencyAnchors = setBlankFrequencyAnchors(label)

upperLimitOfFrequencyAnchors = 6;
frequencyAnchors.counts = zeros(size(label.segment,1),1);
frequencyAnchors.frequency = ...
    zeros(size(label.segment,1),upperLimitOfFrequencyAnchors);
for ii = 1:size(label.segment,1)
    for jj = 1:upperLimitOfFrequencyAnchors
        markA = -500+jj*1000-50;
        frequencyAnchors.frequency(ii,jj) = markA;
    end;
end;


% --- Executes on button press in InitializeMorphingTimeAxis.
function InitializeMorphingTimeAxis_Callback(hObject, eventdata, handles)
% hObject    handle to InitializeMorphingTimeAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuUserData = get(handles.MorphingMenuBody,'userdata');
mSubstrate = menuUserData.mSubstrate;
mRateCommon = 0; % 0: speaker A, 1: speaker B
mSubstrate = morphingSubstrateNewAP(mSubstrate,'generate','morphingTimeAxis',mRateCommon);
%---- set default temporal morphing rate
fs = mSubstrate.samplintFrequency;
mRate.time = 0.5+0*(mSubstrate.morphingTimeAxis(:))/mSubstrate.morphingTimeAxis(end);
mRate.F0 = mRate.time;
mRate.frequency = mRate.time;
mRate.spectrum = mRate.time;
mRate.aperiodicity = mRate.time;
mSubstrate = morphingSubstrateNewAP(mSubstrate,'set','temporalMorphingRate',mRate);
menuUserData.mSubstrate = mSubstrate;
set(handles.MorphingMenuBody,'userdata',menuUserData);
syncGUIStatus(handles);


% --- Executes on button press in EditMorphingRate.
function EditMorphingRate_Callback(hObject, eventdata, handles)
% hObject    handle to EditMorphingRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%handles
userData = get(handles.MorphingMenuBody,'userdata');
mSubstrate = userData.mSubstrate;
%if isfield(userData,'interfaceGHIhandle')
%    if ishandle(userData.interfaceGHIhandle)
%        close(userData.interfaceGHIhandle);
%    end;
%end;
mSubstrate.menuHandle = handles.MorphingMenuBody;
if ~isfield(mSubstrate,'morphingRateGUIhandle')
    mSubstrate.morphingRateGUIhandle = morphingRateGUI('userdata',mSubstrate);
elseif ishandle(mSubstrate.morphingRateGUIhandle)
    figure(mSubstrate.morphingRateGUIhandle);
else
    mSubstrate.morphingRateGUIhandle = morphingRateGUI('userdata',mSubstrate);
end;
userData.mSubstrate = mSubstrate;
set(handles.MorphingMenuBody,'userdata',userData);


% --- Executes on button press in ImportB.
function ImportB_Callback(hObject, eventdata, handles)
% hObject    handle to ImportB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuUserData = get(handles.MorphingMenuBody,'userdata');
mSubstrate = menuUserData.mSubstrate;
[file,path] = uigetfile('*.mat','Select STRAIGHT object (B) to load');
if length(file) == 1 && length(path) == 1
    if file == 0 || path == 0
        disp('Load is cancelled!');
        return;
    end;
end;
%pathReg = regexprep(path,'\s','\\ ');
%eval(['load ' pathReg file]);
load([path file]);
mSubstrate.dataDirectoryForSpeakerB = STRAIGHTobject.dataDirectory;
mSubstrate.fileNameForSpeakerB = STRAIGHTobject.dataFileName;
mSubstrate.waveformForSpeakerB= STRAIGHTobject.waveform;
mSubstrate.samplintFrequency = STRAIGHTobject.samplingFrequency;
mSubstrate.f0TimeBaseOfSpeakerB = STRAIGHTobject.refinedF0Structure.temporalPositions;
%mSubstrate.f0OfSpeakerB = STRAIGHTobject.refinedF0Structure.f0CandidatesMap(1,:)';
mSubstrate.f0OfSpeakerB = STRAIGHTobject.refinedF0Structure.f0;
mSubstrate.spectrogramTimeBaseOfSpeakerB = ...
    STRAIGHTobject.SpectrumStructure.temporalPositions;
mSubstrate.STRAIGHTspectrogramOfSpeakerB = ...
    STRAIGHTobject.SpectrumStructure.spectrogramSTRAIGHT;
mSubstrate.aperiodicityTimeBaseOfSpeakerB = ...
    STRAIGHTobject.AperiodicityStructure.temporalPositions;
mSubstrate.aperiodicityOfSpeakerB = ...
    STRAIGHTobject.AperiodicityStructure;

menuUserData.mSubstrate = mSubstrate;
set(handles.MorphingMenuBody,'userdata',menuUserData);
syncGUIStatus(handles);

% --- Executes on button press in ImportA.
function ImportA_Callback(hObject, eventdata, handles)
% hObject    handle to ImportA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuUserData = get(handles.MorphingMenuBody,'userdata');
mSubstrate = menuUserData.mSubstrate;
[file,path] = uigetfile('*.mat','Select STRAIGHT object (A) to load');
if length(file) == 1 && length(path) == 1
    if file == 0 || path == 0
        disp('Load is cancelled!');
        return;
    end;
end;
%pathReg = regexprep(path,'\s','\\ ');
%eval(['load ' pathReg file]);
load([path file]);
mSubstrate.dataDirectoryForSpeakerA = STRAIGHTobject.dataDirectory;
mSubstrate.fileNameForSpeakerA= STRAIGHTobject.dataFileName;
mSubstrate.waveformForSpeakerA= STRAIGHTobject.waveform;
mSubstrate.samplintFrequency = STRAIGHTobject.samplingFrequency;
mSubstrate.f0TimeBaseOfSpeakerA = STRAIGHTobject.refinedF0Structure.temporalPositions;
%mSubstrate.f0OfSpeakerA = STRAIGHTobject.refinedF0Structure.f0CandidatesMap(1,:)';
mSubstrate.f0OfSpeakerA = STRAIGHTobject.refinedF0Structure.f0;
mSubstrate.spectrogramTimeBaseOfSpeakerA = ...
    STRAIGHTobject.SpectrumStructure.temporalPositions;
mSubstrate.STRAIGHTspectrogramOfSpeakerA = ...
    STRAIGHTobject.SpectrumStructure.spectrogramSTRAIGHT;
mSubstrate.aperiodicityTimeBaseOfSpeakerA = ...
    STRAIGHTobject.AperiodicityStructure.temporalPositions;
mSubstrate.aperiodicityOfSpeakerA = ...
    STRAIGHTobject.AperiodicityStructure;

menuUserData.mSubstrate = mSubstrate;
set(handles.MorphingMenuBody,'userdata',menuUserData);
syncGUIStatus(handles);


% --- Executes on button press in QuitButton.
function QuitButton_Callback(hObject, eventdata, handles)
% hObject    handle to QuitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuUserData = get(handles.MorphingMenuBody,'userdata');
if isfield(menuUserData.mSubstrate,'interfaceGHIhandle')
    if ishandle(menuUserData.mSubstrate.interfaceGHIhandle)
        close(menuUserData.mSubstrate.interfaceGHIhandle);
    end;
end;
if isfield(menuUserData.mSubstrate,'morphingRateGUIhandle')
    if ishandle(menuUserData.mSubstrate.morphingRateGUIhandle)
        close(menuUserData.mSubstrate.morphingRateGUIhandle);
    end;
end;
close(handles.MorphingMenuBody);


% --- Executes on button press in Continuum.
function Continuum_Callback(hObject, eventdata, handles)
% hObject    handle to Continuum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
makeMorphingContinuumGUI

