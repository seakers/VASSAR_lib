function varargout = ExplainSCDesign(varargin)
% EXPLAINSCDESIGN MATLAB code for ExplainSCDesign.fig
%      EXPLAINSCDESIGN, by itself, creates a new EXPLAINSCDESIGN or raises the existing
%      singleton*.
%
%      H = EXPLAINSCDESIGN returns the handle to a new EXPLAINSCDESIGN or the handle to
%      the existing singleton*.
%
%      EXPLAINSCDESIGN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPLAINSCDESIGN.M with the given input arguments.
%
%      EXPLAINSCDESIGN('Property','Value',...) creates a new EXPLAINSCDESIGN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ExplainSCDesign_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ExplainSCDesign_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ExplainSCDesign

% Last Modified by GUIDE v2.5 01-Apr-2014 16:22:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ExplainSCDesign_OpeningFcn, ...
                   'gui_OutputFcn',  @ExplainSCDesign_OutputFcn, ...
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


% --- Executes just before ExplainSCDesign is made visible.
function ExplainSCDesign_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ExplainSCDesign (see VARARGIN)

% Choose default command line output for ExplainSCDesign
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ExplainSCDesign wait for user response (see UIRESUME)
% uiwait(handles.figure1);
sat_id = str2double(get(handles.sat_id,'String'));
create_spacecraft_table( handles.table);
plot_pie_chart(handles.axes,sat_id);

% --- Outputs from this function are returned to the command line.
function varargout = ExplainSCDesign_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




function sat_id_Callback(hObject, eventdata, handles)
% hObject    handle to sat_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sat_id as text
%        str2double(get(hObject,'String')) returns contents of sat_id as a double
sat_id = str2double(get(handles.sat_id,'String'));
plot_pie_chart(handles.axes,sat_id);

% --- Executes during object creation, after setting all properties.
function sat_id_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sat_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
