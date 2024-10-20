function varargout = ExplainSatisfaction(varargin)
% EXPLAINSATISFACTION MATLAB code for ExplainSatisfaction.fig
%      EXPLAINSATISFACTION, by itself, creates a new EXPLAINSATISFACTION or raises the existing
%      singleton*.
%
%      H = EXPLAINSATISFACTION returns the handle to a new EXPLAINSATISFACTION or the handle to
%      the existing singleton*.
%
%      EXPLAINSATISFACTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPLAINSATISFACTION.M with the given input arguments.
%
%      EXPLAINSATISFACTION('Property','Value',...) creates a new EXPLAINSATISFACTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ExplainSatisfaction_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ExplainSatisfaction_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ExplainSatisfaction

% Last Modified by GUIDE v2.5 25-Jul-2014 15:00:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ExplainSatisfaction_OpeningFcn, ...
                   'gui_OutputFcn',  @ExplainSatisfaction_OutputFcn, ...
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


% --- Executes just before ExplainSatisfaction is made visible.
function ExplainSatisfaction_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ExplainSatisfaction (see VARARGIN)

% Choose default command line output for ExplainSatisfaction
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ExplainSatisfaction wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global zeResult
h = msgbox('Loading Explanations. Please Wait');
details = create_satisfaction_table(zeResult);
set(handles.all_subobj_table, 'Data',details,'ColumnWidth',{130,300,100,200});
close(h);

% by default load the AERO1-1
global AE params subobj
subobj = char(details(2,1));
ret = capa_vs_req_from_explanation_field(zeResult,subobj,AE,params);
cell_resize(handles,ret);
set(handles.subobj,'String',subobj);
% set( handles.detail_subobj_table, 'Data', create_satisfaction_table );


% --- Outputs from this function are returned to the command line.
function varargout = ExplainSatisfaction_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function subobj_Callback(hObject, eventdata, handles)
% hObject    handle to subobj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of subobj as text
%        str2double(get(hObject,'String')) returns contents of subobj as a double
global subobj
subobj = get(hObject,'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function subobj_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subobj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_update_subobj.
function button_update_subobj_Callback(hObject, eventdata, handles)
% hObject    handle to button_update_subobj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global subobj AE params zeResult
ret = capa_vs_req(zeResult,subobj,AE,params);
cell_resize(handles,ret);


% --- Executes on button press in prev_subobj.
function prev_subobj_Callback(hObject, eventdata, handles)
% hObject    handle to prev_subobj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global subobj AE params zeResult
data = get(handles.all_subobj_table, 'Data');
all_sub_obj = data(2:end,1);
index = find(strcmp(all_sub_obj, subobj));
if(index~=1)
    subobj = char(all_sub_obj(index-1));
    set(handles.subobj,'String',subobj);
    ret = capa_vs_req_from_explanation_field(zeResult,subobj,AE,params);
    cell_resize(handles,ret);
end


% --- Executes on button press in next_subobj.
function next_subobj_Callback(hObject, eventdata, handles)
% hObject    handle to next_subobj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global subobj AE params zeResult
data = get(handles.all_subobj_table, 'Data');
all_sub_obj = data(2:end,1);
index = find(strcmp(all_sub_obj, subobj));
if(index~=length(all_sub_obj))
    subobj = char(all_sub_obj(index+1));
    set(handles.subobj,'String',subobj);
    ret = capa_vs_req_from_explanation_field(zeResult,subobj,AE,params);
    cell_resize(handles,ret);
end

% resizes the cells in the detail_subobj_table
function cell_resize(handles,ret)
[r,c] = size(ret);
col_width = 750/c;
col_widths = num2cell(ones(1,c)*col_width);
if r>1
    ret2 = highlight_details(ret);
    set( handles.detail_subobj_table, 'Data', ret2,'ColumnWidth',col_widths);
else
    set( handles.detail_subobj_table, 'Data', ret,'ColumnWidth',col_widths);
end
% highlights satisfaction that are 1.0 as blue or 0.0 as red
function [ret2] = highlight_details(ret)
[r,c] = size(ret);
ret2 = cell(r,c);
for i=4:r
    for j = 3:c-1
        if(~isempty(strfind(char(ret(i,j)),'(0)'))) %highlight red if 0.0
            ret2(i,j) = strcat('<html><span style="color: #FF0000; font-weight: bold;">',ret(i,j),'</span></html>');
        elseif(~isempty(strfind(char(ret(i,j)),'(1)'))) %highlight blue if 1.0
            ret2(i,j) = strcat('<html><span style="color: #0000FF; font-weight: bold;">',ret(i,j),'</span></html>');
        else
            ret2(i,j) = ret(i,j);
        end
    end
end

%copy over rest of data
ret2(1:3,3:end) = ret(1:3,3:end);
ret2(1:end,1:2) = ret(1:end,1:2);
ret2(2:end,end) = ret(2:end,end);
