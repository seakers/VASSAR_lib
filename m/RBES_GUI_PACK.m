function varargout = RBES_GUI_PACK(varargin)
% RBES_GUI_PACK MATLAB code for RBES_GUI_PACK.fig
%      RBES_GUI_PACK, by itself, creates a new RBES_GUI_PACK or raises the existing
%      singleton*.
%
%      H = RBES_GUI_PACK returns the handle to a new RBES_GUI_PACK or the handle to
%      the existing singleton*.
%
%      RBES_GUI_PACK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RBES_GUI_PACK.M with the given input arguments.
%
%      RBES_GUI_PACK('Property','Value',...) creates a new RBES_GUI_PACK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RBES_GUI_PACK_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RBES_GUI_PACK_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RBES_GUI_PACK

% Last Modified by GUIDE v2.5 25-Sep-2011 18:32:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RBES_GUI_PACK_OpeningFcn, ...
                   'gui_OutputFcn',  @RBES_GUI_PACK_OutputFcn, ...
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


% --- Executes just before RBES_GUI_PACK is made visible.
function RBES_GUI_PACK_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RBES_GUI_PACK (see VARARGIN)

% Choose default command line output for RBES_GUI_PACK
handles.output = hObject;


% case_study_buttongroup_SelectionChangeFcn(hObject,eventdata);
% Update handles structure
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

% UIWAIT makes RBES_GUI_PACK wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RBES_GUI_PACK_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function manual_arch_Callback(hObject, eventdata, handles)
% hObject    handle to manual_arch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of manual_arch as text
%        str2double(get(hObject,'String')) returns contents of manual_arch as a double
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function manual_arch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to manual_arch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','gray');
end


% --- Executes on button press in plot_manual_arch.
function plot_manual_arch_Callback(hObject, eventdata, handles)
% hObject    handle to plot_manual_arch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
arch = str2num(get(handles.manual_arch,'String'));
RBES_Plot_Pack_arch(handles.axes1,arch,handles.params);
guidata(hObject, handles);


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

    
function update_instruments(hObject,handles)
for i = 1:length(handles.params.instrument_list)
    name = ['handles.I' num2str(i) '_name'];
    h = eval(name);
    set(h,'String',handles.params.instrument_list{i});
end
guidata(hObject, handles);


% --- Executes on button press in eval_man_arch.
function eval_man_arch_Callback(hObject, eventdata, handles)
% hObject    handle to eval_man_arch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set_status(hObject,handles,'Busy');

arch = str2num(get(handles.manual_arch,'String'));
RBES_Plot_Pack_arch(handles.axes1,arch,handles.params);
archit.packaging = arch;
load_facts_base('global_jess_engine.mat');
r = global_jess_engine();
tic;
[science,total_cost] = PACK_evaluate_architecture(r,handles.params,archit);
toc
list = explanation_facility();
clear r;
handles.list_man = list;
update_mem(hObject,handles);

set(handles.man_arch_science,'String',science);
set(handles.man_arch_cost,'String',total_cost);
set_status(hObject,handles,'Ready');


function update_mem(hObject,handles)
max = num2str(round(java.lang.Runtime.getRuntime.maxMemory/1024/1024));
tot = num2str(round(java.lang.Runtime.getRuntime.totalMemory/1024/1024));
free =num2str(round(java.lang.Runtime.getRuntime.freeMemory/1024/1024));
mem_str = ['max=' max ',tot=' tot ',free=' free];
set(handles.java_mem,'String',mem_str);
guidata(hObject, handles);

function man_arch_cost_Callback(hObject, eventdata, handles)
% hObject    handle to man_arch_cost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of man_arch_cost as text
%        str2double(get(hObject,'String')) returns contents of man_arch_cost as a double


% --- Executes during object creation, after setting all properties.
function man_arch_cost_CreateFcn(hObject, eventdata, handles)
% hObject    handle to man_arch_cost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','gray');
end



function man_arch_science_Callback(hObject, eventdata, handles)
% hObject    handle to man_arch_science (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of man_arch_science as text
%        str2double(get(hObject,'String')) returns contents of man_arch_science as a double


% --- Executes during object creation, after setting all properties.
function man_arch_science_CreateFcn(hObject, eventdata, handles)
% hObject    handle to man_arch_science (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','gray');
end


% --- Executes on button press in load_rules.
function load_rules_Callback(hObject, eventdata, handles)
% hObject    handle to load_rules (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set_status(hObject,handles,'Rules');

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
% save_facts_base('test_save_rbes.mat');
set_status(hObject,handles,'Ready');




function selected_arch_Callback(hObject, eventdata, handles)
% hObject    handle to selected_arch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of selected_arch as text
%        str2double(get(hObject,'String')) returns contents of selected_arch as a double


% --- Executes during object creation, after setting all properties.
function selected_arch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selected_arch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','gray');
end



function selected_arch_cost_Callback(hObject, eventdata, handles)
% hObject    handle to selected_arch_cost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of selected_arch_cost as text
%        str2double(get(hObject,'String')) returns contents of selected_arch_cost as a double


% --- Executes during object creation, after setting all properties.
function selected_arch_cost_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selected_arch_cost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','gray');
end



function selected_arch_science_Callback(hObject, eventdata, handles)
% hObject    handle to selected_arch_science (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of selected_arch_science as text
%        str2double(get(hObject,'String')) returns contents of selected_arch_science as a double


% --- Executes during object creation, after setting all properties.
function selected_arch_science_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selected_arch_science (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','gray');
end


% --- Executes on button press in eval_rand_arch.
function eval_rand_arch_Callback(hObject, eventdata, handles)
% hObject    handle to eval_rand_arch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set_status(hObject,handles,'Busy');
ni = length(handles.params.instrument_list);

max_nsats = str2double(get(handles.max_nsats,'String'));
tmp = ones(1,ni);
for n = 2:ni
        tmp(n) = 1+round(min(max(tmp),max_nsats-1)*rand);
end
arch = tmp;
set(handles.rand_arch,'String',num2str(arch));
guidata(hObject, handles);pause(0.33);
RBES_Plot_Pack_arch(handles.axes4,arch,handles.params);guidata(hObject, handles);pause(0.33);
archit.packaging = arch;
load_facts_base('global_jess_engine.mat');
r = global_jess_engine();
[science,total_cost] = PACK_evaluate_architecture(r,handles.params,archit);
list = explanation_facility();
clear r;
handles.list_rand = list;
RBES_Show_Penalties(handles.axes4,arch,handles.params);
update_mem(hObject,handles);
set(handles.rand_arch_science,'String',science);
set(handles.rand_arch_cost,'String',total_cost);
set_status(hObject,handles,'Ready');



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
    set(hObject,'BackgroundColor','gray');
end



function rand_arch_cost_Callback(hObject, eventdata, handles)
% hObject    handle to rand_arch_cost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rand_arch_cost as text
%        str2double(get(hObject,'String')) returns contents of rand_arch_cost as a double


% --- Executes during object creation, after setting all properties.
function rand_arch_cost_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rand_arch_cost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','gray');
end



function rand_arch_science_Callback(hObject, eventdata, handles)
% hObject    handle to rand_arch_science (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rand_arch_science as text
%        str2double(get(hObject,'String')) returns contents of rand_arch_science as a double


% --- Executes during object creation, after setting all properties.
function rand_arch_science_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rand_arch_science (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','gray');
end


% --- Executes on button press in update_good_archs.
function update_good_archs_Callback(hObject, eventdata, handles)
% hObject    handle to update_good_archs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set_status(hObject,handles,'Busy');

filename = get(handles.db_all_good_pack_archs,'String');
load(filename);   
axes(handles.axes2);
cla;
plot(sciences,costs,'bx','Parent',handles.axes2,'ButtonDownFcn', {@test_plot,handles,good_pack_archs,sciences,costs});
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

set(handles.num_archs_db,'String',num2str(length(sciences)));
set_status(hObject,handles,'Ready');


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

% --- Executes on button press in add_rand_arch.
function add_rand_arch_Callback(hObject, eventdata, handles)
% hObject    handle to add_rand_arch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set_status(hObject,handles,'Busy');

science = str2num(get(handles.rand_arch_science,'String'));
cost = str2num(get(handles.rand_arch_cost,'String'));
arch = str2num(get(handles.rand_arch,'String'));

filename = get(handles.db_all_good_pack_archs,'String');

if(exist(filename)>0)
    load(filename);
    narchs = length(good_pack_archs);
    good_pack_archs{narchs+1}.arch = arch;
    good_pack_archs{narchs+1}.science = science;
    good_pack_archs{narchs+1}.cost = cost;
    good_pack_archs{narchs+1}.list = handles.list_rand;
    sciences(narchs+1) = science;
    costs(narchs+1) = cost;

else
    good_pack_archs{1}.arch = arch;
    good_pack_archs{1}.science = science;
    good_pack_archs{1}.cost = cost;
    good_pack_archs{1}.list = handles.list_rand;
    sciences(1) = science;
    costs(1) = cost;
end

% recompute utilities
weight_cost = str2num(get(handles.weight_cost,'String'));
u_science = (sciences - min(sciences))./(max(sciences)- min(sciences));
au_cost = (costs - min(costs))./(max(costs)- min(costs));% negative utility
utilities = (u_science + weight_cost*(1-au_cost))/(1+weight_cost);
save(filename,'good_pack_archs','sciences','costs','utilities');
set_status(hObject,handles,'Ready');



% --- Executes on button press in add_man_arch.
function add_man_arch_Callback(hObject, eventdata, handles)
% hObject    handle to add_man_arch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set_status(hObject,handles,'Busy');

science = str2num(get(handles.man_arch_science,'String'));
cost = str2num(get(handles.man_arch_cost,'String'));
arch = str2num(get(handles.manual_arch,'String'));
filename = get(handles.db_all_good_pack_archs,'String');

if(exist(filename)>0)
    load(filename);
    narchs = length(good_pack_archs);
    good_pack_archs{narchs+1}.arch = arch;
    good_pack_archs{narchs+1}.science = science;
    good_pack_archs{narchs+1}.cost = cost;
    good_pack_archs{narchs+1}.list = handles.list_man;
    sciences(narchs+1) = science;
    costs(narchs+1) = cost;
else
    good_pack_archs{1}.arch = arch;
    good_pack_archs{1}.science = science;
    good_pack_archs{1}.cost = cost;
    good_pack_archs{1}.list = handles.list_man;
    sciences(1) = science;
    costs(1) = cost;
end
% recompute utilities
weight_cost = str2num(get(handles.weight_cost,'String'));
u_science = (sciences - min(sciences))./(max(sciences)- min(sciences));
au_cost = (costs - min(costs))./(max(costs)- min(costs));% negative utility
utilities = (u_science + weight_cost*(1-au_cost))/(1+weight_cost);
save(filename,'good_pack_archs','sciences','costs','utilities');

handles.NUM_archs{1} = arch;
handles.NUM_sciences(1) = science;
handles.NUM_costs(1) = cost;

set_status(hObject,handles,'Ready');



function db_all_good_pack_archs_Callback(hObject, eventdata, handles)
% hObject    handle to db_all_good_pack_archs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of db_all_good_pack_archs as text
%        str2double(get(hObject,'String')) returns contents of db_all_good_pack_archs as a double


% --- Executes during object creation, after setting all properties.
function db_all_good_pack_archs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to db_all_good_pack_archs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','gray');
end


% --- Executes on mouse press over axes background.
function axes2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




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
    set(hObject,'BackgroundColor','gray');
end



function java_mem_Callback(hObject, eventdata, handles)
% hObject    handle to java_mem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of java_mem as text
%        str2double(get(hObject,'String')) returns contents of java_mem as a double


% --- Executes during object creation, after setting all properties.
function java_mem_CreateFcn(hObject, eventdata, handles)
% hObject    handle to java_mem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','gray');
end



function max_nsats_Callback(hObject, eventdata, handles)
% hObject    handle to max_nsats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max_nsats as text
%        str2double(get(hObject,'String')) returns contents of max_nsats as a double


% --- Executes during object creation, after setting all properties.
function max_nsats_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_nsats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','gray');
end


% --- Executes on button press in random_search.
function random_search_Callback(hObject, eventdata, handles)
% hObject    handle to random_search (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set_status(hObject,handles,'Busy');

% clean matlab file
fid = fopen('control_matlab.txt','w');
fprintf(fid,'%% write stop on next line to stop matlab execution\n');
fclose(fid);
        
NUM = str2double(get(handles.num_archs,'String'));
NUM_sciences = zeros(1,NUM);
NUM_costs = zeros(1,NUM);
NUM_archs = cell(1,NUM);
for i = 1:NUM
    fprintf('%d of %d\n',i,NUM);
    ni = length(handles.params.instrument_list);
    set(handles.status,'BackgroundColor',[1 0 0]);
    set(handles.status,'String','Busy');guidata(hObject, handles);pause(0.33);
    max_nsats = str2double(get(handles.max_nsats,'String'));
    tmp = ones(1,ni);
    for n = 2:ni
            tmp(n) = 1+round(min(max(tmp),max_nsats-1)*rand);
    end
    NUM_archs{i} = tmp;
    set(handles.rand_arch,'String',num2str(tmp));
    guidata(hObject, handles);pause(0.33);
    RBES_Plot_Pack_arch(handles.axes4,tmp,handles.params);guidata(hObject, handles);pause(0.33);
    archit.packaging = tmp;
    load_facts_base('global_jess_engine.mat');
    r = global_jess_engine();
    [NUM_sciences(i),NUM_costs(i)] = PACK_evaluate_architecture(r,handles.params,archit);
    clear r;
    
    % Check if we have to stop
    fid = fopen('control_matlab.txt','r');
    s = fscanf(fid,'%s\n');
    fclose(fid);
    if strcmp(s(end-3:end),'stop')
        fprintf('Stopping after %d from %d iterations\n',i,NUM);
        NUM_sciences(i+1:end) = [];
        NUM_costs(i+1:end) = [];
        NUM_archs(i+1:end) = [];
        break;
    else
        if(mod(i,10)==0)
            t = clock();str = [date '-' num2str(t(4)) '-' num2str(t(5))];
            filename = ['intermediate_packaging_results-' str '.mat'];
            save(filename,'NUM_archs','NUM_sciences','NUM_costs');
        end
    end        
end
handles.NUM_sciences = NUM_sciences;
handles.NUM_costs = NUM_costs;
handles.NUM_archs = NUM_archs;

set_status(hObject,handles,'Ready');


% --- Executes on button press in add_many_rand_archs.
function add_many_rand_archs_Callback(hObject, eventdata, handles)
% hObject    handle to add_many_rand_archs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set_status(hObject,handles,'Busy');

science = handles.NUM_sciences;
cost = handles.NUM_costs;
arch = handles.NUM_archs;
filename = get(handles.db_all_good_pack_archs,'String');
% NUM = str2double(get(handles.num_archs,'String'));
NUM = length(handles.NUM_archs);
if(exist(filename)>0)
    load(filename);
    narchs = length(good_pack_archs);
    for j = 1:NUM
        good_pack_archs{narchs+j}.arch = arch{j};
        good_pack_archs{narchs+j}.science = science(j);
        good_pack_archs{narchs+j}.cost = cost(j);
%         good_pack_archs{narchs+j}.list = handles.list_man;
        sciences(narchs+j) = science(j);
        costs(narchs+j) = cost(j);
    end
else
    good_pack_archs{1}.arch = arch;
    good_pack_archs{1}.science = science;
    good_pack_archs{1}.cost = cost;
    good_pack_archs{1}.list = handles.list_man;
    sciences(1) = science;
    costs(1) = cost;
end
% recompute utilities
weight_cost = str2num(get(handles.weight_cost,'String'));
u_science = (sciences - min(sciences))./(max(sciences)- min(sciences));
au_cost = (costs - min(costs))./(max(costs)- min(costs));% negative utility
utilities = (u_science + weight_cost*(1-au_cost))/(1+weight_cost);
save(filename,'good_pack_archs','sciences','costs','utilities');

set_status(hObject,handles,'Ready');


% --- Executes on button press in why_cost_rand.
function why_cost_rand_Callback(hObject, eventdata, handles)
% hObject    handle to why_cost_rand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set_status(hObject,handles,'Busy');
arch = str2num(get(handles.rand_arch,'String'));
archit.packaging = arch;
handles.params.ESTIMATE_COST = 1;% we are only interested in science
handles.params.SCIENCE = 0;% we are only interested in science
handles.params.EXPLANATION = 0;% we want the explanations

load_facts_base('global_jess_engine.mat');
r = global_jess_engine();
[~,~,~] = PACK_evaluate_architecture(r,handles.params,archit);
RBES_Show_Penalties(handles.axes4,arch,handles.params);
clear r;
handles.params.ESTIMATE_COST = 1;%back to default
handles.params.SCIENCE = 1;% we are only interested in science
handles.params.EXPLANATION = 0;% back to default
set_status(hObject,handles,'Ready');

function [] = set_status(hObject,handles,st)
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


% --- Executes on button press in why_science_rand.
function why_science_rand_Callback(hObject, eventdata, handles)
% hObject    handle to why_science_rand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set_status(hObject,handles,'Busy');

arch = str2num(get(handles.rand_arch,'String'));
archit.packaging = arch;
handles.params.ESTIMATE_COST = 0;% we are only interested in science
handles.params.EXPLANATION = 1;% we want the explanations
handles.params.SCIENCE = 1;% we are only interested in science
load_facts_base('global_jess_engine.mat');
r = global_jess_engine();
[r,handles.params] = load_explanation_rules(r,handles.params);% load the explanation rules
[science,~,~] = PACK_evaluate_architecture(r,handles.params,archit);
list = explanation_facility();% get information
clear r;
show_explanations_in_excel(list);

handles.params.ESTIMATE_COST = 1;%back to default
handles.params.EXPLANATION = 0;% back to default
handles.params.SCIENCE = 1;% we are only interested in science

set_status(hObject,handles,'Ready');


% --- Executes on button press in why_cost_man.
function why_cost_man_Callback(hObject, eventdata, handles)
% hObject    handle to why_cost_man (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set_status(hObject,handles,'Busy');
arch = str2num(get(handles.manual_arch,'String'));
handles.params.ESTIMATE_COST = 1;% we are only interested in science
handles.params.SCIENCE = 0;% we are only interested in science
handles.params.EXPLANATION = 0;% we want the explanations
load_facts_base('global_jess_engine.mat');
r = global_jess_engine();
[~,~,~] = PACK_evaluate_architecture(r,handles.params,archit);
RBES_Show_Penalties(handles.axes1,arch,handles.params);
clear r;
handles.params.ESTIMATE_COST = 1;%back to default
handles.params.SCIENCE = 1;% we are only interested in science
handles.params.EXPLANATION = 0;% back to default
set_status(hObject,handles,'Ready');


% --- Executes on button press in why_science_man.
function why_science_man_Callback(hObject, eventdata, handles)
% hObject    handle to why_science_man (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set_status(hObject,handles,'Busy');

guidata(hObject, handles);pause(0.33);
arch = str2num(get(handles.manual_arch,'String'));
archit.packaging = arch;
handles.params.ESTIMATE_COST = 0;% we are only interested in science
handles.params.EXPLANATION = 1;% we want the explanations
load_facts_base('global_jess_engine.mat');
r = global_jess_engine();
[r,handles.params] = load_explanation_rules(r,handles.params);% load the explanation rules
[science,~,~] = PACK_evaluate_architecture(r,handles.params,archit);
list = explanation_facility();% get information
clear r;
show_explanations_in_excel(list);
handles.params.ESTIMATE_COST = 1;%back to default
handles.params.EXPLANATION = 0;% back to default
set_status(hObject,handles,'Ready');



% --- Executes on button press in filter_db.
function filter_db_Callback(hObject, eventdata, handles)
% hObject    handle to filter_db (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set_status(hObject,handles,'Busy');

    
filename = get(handles.db_all_good_pack_archs,'String');
load(filename);
backup = [filename '_backup'];
save(backup,'good_pack_archs','sciences','costs','utilities');
min_science = str2num(get(handles.min_science,'String'));
max_cost = str2num(get(handles.max_cost,'String'));
pareto_membership = str2num(get(handles.pareto_membership,'String'));
min_utility = str2num(get(handles.min_utility,'String'));
weight_cost = str2num(get(handles.weight_cost,'String'));

save_needed = false;
if(~isempty(min_science))
    % delete all archs from db with science less than min_science
    ind2remove = (sciences < min_science);
    sciences(ind2remove) = [];
    costs(ind2remove) = [];
    utilities(ind2remove) = [];
    good_pack_archs(ind2remove) = [];
    save_needed = true;
end
if(~isempty(max_cost))
    % delete all archs from db with cost greater than max_cost
    ind2remove = (costs > max_cost);
    sciences(ind2remove) = [];
    costs(ind2remove) = [];
    utilities(ind2remove) = [];
    good_pack_archs(ind2remove) = [];
    save_needed = true;
end
if(~isempty(min_utility))
    % delete all archs from db with utility less than min_utilities
    ind2remove = (utilities < min_utility);
    sciences(ind2remove) = [];
    utilities(ind2remove) = [];
    costs(ind2remove) = [];
    good_pack_archs(ind2remove) = [];
    save_needed = true;
end
if(~isempty(pareto_membership))
    % delete all archs from db with pareto membership less than
    % min_pareto_membership
    fuzzy_PF = FuzzyParetoFront([-sciences' costs'],pareto_membership);
    ind2remove = ~fuzzy_PF;
    sciences(ind2remove) = [];
    utilities(ind2remove) = [];
    costs(ind2remove) = [];
    good_pack_archs(ind2remove) = [];
    save_needed = true;
end


% remove duplicates
[myarchs,ind1,~] =unique(cellfun(@num2str,cellfun(@(x)getfield(x,'arch'),good_pack_archs,'UniformOutput',false),'UniformOutput',0));
sciences = sciences(ind1);
costs = costs(ind1);
utilities = utilities(ind1);
good_pack_archs = good_pack_archs(ind1);


% recompute utilities
u_science = (sciences - min(sciences))./(max(sciences)- min(sciences));
au_cost = (costs - min(costs))./(max(costs)- min(costs));% negative utility
utilities = (u_science + weight_cost*(1-au_cost))/(1+weight_cost);

% finish
set(handles.num_archs_db,'String',num2str(length(sciences)));
save(filename,'good_pack_archs','sciences','costs','utilities');

set_status(hObject,handles,'Ready');



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
    set(hObject,'BackgroundColor','gray');
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
    set(hObject,'BackgroundColor','gray');
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
    set(hObject,'BackgroundColor','gray');
end



function num_archs_db_Callback(hObject, eventdata, handles)
% hObject    handle to num_archs_db (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of num_archs_db as text
%        str2double(get(hObject,'String')) returns contents of num_archs_db as a double


% --- Executes during object creation, after setting all properties.
function num_archs_db_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_archs_db (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','gray');
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
    set(hObject,'BackgroundColor','gray');
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
    set(hObject,'BackgroundColor','gray');
end


% --- Executes on button press in update_status.
function update_status_Callback(hObject, eventdata, handles)
% hObject    handle to update_status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_mem(hObject,handles);


% --- Executes on button press in why_cost_click.
function why_cost_click_Callback(hObject, eventdata, handles)
% hObject    handle to why_cost_click (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set_status(hObject,handles,'Busy');

arch = str2num(get(handles.selected_arch,'String'));
archit.packaging = arch;

handles.params.ESTIMATE_COST = 1;% we are only interested in science
handles.params.SCIENCE = 0;% we are only interested in science
handles.params.EXPLANATION = 0;% we want the explanations
load_facts_base('global_jess_engine.mat');
r = global_jess_engine();
[~,~,~] = PACK_evaluate_architecture(r,handles.params,archit);
RBES_Show_Penalties(handles.axes3,arch,handles.params);
clear r;
handles.params.ESTIMATE_COST = 1;%back to default
handles.params.SCIENCE = 1;% we are only interested in science
handles.params.EXPLANATION = 0;% back to default

set_status(hObject,handles,'Ready');


% --- Executes on button press in why_science_click.
function why_science_click_Callback(hObject, eventdata, handles)
% hObject    handle to why_science_click (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.status,'BackgroundColor',[1 0 0]);
set(handles.status,'String','Busy');
guidata(hObject, handles);pause(0.33);
arch = str2num(get(handles.selected_arch,'String'));
archit.packaging = arch;
handles.params.ESTIMATE_COST = 0;% we are only interested in science
handles.params.EXPLANATION = 1;% we want the explanations
load_facts_base('global_jess_engine.mat');
r = global_jess_engine();
[r,handles.params] = load_explanation_rules(r,handles.params);% load the explanation rules
[science,~,~] = PACK_evaluate_architecture(r,handles.params,archit);
list = explanation_facility();% get information
clear r;
show_explanations_in_excel(list);
handles.params.ESTIMATE_COST = 1;%back to default
handles.params.EXPLANATION = 0;% back to default
set(handles.status,'BackgroundColor',[0 1 0]);
set(handles.status,'String','Ready');
guidata(hObject, handles);


function num_archs_Callback(hObject, eventdata, handles)
% hObject    handle to num_archs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of num_archs as text
%        str2double(get(hObject,'String')) returns contents of num_archs as a double


% --- Executes during object creation, after setting all properties.
function num_archs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_archs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','gray');
end


% --- Executes on button press in run_GA.
function run_GA_Callback(hObject, eventdata, handles)
% hObject    handle to run_GA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.status,'BackgroundColor',[1 0 0]);
set(handles.status,'String','Busy');guidata(hObject, handles);pause(0.33);

% clean matlab file
fid = fopen('control_matlab.txt','w');
fprintf(fid,'%% write stop on next line to stop matlab execution\n');
fclose(fid);

[x,fval,exitflag,output,population,score] = PACK_run_GA_multi(hObject);

% handles.NUM_archs = mat2cell(x,ones(1,size(x,1)),size(x,2));
set(handles.status,'BackgroundColor',[0 1 0]);
set(handles.status,'String','Ready');
guidata(hObject, handles);



function I19_name_Callback(hObject, eventdata, handles)
% hObject    handle to I19_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of I19_name as text
%        str2double(get(hObject,'String')) returns contents of I19_name as a double



function I18_name_Callback(hObject, eventdata, handles)
% hObject    handle to I18_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of I18_name as text
%        str2double(get(hObject,'String')) returns contents of I18_name as a double


% --- Executes during object creation, after setting all properties.
function I17_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to I17_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','gray');
end


% --- Executes during object creation, after setting all properties.
function I19_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to I19_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','gray');
end


% --- Executes during object creation, after setting all properties.
function I18_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to I18_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','gray');
end


% --- Executes during object creation, after setting all properties.
function I16_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to I16_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','gray');
end


% --- Executes during object creation, after setting all properties.
function I15_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to I15_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','gray');
end


% --- Executes during object creation, after setting all properties.
function I14_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to I14_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','gray');
end
