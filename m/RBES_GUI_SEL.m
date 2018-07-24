function varargout = RBES_GUI_SEL(varargin)
% RBES_GUI_SEL MATLAB code for RBES_GUI_SEL.fig
%      RBES_GUI_SEL, by itself, creates a new RBES_GUI_SEL or raises the existing
%      singleton*.
%
%      H = RBES_GUI_SEL returns the handle to a new RBES_GUI_SEL or the handle to
%      the existing singleton*.
%
%      RBES_GUI_SEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RBES_GUI_SEL.M with the given input arguments.
%
%      RBES_GUI_SEL('Property','Value',...) creates a new RBES_GUI_SEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RBES_GUI_SEL_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RBES_GUI_SEL_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RBES_GUI_SEL

% Last Modified by GUIDE v2.5 04-Oct-2011 22:40:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RBES_GUI_SEL_OpeningFcn, ...
                   'gui_OutputFcn',  @RBES_GUI_SEL_OutputFcn, ...
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


% --- Executes just before RBES_GUI_SEL is made visible.
function RBES_GUI_SEL_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RBES_GUI_SEL (see VARARGIN)

% Choose default command line output for RBES_GUI_SEL
handles.output = hObject;
set(handles.status,'Style','Text');
set(handles.status,'FontWeight','Bold');

update_mem(hObject,handles);
RBES_Init_Params_EOS;
handles.params = params;

update_instruments(hObject,handles);

plot_manual_arch_Callback(hObject, eventdata, handles);

%load_rules_Callback(hObject, eventdata, handles);

%eval_man_arch_Callback(hObject, eventdata, handles);

set_status(hObject,handles,'Ready');
set(handles.case_study_buttongroup,'SelectionChangeFcn',@case_study_buttongroup_SelectionChangeFcn);
guidata(hObject, handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RBES_GUI_SEL wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = RBES_GUI_SEL_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%% Support functions
function update_instruments(hObject,handles)
for i = 1:length(handles.params.instrument_list)
    name = ['handles.I' num2str(i) '_name'];
    h = eval(name);
    set(h,'String',handles.params.instrument_list{i});
end
guidata(hObject, handles);

function update_mem(hObject,handles)
max = num2str(round(java.lang.Runtime.getRuntime.maxMemory/1024/1024));
tot = num2str(round(java.lang.Runtime.getRuntime.totalMemory/1024/1024));
free =num2str(round(java.lang.Runtime.getRuntime.freeMemory/1024/1024));
mem_str = ['max=' max ',tot=' tot ',free=' free];
set(handles.mem,'String',mem_str);
guidata(hObject, handles);

function set_status(hObject,handles,st)
if strcmp(st,'Busy')
    set(handles.status,'BackgroundColor',[1 0 0]);
    set(handles.status,'String','Busy');
elseif strcmp(st,'Ready')
    set(handles.status,'BackgroundColor',[0 1 0]);
    set(handles.status,'String','Ready');
else
    set(handles.status,'BackgroundColor',[1 0 0]);
    set(handles.status,'String',st);
    
end
guidata(hObject, handles);
pause(0.33);

function mag = u_to_mag(u,mi,ma)
% in u = magn - magn_min / magn_max - magn_min returns magn from u
mag = mi + u*(ma - mi);

function [x,y] = iso_utility_line(u0,w_cost,scmin,scmax,cmin,cmax)
% returns the two vectors [x1 x2] [y1 y2] such that the line that passess
% through (x1,y1) and (x2,y2) is the iso-utility u0
usc1 = u0*(1+w_cost) - w_cost;
x1 = u_to_mag(usc1,scmin,scmax);
y1 = cmin;

auco2 = 1 - (u0*(w_cost + 1) - 1)/w_cost;
y2 = u_to_mag(auco2,cmin,cmax);
x2 = scmax;

x = [x1 x2];
y = [y1 y2];

function test_plot(src,eventdata,handles,good_pack_archs,sciences,costs)
mouse = get(gca, 'CurrentPoint');
xmouse = mouse(1,1);
ymouse = mouse(1,2);
[val, i] = min(abs(sciences - xmouse).^2+abs(costs - ymouse).^2);
xpoint   = sciences(i);
ypoint   = costs(i);
arch = good_pack_archs{i}.arch;

set(handles.selected_arch,'String',num2str(arch));
set(handles.selected_arch_science,'String',num2str(xpoint));
set(handles.selected_arch_cost,'String',num2str(ypoint));
RBES_Plot_Pack_arch(handles.axes3,arch,handles.params);

%% Buttons
function case_study_buttongroup_SelectionChangeFcn(hObject,eventdata)
handles = guidata(hObject); 
set_status(hObject,handles,'Busy');

switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
case 'EOS_case_study'
    RBES_Init_Params_EOS;

case 'Decadal_case_study'
    RBES_Init_Params_Decadal;
case 'Iridium_case_study'
    RBES_Init_Params_Iridium;
otherwise
    % do nothing
end
handles.params = params;
update_instruments(hObject,handles);
set_status(hObject,handles,'Ready');

% --- Executes on button press in update_db_plot.
function update_db_plot_Callback(hObject, eventdata, handles)
% hObject    handle to update_db_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set_status(hObject,handles,'Busy');

filename = get(handles.db_filename,'String');
load(filename);   
axes(handles.db_axes);
cla;
plot(sciences,costs,'bx','Parent',handles.db_axes,'ButtonDownFcn', {@test_plot,handles,good_sel_archs,sciences,costs});
grid on;
xlabel('science');
ylabel('cost');
hold on;
weight_cost = str2num(get(handles.weight_cost,'String'));
umin = min(utilities);
umax = max(utilities);
u1 = u_to_mag(1/4,umin,umax);
u2 = u_to_mag(1/2,umin,umax);
u3 = u_to_mag(3/4,umin,umax);

[x1,y1] = iso_utility_line(u1,weight_cost,min(sciences),max(sciences),min(costs),max(costs));
line(x1,y1,'LineStyle','--','Color',[1 0 0]);
[x2,y2] = iso_utility_line(u2,weight_cost,min(sciences),max(sciences),min(costs),max(costs));
line(x2,y2,'LineStyle','--','Color',[0 1 0]);
[x3,y3] = iso_utility_line(u3,weight_cost,min(sciences),max(sciences),min(costs),max(costs));
line(x3,y3,'LineStyle','--','Color',[0 0 1]);
l1 = ['u25=' num2str(1/100*round(100*u1))];
l2 = ['u50=' num2str(1/100*round(100*u2))];
l3 = ['u75=' num2str(1/100*round(100*u3))];

leg = legend('arch',l1,l2,l3);
set(leg,'Location','NorthWest');

set(handles.db_narcs,'String',num2str(length(sciences)));
set_status(hObject,handles,'Ready');

% --- Executes on button press in filter_db.
function filter_db_Callback(hObject, eventdata, handles)
% hObject    handle to filter_db (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in click_why_cost.
function click_why_cost_Callback(hObject, eventdata, handles)
% hObject    handle to click_why_cost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in click_why_science.
function click_why_science_Callback(hObject, eventdata, handles)
% hObject    handle to click_why_science (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rand_eval.
function rand_eval_Callback(hObject, eventdata, handles)
% hObject    handle to rand_eval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in rand_add.
function rand_add_Callback(hObject, eventdata, handles)
% hObject    handle to rand_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set_status(hObject,handles,'Busy');

science = str2num(get(handles.rand_science,'String'));
cost = str2num(get(handles.rand_cost,'String'));
arch = str2num(get(handles.rand_arch,'String'));

filename = get(handles.db_filename,'String');

if(exist(filename)>0)
    load(filename);
    narchs = length(good_sel_archs);
    good_sel_archs{narchs+1}.arch = arch;
    good_sel_archs{narchs+1}.science = science;
    good_sel_archs{narchs+1}.cost = cost;
    good_sel_archs{narchs+1}.list = handles.list_rand;
    sciences(narchs+1) = science;
    costs(narchs+1) = cost;

else
    good_sel_archs{1}.arch = arch;
    good_sel_archs{1}.science = science;
    good_sel_archs{1}.cost = cost;
    good_sel_archs{1}.list = handles.list_rand;
    sciences(1) = science;
    costs(1) = cost;
end

% recompute utilities
weight_cost = str2num(get(handles.weight_cost,'String'));
u_science = (sciences - min(sciences))./(max(sciences)- min(sciences));
au_cost = (costs - min(costs))./(max(costs)- min(costs));% negative utility
utilities = (u_science + weight_cost*(1-au_cost))/(1+weight_cost);
save(filename,'good_sel_archs','sciences','costs','utilities');
set_status(hObject,handles,'Ready');

% --- Executes on button press in search.
function search_Callback(hObject, eventdata, handles)
% hObject    handle to search (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in search_add.
function search_add_Callback(hObject, eventdata, handles)
% hObject    handle to search_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rand_why_cost.
function rand_why_cost_Callback(hObject, eventdata, handles)
% hObject    handle to rand_why_cost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rand_why_science.
function rand_why_science_Callback(hObject, eventdata, handles)
% hObject    handle to rand_why_science (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in run_ga.
function run_ga_Callback(hObject, eventdata, handles)
% hObject    handle to run_ga (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in load_rules.
function load_rules_Callback(hObject, eventdata, handles)
% hObject    handle to load_rules (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set_status(hObject,handles,'Busy');
params = handles.params;
[r,params] = RBES_Init_WithRules(params);
r.reset;
handles.r = r;
handles.params = params;
set(handles.rules_loaded,'String','Loaded');
set(handles.rules_loaded,'ForegroundColor',[0 1 0]);
set(handles.status,'BackgroundColor',[0 1 0]);
guidata(hObject, handles);
update_mem(hObject,handles);
save_facts_base('global_jess_engine.mat');
set_status(hObject,handles,'Ready');

% --- Executes on button press in man_plot.
function man_plot_Callback(hObject, eventdata, handles)
% hObject    handle to man_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in man_eval.
function man_eval_Callback(hObject, eventdata, handles)
% hObject    handle to man_eval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set_status(hObject,handles,'Busy');

arch = str2num(get(handles.man_arch,'String'));
RBES_Plot_Pack_arch(handles.man_axes,arch,handles.params);
archit.packaging = arch;
load_facts_base('global_jess_engine.mat');
r = global_jess_engine();
tic;
[science,total_cost] = SEL_evaluate_architecture2(handles.params,archit);
toc
list = explanation_facility();
clear r;
handles.list_man = list;
update_mem(hObject,handles);

set(handles.man_arch_science,'String',science);
set(handles.man_arch_cost,'String',total_cost);
set_status(hObject,handles,'Ready');

% --- Executes on button press in man_add.
function man_add_Callback(hObject, eventdata, handles)
% hObject    handle to man_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set_status(hObject,handles,'Busy');

science = str2num(get(handles.man_science,'String'));
cost = str2num(get(handles.man_cost,'String'));
arch = str2num(get(handles.man_arch,'String'));

filename = get(handles.db_filename,'String');

if(exist(filename)>0)
    load(filename);
    narchs = length(good_sel_archs);
    good_sel_archs{narchs+1}.arch = arch;
    good_sel_archs{narchs+1}.science = science;
    good_sel_archs{narchs+1}.cost = cost;
    good_sel_archs{narchs+1}.list = handles.list_man;
    sciences(narchs+1) = science;
    costs(narchs+1) = cost;

else
    good_sel_archs{1}.arch = arch;
    good_sel_archs{1}.science = science;
    good_sel_archs{1}.cost = cost;
    good_sel_archs{1}.list = handles.list_rand;
    sciences(1) = science;
    costs(1) = cost;
end

% recompute utilities
weight_cost = str2num(get(handles.weight_cost,'String'));
u_science = (sciences - min(sciences))./(max(sciences)- min(sciences));
au_cost = (costs - min(costs))./(max(costs)- min(costs));% negative utility
utilities = (u_science + weight_cost*(1-au_cost))/(1+weight_cost);
save(filename,'good_sel_archs','sciences','costs','utilities');
set_status(hObject,handles,'Ready');


% --- Executes on button press in man_why_cost.
function man_why_cost_Callback(hObject, eventdata, handles)
% hObject    handle to man_why_cost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in man_why_science.
function man_why_science_Callback(hObject, eventdata, handles)
% hObject    handle to man_why_science (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%% Unused
function status_Callback(hObject, eventdata, handles)
% hObject    handle to status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of status as text
%        str2double(get(hObject,'String')) returns contents of status as a double

% --- Executes during object creation, after setting all properties.
function status_CreateFcn(hObject, eventdata, handles)
% hObject    handle to status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function mem_Callback(hObject, eventdata, handles)
% hObject    handle to mem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mem as text
%        str2double(get(hObject,'String')) returns contents of mem as a double

% --- Executes during object creation, after setting all properties.
function mem_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in update_mem.
function update_mem_Callback(hObject, eventdata, handles)
% hObject    handle to update_mem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_mem(hObject,handles);

function click_arch_Callback(hObject, eventdata, handles)
% hObject    handle to click_arch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of click_arch as text
%        str2double(get(hObject,'String')) returns contents of click_arch as a double

% --- Executes during object creation, after setting all properties.
function click_arch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to click_arch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function click_cost_Callback(hObject, eventdata, handles)
% hObject    handle to click_cost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of click_cost as text
%        str2double(get(hObject,'String')) returns contents of click_cost as a double

% --- Executes during object creation, after setting all properties.
function click_cost_CreateFcn(hObject, eventdata, handles)
% hObject    handle to click_cost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function click_science_Callback(hObject, eventdata, handles)
% hObject    handle to click_science (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of click_science as text
%        str2double(get(hObject,'String')) returns contents of click_science as a double

% --- Executes during object creation, after setting all properties.
function click_science_CreateFcn(hObject, eventdata, handles)
% hObject    handle to click_science (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function db_filename_Callback(hObject, eventdata, handles)
% hObject    handle to db_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of db_filename as text
%        str2double(get(hObject,'String')) returns contents of db_filename as a double

% --- Executes during object creation, after setting all properties.
function db_filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to db_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function max_cost_Callback(hObject, eventdata, handles)
% hObject    handle to max_cost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max_cost as text
%        str2double(get(hObject,'String')) returns contents of max_cost as a double

% --- Executes during object creation, after setting all properties.
function max_cost_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_cost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function min_science_Callback(hObject, eventdata, handles)
% hObject    handle to min_science (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of min_science as text
%        str2double(get(hObject,'String')) returns contents of min_science as a double

% --- Executes during object creation, after setting all properties.
function min_science_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min_science (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pareto_membership_Callback(hObject, eventdata, handles)
% hObject    handle to pareto_membership (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pareto_membership as text
%        str2double(get(hObject,'String')) returns contents of pareto_membership as a double

% --- Executes during object creation, after setting all properties.
function pareto_membership_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pareto_membership (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function db_narcs_Callback(hObject, eventdata, handles)
% hObject    handle to db_narcs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of db_narcs as text
%        str2double(get(hObject,'String')) returns contents of db_narcs as a double

% --- Executes during object creation, after setting all properties.
function db_narcs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to db_narcs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function min_utility_Callback(hObject, eventdata, handles)
% hObject    handle to min_utility (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of min_utility as text
%        str2double(get(hObject,'String')) returns contents of min_utility as a double

% --- Executes during object creation, after setting all properties.
function min_utility_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min_utility (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function weight_cost_Callback(hObject, eventdata, handles)
% hObject    handle to weight_cost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of weight_cost as text
%        str2double(get(hObject,'String')) returns contents of weight_cost as a double

% --- Executes during object creation, after setting all properties.
function weight_cost_CreateFcn(hObject, eventdata, handles)
% hObject    handle to weight_cost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function rand_arch_Callback(hObject, eventdata, handles)
% hObject    handle to rand_arch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rand_arch as text
%        str2double(get(hObject,'String')) returns contents of rand_arch as a double

% --- Executes during object creation, after setting all properties.
function rand_arch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rand_arch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function rand_cost_Callback(hObject, eventdata, handles)
% hObject    handle to rand_cost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rand_cost as text
%        str2double(get(hObject,'String')) returns contents of rand_cost as a double

% --- Executes during object creation, after setting all properties.
function rand_cost_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rand_cost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function rand_science_Callback(hObject, eventdata, handles)
% hObject    handle to rand_science (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rand_science as text
%        str2double(get(hObject,'String')) returns contents of rand_science as a double

% --- Executes during object creation, after setting all properties.
function rand_science_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rand_science (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function max_ninstr_Callback(hObject, eventdata, handles)
% hObject    handle to max_ninstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max_ninstr as text
%        str2double(get(hObject,'String')) returns contents of max_ninstr as a double

% --- Executes during object creation, after setting all properties.
function max_ninstr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_ninstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function search_narcs_Callback(hObject, eventdata, handles)
% hObject    handle to search_narcs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of search_narcs as text
%        str2double(get(hObject,'String')) returns contents of search_narcs as a double

% --- Executes during object creation, after setting all properties.
function search_narcs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to search_narcs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function man_arch_Callback(hObject, eventdata, handles)
% hObject    handle to man_arch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of man_arch as text
%        str2double(get(hObject,'String')) returns contents of man_arch as a double

% --- Executes during object creation, after setting all properties.
function man_arch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to man_arch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function man_cost_Callback(hObject, eventdata, handles)
% hObject    handle to man_cost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of man_cost as text
%        str2double(get(hObject,'String')) returns contents of man_cost as a double

% --- Executes during object creation, after setting all properties.
function man_cost_CreateFcn(hObject, eventdata, handles)
% hObject    handle to man_cost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function man_science_Callback(hObject, eventdata, handles)
% hObject    handle to man_science (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of man_science as text
%        str2double(get(hObject,'String')) returns contents of man_science as a double

% --- Executes during object creation, after setting all properties.
function man_science_CreateFcn(hObject, eventdata, handles)
% hObject    handle to man_science (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% Instrument callbacks
% --- Executes on button press in I1.
function I1_Callback(hObject, eventdata, handles)
% hObject    handle to I1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of I1


% --- Executes on button press in I2.
function I2_Callback(hObject, eventdata, handles)
% hObject    handle to I2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of I2


% --- Executes on button press in I3.
function I3_Callback(hObject, eventdata, handles)
% hObject    handle to I3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of I3


% --- Executes on button press in I4.
function I4_Callback(hObject, eventdata, handles)
% hObject    handle to I4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of I4


% --- Executes on button press in I5.
function I5_Callback(hObject, eventdata, handles)
% hObject    handle to I5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of I5


% --- Executes on button press in I6.
function I6_Callback(hObject, eventdata, handles)
% hObject    handle to I6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of I6


% --- Executes on button press in I7.
function I7_Callback(hObject, eventdata, handles)
% hObject    handle to I7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of I7


% --- Executes on button press in I8.
function I8_Callback(hObject, eventdata, handles)
% hObject    handle to I8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of I8


% --- Executes on button press in I9.
function I9_Callback(hObject, eventdata, handles)
% hObject    handle to I9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of I9


% --- Executes on button press in I10.
function I10_Callback(hObject, eventdata, handles)
% hObject    handle to I10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of I10


% --- Executes on button press in I11.
function I11_Callback(hObject, eventdata, handles)
% hObject    handle to I11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of I11


% --- Executes on button press in I14.
function I14_Callback(hObject, eventdata, handles)
% hObject    handle to I14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of I14


% --- Executes on button press in I15.
function I15_Callback(hObject, eventdata, handles)
% hObject    handle to I15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of I15


% --- Executes on button press in I16.
function I16_Callback(hObject, eventdata, handles)
% hObject    handle to I16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of I16


% --- Executes on button press in I17.
function I17_Callback(hObject, eventdata, handles)
% hObject    handle to I17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of I17


% --- Executes on button press in I18.
function I18_Callback(hObject, eventdata, handles)
% hObject    handle to I18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of I18


% --- Executes on button press in I19.
function I19_Callback(hObject, eventdata, handles)
% hObject    handle to I19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of I19


% --- Executes on button press in I20.
function I20_Callback(hObject, eventdata, handles)
% hObject    handle to I20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of I20


% --- Executes on button press in I12.
function I12_Callback(hObject, eventdata, handles)
% hObject    handle to I12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of I12


% --- Executes on button press in I13.
function I13_Callback(hObject, eventdata, handles)
% hObject    handle to I13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of I13
