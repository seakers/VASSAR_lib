function varargout = NewArchitectureWnd(varargin)
% ARCHITECTUREWND MATLAB code for ArchitectureWnd.fig
%      ARCHITECTUREWND, by itself, creates a new ARCHITECTUREWND or raises the existing
%      singleton*.
%
%      H = ARCHITECTUREWND returns the handle to a new ARCHITECTUREWND or the handle to
%      the existing singleton*.
%
%      ARCHITECTUREWND('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ARCHITECTUREWND.M with the given input arguments.
%
%      ARCHITECTUREWND('Property','Value',...) creates a new ARCHITECTUREWND or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ArchitectureWnd_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ArchitectureWnd_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ArchitectureWnd

% Last Modified by GUIDE v2.5 02-Jul-2014 15:38:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ArchitectureWnd_OpeningFcn, ...
                   'gui_OutputFcn',  @ArchitectureWnd_OutputFcn, ...
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


% --- Executes just before ArchitectureWnd is made visible.
function ArchitectureWnd_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ArchitectureWnd (see VARARGIN)

% Choose default command line output for ArchitectureWnd
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ArchitectureWnd wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global zeArch;

set( handles.table, 'Data', format_arch_to_table( zeArch ) );
set(handles.table,'ColumnFormat',{'char','char','char','char','char','char','char','char','char','char'});

end

end

% --- Outputs from this function are returned to the command line.
function varargout = ArchitectureWnd_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

end


% --- Executes on button press in evaluateArchitecture.
function evaluateArchitecture_Callback(hObject, eventdata, handles)
% hObject    handle to evaluateArchitecture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global zeArch results2load resCol zeResult

data = get(handles.table,'Data');
zeArch = format_table_to_arch(data);
zeResult = zeArch.getResult;
results2load=1;
explain_arch_slow;
resCol.pushResult(zeResult)
end


% --- Executes when entered data in editable cell(s) in table.
function table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
disp ([eventdata.EditData ' ' eventdata.Error]);
eventdata.NewData = eventdata.EditData;
guidata(hObject, handles);

end