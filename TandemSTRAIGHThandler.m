function varargout = TandemSTRAIGHThandler(varargin)
% TANDEMSTRAIGHTHANDLER M-file for TandemSTRAIGHThandler.fig
%      TANDEMSTRAIGHTHANDLER, by itself, creates a new TANDEMSTRAIGHTHANDLER or raises the existing
%      singleton*.
%
%      H = TANDEMSTRAIGHTHANDLER returns the handle to a new TANDEMSTRAIGHTHANDLER or the handle to
%      the existing singleton*.
%
%      TANDEMSTRAIGHTHANDLER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TANDEMSTRAIGHTHANDLER.M with the given input arguments.
%
%      TANDEMSTRAIGHTHANDLER('Property','Value',...) creates a new TANDEMSTRAIGHTHANDLER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TandemSTRAIGHThandler_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TandemSTRAIGHThandler_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TandemSTRAIGHThandler
% Author Hideki Kawahara
% for academic users, BSD-2 clause lisence applies
% for non-academic users, please contact Kansai TLO, Kyoto Japan.
%   tlo-wakayama@kansai-tlo.co.jp

% Last Modified by GUIDE v2.5 17-Sep-2015 17:58:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @TandemSTRAIGHThandler_OpeningFcn, ...
    'gui_OutputFcn',  @TandemSTRAIGHThandler_OutputFcn, ...
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


% --- Executes just before TandemSTRAIGHThandler is made visible.
function TandemSTRAIGHThandler_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TandemSTRAIGHThandler (see VARARGIN)

% Choose default command line output for TandemSTRAIGHThandler
handles.output = hObject;
%handles

% Update handles structure
guidata(hObject, handles);

% User defined initialization
STRAIGHTobject = get(hObject,'userdata');
%tmp = get(handles.TandemSTRAIGHThandler,'userdata');
%tmp
%STRAIGHTobject
%STRAIGHTobject = guidata(hObject);
if ~isempty(STRAIGHTobject)
    STRAIGHTobject.creationDate = datestr(now,30);
    STRAIGHTobject.standAlone = false;
    set(handles.fileInformationText,'string',['Invoked by other program ' ]);
else %if ~isfield(STRAIGHTobject,'waveform')
    %    display('No data is given. Please call me with data.');
    [file,path] = uigetfile({'*.wav';'*.WAV';'*.aiff';'*.AIFF';'*.aif'},'Select sound file.');
    if length(file) == 1 && length(path) == 1
        if file == 0 || path == 0
            disp('Load is cancelled!');
            return;
        end;
    end;
    switch file(end-3:end)
        case {'.wav' '.WAV'}
            [x,fs] = audioread([path file]); % H.K. 24/Nov./2014
        case {'aiff' 'AIFF' '.aif'}
            [x,fs] = aiffread([path file]);
        otherwise
            disp([file ' is not a suppoetrd sound file']);
            return;
    end;
    STRAIGHTobject = struct;
    STRAIGHTobject.creationDate = datestr(now,30);
    STRAIGHTobject.dataDirectory = path;
    STRAIGHTobject.dataFileName = file;
    STRAIGHTobject.samplingFrequency = fs;
    STRAIGHTobject.waveform = x(:,1);
    STRAIGHTobject.standAlone = true;
    STRAIGHTobject.soundPath = path;
    set(handles.fileInformationText,'string',file);
    set(handles.soundFilePathText,'string',STRAIGHTobject.soundPath);
end;
%leftMargin = 14;
%topMargin = 24;
STRAIGHTobject.currentHandles = handles;
STRAIGHTobject.startedDirectory = pwd;
%GUIunits = get(handles.TandemSTRAIGHThandler,'units');
%set(handles.TandemSTRAIGHThandler,'units','pixels');
%GUIpositionInPixels = get(handles.TandemSTRAIGHThandler,'position');
%monitorPositionsInPixels = get(0,'MonitorPositions');
%lowerLeftCorner = ...
%    [leftMargin sum(monitorPositionsInPixels([2,4]))-topMargin-GUIpositionInPixels(4)];
%updatedPosition = [lowerLeftCorner GUIpositionInPixels(3:4)];
%set(handles.TandemSTRAIGHThandler,'position',updatedPosition);
%set(handles.TandemSTRAIGHThandler,'units',GUIunits);
%locateTopLeftOfGUI(topMargin,leftMargin,handles.TandemSTRAIGHThandler);
%handles
set(hObject,'userdata',STRAIGHTobject);
syncGUIStatus(handles)

%--- This function is obsolate and not in use. HK 16/Sept./2015
function locateTopLeftOfGUI(Top,Left,GUIHandle)
GUIunits = get(GUIHandle,'units');
set(GUIHandle,'units','pixels');
GUIpositionInPixels = get(GUIHandle,'position');
monitorPositionsInPixels = get(0,'MonitorPositions');
lowerLeftCorner = ...
    [Left sum(monitorPositionsInPixels([2,4]))-Top-GUIpositionInPixels(4)];
updatedPosition = [lowerLeftCorner GUIpositionInPixels(3:4)];
set(GUIHandle,'position',updatedPosition);
set(GUIHandle,'units',GUIunits);
return

% UIWAIT makes TandemSTRAIGHThandler wait for user response (see UIRESUME)
% uiwait(handles.TandemSTRAIGHThandler);


% --- Outputs from this function are returned to the command line.
function varargout = TandemSTRAIGHThandler_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
STRAIGHTobject = get(handles.TandemSTRAIGHThandler,'userdata');
if isempty(STRAIGHTobject)
    varargout{1} = [];
    close;
end;

% --- Executes on button press in F0structure.
function F0structure_Callback(hObject, eventdata, handles)
% hObject    handle to F0structure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTobject = get(handles.TandemSTRAIGHThandler,'userdata');
STRAIGHTobject.F0extractionDate = datestr(now,30);
if 1 == 2
    set(gcf,'Pointer','watch');drawnow;
    optP.debugperiodicityShaping = 2.1;% 22/May/2010 2.5; % original 2.4
    optP.compensationCoefficient = 0;
    optP.exponentControl = 1;
    optP.channelsPerOctave = 4;
    optP.numberOfHarmonicsForExtraction = 4;% 22/May/2010
    optP.f0ceil = 850;% 22/May/2010
    STRAIGHTobject.F0Structure = ...
        exF0candidatesTSTRAIGHTGB(STRAIGHTobject.waveform, ...
        STRAIGHTobject.samplingFrequency,optP);
    STRAIGHTobject.refinedF0Structure = ...
        STRAIGHTobject.F0Structure;
    set(gcf,'Pointer','arrow');drawnow;
end;
STRAIGHTobject.HandleOfCallingRoutine = handles.TandemSTRAIGHThandler;
f0ExtractorGUI('userdata',STRAIGHTobject);
set(handles.TandemSTRAIGHThandler,'userdata',STRAIGHTobject);
syncGUIStatus(handles)

% --- Executes on button press in DisplayGraph.
%function DisplayGraph_Callback(hObject, eventdata, handles)
% hObject    handle to DisplayGraph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%STRAIGHTobject = get(handles.output,'userdata');
%STRAIGHTobject.F0figure = figure;
%currentPosition = get(STRAIGHTobject.F0figure,'position');
%set(STRAIGHTobject.F0figure,'position',...  % This part can be refined
%    [max(1,currentPosition(1)-currentPosition(3)/2) ...
%    max(1,currentPosition(2)-200) currentPosition(3) currentPosition(4)+200]);
%set(STRAIGHTobject.F0figure,'menubar','none');
%tt = STRAIGHTobject.refinedF0Structure.temporalPositions;
%f0c = STRAIGHTobject.refinedF0Structure.f0CandidatesMap;
%f0s = STRAIGHTobject.refinedF0Structure.f0CandidatesScoreMap;
%subplot(211);
%STRAIGHTobject.F0Scoreplot = plot(tt,f0s(1,:)/2,'linewidth',5);
%set(STRAIGHTobject.F0Scoreplot,'color',[0.4 0.85 0.85]);
%hold on;
%plot(tt,f0s/2','.');grid on;
%hold off
%axis([tt(1) tt(end) 0 1.15]);
%set(gca,'fontsize',14);
%ylabel('periodicity score');
%ht = title('F0 trajectory editor');
%set(ht,'fontsize',20);
%currentPosition = get(gca,'position');
%set(gca,'position',[currentPosition(1) currentPosition(2)+0.2 ...
%    currentPosition(3) currentPosition(4)-0.2])
%set(gca,'handlevisibility','off')
%subplot(212);
%STRAIGHTobject.F0plot = semilogy(tt,f0c(1,:),'linewidth',5);
%set(STRAIGHTobject.F0plot,'color',[0.4 0.85 0.85]);
%hold on;
%semilogy(tt,f0c','.');grid on;
%hold off;
%axis([tt(1) tt(end) 10 1000]);
%set(gca,'fontsize',14);
%ylabel('frequency (Hz)');
%xlabel('time (s)')
%currentPosition = get(gca,'position');
%set(gca,'position',[currentPosition(1) currentPosition(2) ...
%    currentPosition(3) currentPosition(4)+0.26])
%drawnow;
%zoom on
%STRAIGHTobject.currentAxis = gca;
%set(handles.output,'userdata',STRAIGHTobject);
%syncGUIStatus(handles)

% --- Executes on button press in STRAIGHTspectrumButton.
function STRAIGHTspectrumButton_Callback(hObject, eventdata, handles)
% hObject    handle to STRAIGHTspectrumButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTobject = get(handles.TandemSTRAIGHThandler,'userdata');
STRAIGHTobject.SpectrumExtractionDate = datestr(now,30);
%prmIn.compensationCoefficient = [-0.2818;0.0397]; % this is experimental 15/Oct./2009
%prmIn.compensationCoefficient = -0.3804;
%prmIn.exponentControl = 1/10;
%prmIn.correctionForBlackman = 2.5;
%prmIn.debugperiodicityShaping = 2.5; % original 2.4
%prmIn.defaultF0 = 500;
set(gcf,'Pointer','watch');drawnow;
SpectrumStructure = ...
    exSpectrumTSTRAIGHTGB(STRAIGHTobject.waveform, ...
    STRAIGHTobject.samplingFrequency, ...
    STRAIGHTobject.refinedF0Structure);%,prmIn);
%STRAIGHTobject.SpectrumStructure = ...
%    fixWindowEffects(SpectrumStructure,STRAIGHTobject.refinedF0Structure, ...
%    prmIn.correctionForBlackman,2,1/2); % 18/Oct./2009
STRAIGHTobject.SpectrumStructure = SpectrumStructure;
processedSpectrum = unvoicedProcessing(STRAIGHTobject);
STRAIGHTobject.SpectrumStructure.spectrogramSTRAIGHT = processedSpectrum;
set(gcf,'Pointer','arrow');drawnow;
set(handles.TandemSTRAIGHThandler,'userdata',STRAIGHTobject);
syncGUIStatus(handles)


% --- Executes on button press in AperiodicityButton.
function AperiodicityButton_Callback(hObject, eventdata, handles)
% hObject    handle to AperiodicityButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTobject = get(handles.TandemSTRAIGHThandler,'userdata');
STRAIGHTobject.AperiodicityExtractionDate = datestr(now,30);
set(gcf,'Pointer','watch');drawnow;
STRAIGHTobject.AperiodicityStructure = ...
    aperiodicityRatioSigmoid(STRAIGHTobject.waveform, ...
    STRAIGHTobject.refinedF0Structure,2,2,0); % originally 2
set(gcf,'Pointer','arrow');drawnow;
if isfield(STRAIGHTobject.refinedF0Structure,'vuv')
    STRAIGHTobject.AperiodicityStructure.vuv = ...
        STRAIGHTobject.refinedF0Structure.vuv;
end;
set(handles.TandemSTRAIGHThandler,'userdata',STRAIGHTobject);
syncGUIStatus(handles)

% --- Executes on button press in SaveSynthesisButton.
function SaveSynthesisButton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveSynthesisButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTobject = get(handles.TandemSTRAIGHThandler,'userdata');
if ~isfield(STRAIGHTobject,'SynthesisStructure')
    disp('Please synthesize at first');
    return;
end;
timeStumpNameOn = get(handles.timeStumpButton,'value');
if timeStumpNameOn
    outFileName = ['SynSpch' datestr(now,30) '.wav'];
else
    soundFileName = STRAIGHTobject.dataFileName;
    if ~isempty(findstr(soundFileName,'.'))
        dotPosition = findstr(soundFileName,'.');
        outFileName = ['Syn' soundFileName(1:dotPosition(end)) 'wav'];
    else
        outFileName = ['Syn' soundFileName '.wav'];
    end;
end;
%outFileName = ['SynSpch' datestr(now,30) '.wav'];
if isfield(STRAIGHTobject,'parameterPath')
    if ~isempty(dir(STRAIGHTobject.parameterPath))
        STRAIGHTobject.oldPath = cd(STRAIGHTobject.parameterPath);
    else
        disp(['parameter directory ' STRAIGHTobject.parameterPath ' does not exist.']);
    end;
end;
[file,path] = uiputfile(outFileName,'Save the synthesized speech');
if length(file) == 1 && length(path) == 1
    if file == 0 || path == 0
        %okInd = 0;
        disp('Save is cancelled!');
        return;
    end;
end;
outSignal = STRAIGHTobject.SynthesisStructure.synthesisOut;
attenuation = 0.85/max(abs(outSignal));
outSignal = outSignal*attenuation;
audiowrite([path file],outSignal,STRAIGHTobject.samplingFrequency);
syncGUIStatus(handles)

% --- Executes on button press in SynthesisButton.
function SynthesisButton_Callback(hObject, eventdata, handles)
% hObject    handle to SynthesisButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTobject = get(handles.TandemSTRAIGHThandler,'userdata');
STRAIGHTobject.AperiodicityExtractionDate = datestr(now,30);
set(gcf,'Pointer','watch');drawnow;
%if isfield(STRAIGHTobject.refinedF0Structure,'vuv')
%    STRAIGHTobject.AperiodicityStructure.vuv = ...
%        STRAIGHTobject.refinedF0Structure.vuv;
%end;
STRAIGHTobject.SynthesisStructure = ...
    exGeneralSTRAIGHTsynthesisR2(STRAIGHTobject.AperiodicityStructure,...
    STRAIGHTobject.SpectrumStructure);
    %exTandemSTRAIGHTsynthNx(STRAIGHTobject.AperiodicityStructure,...
    %STRAIGHTobject.SpectrumStructure);
set(gcf,'Pointer','arrow');drawnow;
normalizedSound = STRAIGHTobject.SynthesisStructure.synthesisOut/max(abs(STRAIGHTobject.SynthesisStructure.synthesisOut))*0.99;
sound(normalizedSound,STRAIGHTobject.samplingFrequency);
set(handles.TandemSTRAIGHThandler,'userdata',STRAIGHTobject);
syncGUIStatus(handles)

% --- Executes on button press in SaveSTRAIGHTobjectButton.
function SaveSTRAIGHTobjectButton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveSTRAIGHTobjectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTobject = get(handles.TandemSTRAIGHThandler,'userdata');
STRAIGHTobjectBackUp = STRAIGHTobject;
%STRAIGHTobject = guidata(handles.TandemSTRAIGHThandler);
if isfield(STRAIGHTobject,'standAlone')
    STRAIGHTobject = rmfield(STRAIGHTobject,'standAlone');
end;
STRAIGHTobject.lastUpdate = datestr(now);
timeStumpNameOn = get(handles.timeStumpButton,'value');
if timeStumpNameOn
    outFileName = ['StrObj' datestr(now,30) '.mat'];
else
    soundFileName = STRAIGHTobject.dataFileName;
    if ~isempty(findstr(soundFileName,'.'))
        dotPosition = findstr(soundFileName,'.');
        outFileName = ['StrObj' soundFileName(1:dotPosition(end)) 'mat'];
    else
        outFileName = ['StrObj' soundFileName '.mat'];
    end;
end;
if isfield(STRAIGHTobject,'parameterPath')
    if ~isempty(dir(STRAIGHTobject.parameterPath))
        STRAIGHTobject.oldPath = cd(STRAIGHTobject.parameterPath);
    else
        disp(['parameter directory ' STRAIGHTobject.parameterPath ' does not exist.']);
    end;
end;
[file,path] = uiputfile(outFileName,'Save the STRAIGHT object');
if length(file) == 1 && length(path) == 1
    if file == 0 || path == 0
        %okInd = 0;
        disp('Save is cancelled!');
        return;
    end;
end;
%pathReg = regexprep(path,'\s','\\ ');
%eval(['save ' pathReg file ' STRAIGHTobject']);
if isfield(STRAIGHTobject,'HandleOfCallingRoutine')
    STRAIGHTobject = rmfield(STRAIGHTobject,'HandleOfCallingRoutine');
end;
if isfield(STRAIGHTobject,'currentHandles')
    STRAIGHTobject = rmfield(STRAIGHTobject,'currentHandles');
end;
save([path file],'STRAIGHTobject');
STRAIGHTobject = STRAIGHTobjectBackUp;
STRAIGHTobject.parameterPath = path;
set(handles.parameterPathText,'string',path);
set(handles.TandemSTRAIGHThandler,'userdata',STRAIGHTobject);
syncGUIStatus(handles)

% --- Executes on button press in PlayOriginal.
function PlayOriginal_Callback(hObject, eventdata, handles)
% hObject    handle to PlayOriginal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTobject = get(handles.TandemSTRAIGHThandler,'userdata');
x = STRAIGHTobject.waveform/max(abs(STRAIGHTobject.waveform))*0.99;
fs = STRAIGHTobject.samplingFrequency;
%sound(x,fs);
STRAIGHTobject.player = audioplayer(x,fs);
playblocking(STRAIGHTobject.player);
set(handles.TandemSTRAIGHThandler,'userdata',STRAIGHTobject);
syncGUIStatus(handles)

% --- Executes on button press in PlaySynth.
function PlaySynth_Callback(hObject, eventdata, handles)
% hObject    handle to PlaySynth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTobject = get(handles.TandemSTRAIGHThandler,'userdata');
%sound(STRAIGHTobject.SynthesisStructure.synthesisOut/max(abs(STRAIGHTobject.SynthesisStructure.synthesisOut))*0.99,...
%    STRAIGHTobject.samplingFrequency);
STRAIGHTobject.synthPlayer = ...
    audioplayer(STRAIGHTobject.SynthesisStructure.synthesisOut/max(abs(STRAIGHTobject.SynthesisStructure.synthesisOut))*0.99,...
    STRAIGHTobject.samplingFrequency);
play(STRAIGHTobject.synthPlayer);
set(handles.TandemSTRAIGHThandler,'userdata',STRAIGHTobject);
syncGUIStatus(handles)


% --- Executes on button press in ImportSTRAIGHTobject.
function ImportSTRAIGHTobject_Callback(hObject, eventdata, handles)
% hObject    handle to ImportSTRAIGHTobject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uigetfile('*.mat','Select STRAIGHT object to load');
if length(file) == 1 && length(path) == 1
    if file == 0 || path == 0
        disp('Load is cancelled!');
        return;
    end;
end;
%pathReg = regexprep(path,'\s','\\ ');
%eval(['load ' pathReg file]);
load([path file]);
if exist('STRAIGHTobject') ~= 1
    disp(['The file ' file ' is not a STRAIGHT object']);
    return;
else
    STRAIGHTobject.originalSubstratePath = path;
    STRAIGHTobject.originalSubstrateFile = file;
    STRAIGHTobject.currentHandles = handles;
    STRAIGHTobject.standAlone = true;
    set(handles.TandemSTRAIGHThandler,'userdata',STRAIGHTobject);
end;
syncGUIStatus(handles)


% --- Executes on button press in UseRegion.
%function UseRegion_Callback(hObject, eventdata, handles)
% hObject    handle to UseRegion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%STRAIGHTobject = get(handles.output,'userdata');
%figure(STRAIGHTobject.F0figure)
%if gca == STRAIGHTobject.currentAxis
%xlim = get(STRAIGHTobject.currentAxis,'xlim');
%ylim = get(STRAIGHTobject.currentAxis,'ylim');
%STRAIGHTobject.refinedF0Structure = ...
%    reviseF0candidate(STRAIGHTobject.refinedF0Structure,[xlim ylim]);
%end;
%tt = STRAIGHTobject.refinedF0Structure.temporalPositions;
%f0c = STRAIGHTobject.refinedF0Structure.f0CandidatesMap;
%f0s = STRAIGHTobject.refinedF0Structure.f0CandidatesScoreMap;
%%----------- periodicity score --------
%subplot(211)
%STRAIGHTobject.F0Scoreplot = plot(tt,f0s(1,:)/2,'linewidth',5);
%set(STRAIGHTobject.F0Scoreplot,'color',[0.4 0.85 0.85]);
%hold on;
%plot(tt,f0s/2','.');grid on;
%hold off;
%drawnow;
%axis([tt(1) tt(end) 0 1.15]);
%set(gca,'fontsize',14);
%ylabel('periodicity score');
%ht = title('F0 trajectory editor');
%set(ht,'fontsize',20);
%currentPosition = get(gca,'position');
%set(gca,'position',[currentPosition(1) currentPosition(2)+0.2 ...
%    currentPosition(3) currentPosition(4)-0.2])
%set(gca,'handlevisibility','off')
%%----------- F0 candidates -----------
%subplot(212)
%STRAIGHTobject.F0plot = semilogy(tt,f0c(1,:),'linewidth',5);
%set(STRAIGHTobject.F0plot,'color',[0.4 0.85 0.85]);
%hold on;
%semilogy(tt,f0c','.');grid on;
%hold off;
%set(gca,'fontsize',14);
%ylabel('frequency (Hz)');
%xlabel('time (s)')
%axis([tt(1) tt(end) 10 1000]);
%currentPosition = get(gca,'position');
%set(gca,'position',[currentPosition(1) currentPosition(2) ...
%    currentPosition(3) currentPosition(4)+0.26])
%drawnow;
%STRAIGHTobject.currentAxis = gca;
%set(handles.output,'userdata',STRAIGHTobject);
%syncGUIStatus(handles)

% --- Executes on button press in FullReset.
%function FullReset_Callback(hObject, eventdata, handles)
% hObject    handle to FullReset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%---- internal function

function syncGUIStatus(handles)

STRAIGHTobject = get(handles.TandemSTRAIGHThandler,'userdata');

if STRAIGHTobject.standAlone
    set(handles.ImportSTRAIGHTobject,'enable','on');
else
    set(handles.ImportSTRAIGHTobject,'enable','off');
end;
set(handles.PlaySynth,'enable','off');
set(handles.F0structure,'enable','off');
set(handles.PlayOriginal,'enable','off');
set(handles.SaveSTRAIGHTobjectButton,'enable','off');
set(handles.SynthesisButton,'enable','off');
set(handles.SaveSynthesisButton,'enable','off');
set(handles.AperiodicityButton,'enable','off');
set(handles.STRAIGHTspectrumButton,'enable','off');
set(handles.openGUIbutton,'enable','off');
set(handles.FinishButton,'enable','off');
if isfield(STRAIGHTobject,'waveform')
    if ~isempty(STRAIGHTobject.waveform)
        set(handles.PlayOriginal,'enable','on');
        set(handles.F0structure,'enable','on');
    end;
end;
if isfield(STRAIGHTobject,'refinedF0Structure')
    if ~isempty(STRAIGHTobject.refinedF0Structure)
        set(handles.F0structure,'enable','off');
        set(handles.AperiodicityButton,'enable','on');
        set(handles.STRAIGHTspectrumButton,'enable','on');
    end;
end;
if isfield(STRAIGHTobject,'refinedF0Structure') && ...
        ~isempty(STRAIGHTobject.refinedF0Structure) &&...
        isfield(STRAIGHTobject,'AperiodicityStructure') && ...
        ~isempty(STRAIGHTobject.AperiodicityStructure)
    %set(handles.F0structure,'enable','off');
    set(handles.AperiodicityButton,'enable','off');
end;
if isfield(STRAIGHTobject,'refinedF0Structure') && ...
        ~isempty(STRAIGHTobject.refinedF0Structure) &&...
        isfield(STRAIGHTobject,'SpectrumStructure') && ...
        ~isempty(STRAIGHTobject.SpectrumStructure)
    %set(handles.F0structure,'enable','off');
    set(handles.STRAIGHTspectrumButton,'enable','off');
end;
if isfield(STRAIGHTobject,'AperiodicityStructure')&&...
        isfield(STRAIGHTobject,'refinedF0Structure')&&...
        isfield(STRAIGHTobject,'SpectrumStructure')
    if ~isempty(STRAIGHTobject.refinedF0Structure)&&...
            ~isempty(STRAIGHTobject.AperiodicityStructure)&&...
            ~isempty(STRAIGHTobject.SpectrumStructure)
        set(handles.SynthesisButton,'enable','on');
        set(handles.openGUIbutton,'enable','on');
        set(handles.SaveSTRAIGHTobjectButton,'enable','on');
        set(handles.FinishButton,'enable','on');
    end;
end;
if isfield(STRAIGHTobject,'SynthesisStructure')
    if ~isempty(STRAIGHTobject.SynthesisStructure)
        set(handles.SaveSynthesisButton,'enable','on');
        set(handles.PlaySynth,'enable','on');
    end;
end;
if isfield(STRAIGHTobject,'dataFileName')
    if ~isempty(STRAIGHTobject.dataFileName)
        set(handles.fileInformationText,'string',STRAIGHTobject.dataFileName);
    end;
end;
if isfield(STRAIGHTobject,'soundPath')
    if ~isempty(STRAIGHTobject.soundPath)
        if ~isempty(dir(STRAIGHTobject.soundPath))
            set(handles.soundFilePathText,'string',STRAIGHTobject.soundPath);
        end;
    end;
end;


% --- Executes on button press in FinishButton.
function FinishButton_Callback(hObject, eventdata, handles)
% hObject    handle to FinishButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTobject = get(handles.TandemSTRAIGHThandler,'userdata');
cd(STRAIGHTobject.startedDirectory);
if isfield(STRAIGHTobject,'STRAIGHTGUIhandle') && ...
        ishandle(STRAIGHTobject.STRAIGHTGUIhandle)
    close(STRAIGHTobject.STRAIGHTGUIhandle);
end;
if isfield(STRAIGHTobject,'morphingMenu')
    menuUserData = get(STRAIGHTobject.morphingMenu,'userdata');
    mSubstrate = menuUserData.mSubstrate;
    switch STRAIGHTobject.speakerID
        case 'A'
            if isfield(STRAIGHTobject,'dataDirectory')
                mSubstrate.dataDirectoryForSpeakerA = STRAIGHTobject.dataDirectory;
            end;
            mSubstrate.waveformForSpeakerA= STRAIGHTobject.waveform;
            mSubstrate.samplintFrequency = STRAIGHTobject.samplingFrequency;
            if isfield(STRAIGHTobject,'dataFileName')
                mSubstrate.fileNameForSpeakerA= STRAIGHTobject.dataFileName;
            end;
            mSubstrate.f0TimeBaseOfSpeakerA = STRAIGHTobject.refinedF0Structure.temporalPositions;
            mSubstrate.f0OfSpeakerA = STRAIGHTobject.refinedF0Structure.f0CandidatesMap(1,:)';
            mSubstrate.spectrogramTimeBaseOfSpeakerA = ...
                STRAIGHTobject.SpectrumStructure.temporalPositions;
            mSubstrate.STRAIGHTspectrogramOfSpeakerA = ...
                STRAIGHTobject.SpectrumStructure.spectrogramSTRAIGHT;
            mSubstrate.aperiodicityTimeBaseOfSpeakerA = ...
                STRAIGHTobject.AperiodicityStructure.temporalPositions;
            mSubstrate.aperiodicityOfSpeakerA = ...
                STRAIGHTobject.AperiodicityStructure;
        case'B'
            if isfield(STRAIGHTobject,'dataDirectory')
                mSubstrate.dataDirectoryForSpeakerB = STRAIGHTobject.dataDirectory;
            end;
            mSubstrate.waveformForSpeakerB= STRAIGHTobject.waveform;
            mSubstrate.samplintFrequency = STRAIGHTobject.samplingFrequency;
            if isfield(STRAIGHTobject,'dataFileName')
                mSubstrate.fileNameForSpeakerB= STRAIGHTobject.dataFileName;
            end;
            mSubstrate.f0TimeBaseOfSpeakerB = STRAIGHTobject.refinedF0Structure.temporalPositions;
            mSubstrate.f0OfSpeakerB = STRAIGHTobject.refinedF0Structure.f0CandidatesMap(1,:)';
            mSubstrate.spectrogramTimeBaseOfSpeakerB = ...
                STRAIGHTobject.SpectrumStructure.temporalPositions;
            mSubstrate.STRAIGHTspectrogramOfSpeakerB = ...
                STRAIGHTobject.SpectrumStructure.spectrogramSTRAIGHT;
            mSubstrate.aperiodicityTimeBaseOfSpeakerB = ...
                STRAIGHTobject.AperiodicityStructure.temporalPositions;
            mSubstrate.aperiodicityOfSpeakerB = ...
                STRAIGHTobject.AperiodicityStructure;
        otherwise
    end;
    menuUserData.mSubstrate = mSubstrate;
    set(STRAIGHTobject.morphingMenu,'userdata',menuUserData);
    %MorphingMenu('selected','on');
    if isfield(menuUserData,'currentHandles') && ...
            ishandle(menuUserData.currentHandles)
        MorphingMenu('syncGUIStatus',menuUserData.currentHandles);
    end;
    figure(STRAIGHTobject.morphingMenu);
end;
close(handles.TandemSTRAIGHThandler);


% --- Executes on button press in readFileButton.
function readFileButton_Callback(hObject, eventdata, handles)
% hObject    handle to readFileButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTobject = get(handles.TandemSTRAIGHThandler,'userdata');
if isfield(STRAIGHTobject,'soundPath')
    if ~isempty(dir(STRAIGHTobject.soundPath))
        STRAIGHTobject.oldPath = cd(STRAIGHTobject.soundPath);
    else
        disp(['directory ' STRAIGHTobject.soundPath ' cannot be found.']);
    end;
end;
[file,path] = uigetfile({'*.wav';'*.WAV'},'Select sound file.');
if length(file) == 1 && length(path) == 1
    if file == 0 || path == 0
        disp('Load is cancelled!');
        return;
    end;
end;
[x,fs] = audioread([path file]);
x = x(:,1)+randn(length(x(:,1)),1)*std(x(:,1))/100000; % safeguard 7/Msy/2012
STRAIGHTobject.creationDate = datestr(now,30);
STRAIGHTobject.dataDirectory = path;
STRAIGHTobject.dataFileName = file;
STRAIGHTobject.samplingFrequency = fs;
STRAIGHTobject.waveform = x(:,1);
STRAIGHTobject.standAlone = true;
STRAIGHTobject.soundPath = path;
set(handles.fileInformationText,'string',['file: ' file]);
set(handles.TandemSTRAIGHThandler,'userdata',STRAIGHTobject);
set(handles.soundFilePathText,'string',STRAIGHTobject.soundPath);
set(handles.TandemSTRAIGHThandler,'userdata',STRAIGHTobject);
clearAnalysisButton_Callback(handles.clearAnalysisButton,1,handles);


% --- Executes on button press in openGUIbutton.
function openGUIbutton_Callback(hObject, eventdata, handles)
% hObject    handle to openGUIbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTobject = get(handles.TandemSTRAIGHThandler,'userdata');
STRAIGHTGUIhandle = STRAIGHTmanipulatorGUI('userdata',STRAIGHTobject);
STRAIGHTobject.STRAIGHTGUIhandle = STRAIGHTGUIhandle;
set(handles.TandemSTRAIGHThandler,'userdata',STRAIGHTobject);
return;

% --- Executes on button press in clearAnalysisButton.
function clearAnalysisButton_Callback(hObject, eventdata, handles)
% hObject    handle to clearAnalysisButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTobject = get(handles.TandemSTRAIGHThandler,'userdata');
set(handles.SynthesisButton,'enable','off');
set(handles.openGUIbutton,'enable','off');
set(handles.SaveSTRAIGHTobjectButton,'enable','off');
set(handles.FinishButton,'enable','off');
set(handles.AperiodicityButton,'enable','on');
set(handles.STRAIGHTspectrumButton,'enable','on');
set(handles.SaveSynthesisButton,'enable','off');
set(handles.PlaySynth,'enable','off');
if isfield(STRAIGHTobject,'refinedF0Structure')
    STRAIGHTobject = rmfield(STRAIGHTobject,'refinedF0Structure');
    %if ~isempty(STRAIGHTobject.refinedF0Structure)
        %STRAIGHTobject.refinedF0Structure = [];
    %end;
end;
if isfield(STRAIGHTobject,'AperiodicityStructure')
    STRAIGHTobject = rmfield(STRAIGHTobject,'AperiodicityStructure');
    %if ~isempty(STRAIGHTobject.AperiodicityStructure)
    %    STRAIGHTobject.AperiodicityStructure = [];
    %end;
end;
if isfield(STRAIGHTobject,'SpectrumStructure')
    STRAIGHTobject = rmfield(STRAIGHTobject,'SpectrumStructure');
    %if ~isempty(STRAIGHTobject.SpectrumStructure)
    %    STRAIGHTobject.SpectrumStructure = [];
    %end;
end;
if isfield(STRAIGHTobject,'SynthesisStructure')
    STRAIGHTobject = rmfield(STRAIGHTobject,'SynthesisStructure');
    %if ~isempty(STRAIGHTobject.SynthesisStructure)
    %    STRAIGHTobject.SynthesisStructure = [];
    %end;
end;
set(handles.TandemSTRAIGHThandler,'userdata',STRAIGHTobject);
syncGUIStatus(handles)
return;


% --- Executes on button press in timeStumpButton.
function timeStumpButton_Callback(hObject, eventdata, handles)
% hObject    handle to timeStumpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of timeStumpButton


% --- Executes on button press in sourceNameButton.
function sourceNameButton_Callback(hObject, eventdata, handles)
% hObject    handle to sourceNameButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sourceNameButton


% --- Executes on button press in createDirectoryButton.
function createDirectoryButton_Callback(hObject, eventdata, handles)
% hObject    handle to createDirectoryButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
STRAIGHTobject = get(handles.TandemSTRAIGHThandler,'userdata');
if isfield(STRAIGHTobject,'parameterPath')
    if ~isempty(dir(STRAIGHTobject.parameterPath))
        STRAIGHTobject.oldPath = cd(STRAIGHTobject.parameterPath);
    else
        disp(['parameter directory ' STRAIGHTobject.parameterPath ' does not exist.']);
        STRAIGHTobject.oldPath = pwd;
    end;
end;
dirName = uigetdir('','Select/create directory');
dirName
if dirName ~= 0
    cd(dirName);
    STRAIGHTobject.parameterPath = pwd;
    set(handles.TandemSTRAIGHThandler,'userdata',STRAIGHTobject);
    set(handles.parameterPathText,'string',STRAIGHTobject.parameterPath);
else
    disp('Directory selection is cancelled');
    cd(STRAIGHTobject.oldPath);
end;
