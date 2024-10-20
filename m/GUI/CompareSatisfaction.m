function varargout = CompareSatisfaction(varargin)
% COMPARESATISFACTION MATLAB code for CompareSatisfaction.fig
%      COMPARESATISFACTION, by itself, creates a new COMPARESATISFACTION or raises the existing
%      singleton*.
%
%      H = COMPARESATISFACTION returns the handle to a new COMPARESATISFACTION or the handle to
%      the existing singleton*.
%
%      COMPARESATISFACTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COMPARESATISFACTION.M with the given input arguments.
%
%      COMPARESATISFACTION('Property','Value',...) creates a new COMPARESATISFACTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CompareSatisfaction_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CompareSatisfaction_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CompareSatisfaction

% Last Modified by GUIDE v2.5 25-Jul-2014 14:59:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CompareSatisfaction_OpeningFcn, ...
                   'gui_OutputFcn',  @CompareSatisfaction_OutputFcn, ...
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


% --- Executes just before CompareSatisfaction is made visible.
function CompareSatisfaction_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CompareSatisfaction (see VARARGIN)

% Choose default command line output for CompareSatisfaction
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CompareSatisfaction wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global compArch1 compResult1 compArch2 compResult2
h = msgbox(strcat('Loading explanations...'));
arch1_details = create_satisfaction_table(compResult1);
arch2_details = create_satisfaction_table(compResult2);
diff_details = compute_diff(arch1_details, arch2_details);
set(handles.all_subobj_table, 'Data', diff_details,'ColumnWidth',{80,230,75,150,75,150});
set(handles.arch1,'String',char(compArch1.getKey));
set(handles.arch2,'String',char(compArch2.getKey));
close(h)

% by default load the first different subobj
global AE params subobj
[m,n] = size(diff_details);
if m>1 %if there are difference between the two architectures
    subobj = char(diff_details(2,1));
    ret = capa_vs_req_from_explanation_field(compResult1,subobj,AE,params);
    cell_resize(handles,ret,1);
    ret = capa_vs_req_from_explanation_field(compResult2,subobj,AE,params);
    cell_resize(handles,ret,2);
    set(handles.subobj,'String',subobj);
else
     set(handles.detail_subobj_table1, 'Data',[]);
     set(handles.detail_subobj_table2, 'Data',[]);
end



function diff = compute_diff(details1, details2)
[m,n] = size(details1);
diff = [details1(1,:),details2(1,3:4)];
for i=1:m
    if ~strcmp(details1(i,3),details2(i,3));
        diff_detail = [details1(i,:),details2(i,3:4)];
        diff = [diff;diff_detail];
    end
end

% --- Outputs from this function are returned to the command line.
function varargout = CompareSatisfaction_OutputFcn(hObject, eventdata, handles) 
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
global subobj AE params compResult1 compResult2
ret = capa_vs_req_from_explanation_field(compResult1,subobj,AE,params);
cell_resize(handles,ret,1);
ret = capa_vs_req_from_explanation_field(compResult2,subobj,AE,params);
cell_resize(handles,ret,2);


% --- Executes on button press in prev_subobj.
function prev_subobj_Callback(hObject, eventdata, handles)
% hObject    handle to prev_subobj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global subobj AE params compResult1 compResult2
data = get(handles.all_subobj_table, 'Data');
all_sub_obj = data(2:end,1);
index = find(strcmp(all_sub_obj, subobj));
if(index~=1)
    subobj = char(all_sub_obj(index-1));
    set(handles.subobj,'String',subobj);
    ret = capa_vs_req_from_explanation_field(compResult1,subobj,AE,params);
    cell_resize(handles,ret,1);
    ret = capa_vs_req_from_explanation_field(compResult2,subobj,AE,params);
    cell_resize(handles,ret,2);
end


% --- Executes on button press in next_subobj.
function next_subobj_Callback(hObject, eventdata, handles)
% hObject    handle to next_subobj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global subobj AE params compResult1 compResult2
data = get(handles.all_subobj_table, 'Data');
all_sub_obj = data(2:end,1);
index = find(strcmp(all_sub_obj, subobj));
if(index~=length(all_sub_obj))
    subobj = char(all_sub_obj(index+1));
    set(handles.subobj,'String',subobj);
    ret = capa_vs_req_from_explanation_field(compResult1,subobj,AE,params);
    cell_resize(handles,ret,1);
    ret = capa_vs_req_from_explanation_field(compResult2,subobj,AE,params);
    cell_resize(handles,ret,2);
end

% resizes the cells in the detail_subobj_table1
function cell_resize(handles,ret,num)
[r,c] = size(ret);
col_width = 750/c;
col_widths = num2cell(ones(1,c)*col_width);
ret2 = highlight_details(ret);
if num==1
    set(handles.detail_subobj_table1, 'Data', ret2,'ColumnWidth',col_widths);
elseif num ==2
    set(handles.detail_subobj_table2, 'Data', ret2,'ColumnWidth',col_widths);
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
