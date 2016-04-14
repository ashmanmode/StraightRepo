function varargout = makeMorphingContinuumGUI(varargin)
% MAKEMORPHINGCONTINUUMGUI M-file for makeMorphingContinuumGUI.fig
%      MAKEMORPHINGCONTINUUMGUI, by itself, creates a new MAKEMORPHINGCONTINUUMGUI or raises the existing
%      singleton*.
%
%      H = MAKEMORPHINGCONTINUUMGUI returns the handle to a new MAKEMORPHINGCONTINUUMGUI or the handle to
%      the existing singleton*.
%
%      MAKEMORPHINGCONTINUUMGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAKEMORPHINGCONTINUUMGUI.M with the given input arguments.
%
%      MAKEMORPHINGCONTINUUMGUI('Property','Value',...) creates a new MAKEMORPHINGCONTINUUMGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before makeMorphingContinuumGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to makeMorphingContinuumGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help makeMorphingContinuumGUI

% Last Modified by GUIDE v2.5 05-Feb-2011 04:04:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @makeMorphingContinuumGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @makeMorphingContinuumGUI_OutputFcn, ...
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


% --- Executes just before makeMorphingContinuumGUI is made visible.
function makeMorphingContinuumGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to makeMorphingContinuumGUI (see VARARGIN)

% Choose default command line output for makeMorphingContinuumGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
handles
userData = get(handles.makeMorphingContinuumGUITag,'userdata');
if isempty(userData)
    menuUserData.currentHandles = handles;
    menuUserData.outDirectoruName = ['continuum' datestr(now,30)];
    menuUserData.outFileRootName = 'stimulus';
    menuUserData.numberOfSteps = 11;
    menuUserData.rangeExpansion = 1;
    menuUserData.dateDirectory = pwd;
    set(handles.currentDirectory,'String',menuUserData.dateDirectory);
    set(handles.TargetDirectory,'String',menuUserData.outDirectoruName);
    set(handles.FileNameRoot,'String',menuUserData.outFileRootName);
    set(handles.NumberOfSteps,'String',num2str(menuUserData.numberOfSteps));
    set(handles.RangeMagnification,'String',num2str(menuUserData.rangeExpansion));
    set(handles.makeMorphingContinuumGUITag,'userdata',menuUserData);
end;


% UIWAIT makes makeMorphingContinuumGUI wait for user response (see UIRESUME)
% uiwait(handles.makeMorphingContinuumGUITag);


% --- Outputs from this function are returned to the command line.
function varargout = makeMorphingContinuumGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in GenerateContinuumButton.
function GenerateContinuumButton_Callback(hObject, eventdata, handles)
% hObject    handle to GenerateContinuumButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuUserData = get(handles.makeMorphingContinuumGUITag,'userdata')
outFileDirecotry = [menuUserData.dateDirectory '/' menuUserData.outDirectoruName];
outFileRootName = menuUserData.outFileRootName;
nOfSteps = num2str(menuUserData.numberOfSteps);
expansionRate = num2str(menuUserData.rangeExpansion);
makeMorphingContinuum(outFileDirecotry,outFileRootName,nOfSteps,expansionRate)

function FileNameRoot_Callback(hObject, eventdata, handles)
% hObject    handle to FileNameRoot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuUserData = get(handles.makeMorphingContinuumGUITag,'userdata');
menuUserData.outFileRootName = get(handles.FileNameRoot,'string');
set(handles.makeMorphingContinuumGUITag,'userdata',menuUserData);

% Hints: get(hObject,'String') returns contents of FileNameRoot as text
%        str2double(get(hObject,'String')) returns contents of FileNameRoot as a double


% --- Executes during object creation, after setting all properties.
function FileNameRoot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileNameRoot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NumberOfSteps_Callback(hObject, eventdata, handles)
% hObject    handle to NumberOfSteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuUserData = get(handles.makeMorphingContinuumGUITag,'userdata');
menuUserData.numberOfSteps = eval(get(handles.NumberOfSteps,'string'));
set(handles.makeMorphingContinuumGUITag,'userdata',menuUserData);
% Hints: get(hObject,'String') returns contents of NumberOfSteps as text
%        str2double(get(hObject,'String')) returns contents of NumberOfSteps as a double


% --- Executes during object creation, after setting all properties.
function NumberOfSteps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumberOfSteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RangeMagnification_Callback(hObject, eventdata, handles)
% hObject    handle to RangeMagnification (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuUserData = get(handles.makeMorphingContinuumGUITag,'userdata');
menuUserData.rangeExpansion = eval(get(handles.RangeMagnification,'string'));
set(handles.makeMorphingContinuumGUITag,'userdata',menuUserData);
% Hints: get(hObject,'String') returns contents of RangeMagnification as text
%        str2double(get(hObject,'String')) returns contents of RangeMagnification as a double


% --- Executes during object creation, after setting all properties.
function RangeMagnification_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RangeMagnification (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TargetDirectory_Callback(hObject, eventdata, handles)
% hObject    handle to TargetDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuUserData = get(handles.makeMorphingContinuumGUITag,'userdata');
menuUserData.outDirectoruName = get(handles.TargetDirectory,'string');
set(handles.makeMorphingContinuumGUITag,'userdata',menuUserData);

% Hints: get(hObject,'String') returns contents of TargetDirectory as text
%        str2double(get(hObject,'String')) returns contents of TargetDirectory as a double



function currentDirectory_Callback(hObject, eventdata, handles)
% hObject    handle to currentDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuUserData = get(handles.makeMorphingContinuumGUITag,'userdata');
menuUserData.dateDirectory = get(handles.currentDirectory,'string');
cd(menuUserData.dateDirectory);
set(handles.makeMorphingContinuumGUITag,'userdata',menuUserData);

% Hints: get(hObject,'String') returns contents of currentDirectory as text
%        str2double(get(hObject,'String')) returns contents of currentDirectory as a double
