function varargout = Sensitivity(varargin)
% SENSITIVITY MATLAB code for Sensitivity.fig
%      SENSITIVITY, by itself, creates a new SENSITIVITY or raises the existing
%      singleton*.
%
%      H = SENSITIVITY returns the handle to a new SENSITIVITY or the handle to
%      the existing singleton*.
%
%      SENSITIVITY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SENSITIVITY.M with the given input arguments.
%
%      SENSITIVITY('Property','Value',...) creates a new SENSITIVITY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Sensitivity_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Sensitivity_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Sensitivity

% Last Modified by GUIDE v2.5 20-Oct-2014 23:43:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Sensitivity_OpeningFcn, ...
                   'gui_OutputFcn',  @Sensitivity_OutputFcn, ...
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


% --- Executes just before Sensitivity is made visible.
function Sensitivity_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Sensitivity (see VARARGIN)

% Choose default command line output for Sensitivity
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global edited_cap edited_wts params
[ninst,~] = params.instrument_list.size;
%resets the edits made to panel weights and/or instrument capabilities
edited_cap = zeros(1,ninst);
edited_wts = false;
set(hObject,'MenuBar','figure');
set(hObject,'Toolbar','figure');
set(handles.sensiTable,'CellEditCallback',{@cell_edited,handles})


% --- Outputs from this function are returned to the command line.
function varargout = Sensitivity_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in sensitivityCategory.
function sensitivityCategory_Callback(hObject, eventdata, handles)
% hObject    handle to sensitivityCategory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global params edited_wts sensitivity_wts

% updates table
selection = get(hObject,'Value');

if(selection==1)
    set(handles.sensiTable,'Data',{})
    set(handles.menuSubCategory,'Value',1,'Enable','off');
elseif(selection==2) %selected panels
    if edited_wts %if already edited, return edited weights
        set(handles.sensiTable,'Data',sensitivity_wts)
    else
        header = {'Panels','Weights'};
        header = strcat('<html><span style="color: #000000; font-weight: bold;">',header,'</span></html>');
        n = params.panel_names.size;
        nameAndWeights = cell(n,2);
        sum=0;
        for i=1:n
            nameAndWeights{i,1} = params.panel_names.get(i-1);
            nameAndWeights{i,2} = params.panel_weights.get(i-1);
            sum = sum + params.panel_weights.get(i-1);
        end
        total = {'Total',num2str(sum)};
        total = strcat('<html><span style="color: #000000; font-weight: bold;">',total,'</span></html>');
        set(handles.sensiTable,'Data',[header;nameAndWeights;total],'ColumnWidth',{150,150},'ColumnEditable',logical([0,1]));
        set(handles.menuSubCategory,'Enable','off');
    end
    set(handles.menuSubCategory,'Value',1,'Enable','off');
elseif(selection==3) %selected instrument capabilities
    %for dropdown menu for instrument selection
    inst={};
    for i=1:params.instrument_list.size
        inst = [inst,char(params.instrument_list(i))];
    end
    set(handles.menuSubCategory, 'String', inst );
    set(handles.textSubCategory,'String','Select Instrument');
    
    menuSubCategory_Callback(handles.menuSubCategory,eventdata,handles);
    
    set(handles.menuSubCategory,'Enable','on');
end

% --- Executes during object creation, after setting all properties.
function sensitivityCategory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sensitivityCategory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%list of categories that a user can study
set(hObject, 'String', {'','Panel Weights','Instrument Capabilities'} );

% --- Executes on selection change in menuSubCategory.
function menuSubCategory_Callback(hObject, eventdata, handles)
% hObject    handle to menuSubCategory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns menuSubCategory contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menuSubCategory
global edited_cap sensitivity_inst
inst_val = get(handles.menuSubCategory,'Value');

%if already edited, return edited data table
if edited_cap(inst_val)==1
    data = get(handles.sensiTable,'Data');
    attr = data(1,2:end);
    [a,b]=size(attr);
    set(handles.sensiTable,'Data',sensitivity_inst{inst_val})
else
    %make table with all measurements and attributes
    [meas,attr] = find_all_meas;
    meas = ['Measurements';meas];
    [a,b]=size(attr);
    [c,d]=size(meas);
    emptyCell = cell(c-1,b);
    set(handles.sensiTable,'Data',[meas,[attr;emptyCell]]);
end
%for formating table
colWidth =  num2cell([250,ones(1,b)*floor(800/(b+1))]);
editCol = logical([0,ones(1,b)]);
%format of columns. If no # assume type char
colFormat = cell(1,b+1);
colFormat{1} = 'char'; %for first col
for i=1:b
    if isempty(strfind(attr{i},'#'))
        colFormat{i+1}='char';
    else
        colFormat{i+1}='numeric';
    end
end
set(handles.sensiTable,'ColumnWidth',colWidth,...
    'ColumnEditable',editCol,'ColumnFormat',colFormat);

function [subObjMeas,attributes] = find_all_meas()
global params
subObjMeas = {};
attributes = {};
%iterate through all panels (eg WEA)
for i=0:params.subobjectives.size-1
    %iterate through all panel objectives (eg WEA1)
    for j=0:params.subobjectives.get(i).size-1
        %iterate through all subobjectives (eg WEA1-1)
        for k=0:params.subobjectives.get(i).get(j).size-1
            subObj=params.subobjectives.get(i).get(j).get(k);
            subObjMeas = [subObjMeas;params.subobjectives_to_measurements.get(subObj)];
            rule = params.requirement_rules.get(subObj);
            it = rule.keySet.iterator;
            while it.hasNext
                attributes=[attributes,it.next];
            end
        end
    end
end
subObjMeas = unique(subObjMeas);
attributes = unique(attributes);

% --- Executes during object creation, after setting all properties.
function menuSubCategory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menuSubCategory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in buttonMakeChange.
function buttonMakeChange_Callback(hObject, eventdata, handles)
% hObject    handle to buttonMakeChange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sensitivity_inst sensitivity_wts edited_cap edited_wts

%if panel weights is selected
if(get(handles.sensitivityCategory,'Value')==2)
    % check to see if total of panel weights == 1
    data = get(handles.sensiTable,'Data');
    total = sum([data{2:6,2}]);
    if abs(1-total) > 0.00001
        h = msgbox('Sum of the weights must equal 1');
    else
        sensitivity_wts=get(handles.sensiTable,'Data');
        edited_wts = true;
    end
%if instrument capabilities is selected
elseif(get(handles.sensitivityCategory,'Value')==3)
    inst = get(handles.menuSubCategory,'Value');
    sensitivity_inst{inst}=get(handles.sensiTable,'Data');
    edited_cap(get(handles.menuSubCategory,'Value'))=1;
end
set(handles.buttonMakeChange,'Enable','off');
set(handles.buttonSensiPlot,'Enable','on')

function cell_edited(hObject,eventdata,handles)
%keep track of weight total
if(get(handles.sensitivityCategory,'Value')==2)
    data = get(handles.sensiTable,'Data');
    total = sum([data{2:6,2}]);
    total_bold = strcat('<html><span style="color: #000000; font-weight: bold;">',num2str(total),'</span></html>');
    data{7,2}=total_bold;
    set(handles.sensiTable,'Data',data);
end
set(handles.buttonMakeChange,'Enable','on');

% --- Executes on button press in buttonSensiPlot.
function buttonSensiPlot_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSensiPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sensitivityCalculation(handles);
set(handles.printbutton,'Enable','on')
set(handles.buttonSensiPlot,'Enable','off');

% --- Executes on button press in printbutton.
function printbutton_Callback(hObject, eventdata, handles)
% hObject    handle to printbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global params marker_handles marker_closestArch_handle

try
    delete(marker_handles);
    delete(marker_closestArch_handle);
end

hfig = figure('visible', 'off');
hax_new = copyobj(handles.sensiAxes, hfig);
set(hax_new, 'Position', get(0, 'DefaultAxesPosition'),'units','normalized');
set(hax_new, 'Position', [1000 1000 700 500]);
set(hax_new, 'Position', get(0, 'DefaultAxesPosition'),'units','normalized'); 
%for some reason have to resize to some arbitrary position and then use the default
[FILENAME, PATHNAME, FILTERINDEX] = uiputfile({'*.png';'*.emf'},'Save as', 'rescoredArchs');
cd(PATHNAME);
if FILTERINDEX == 1
    print(hfig, '-dpng', FILENAME);
elseif FILTERINDEX == 2 
    print(hfig, '-dmeta', FILENAME);
end
cd(char(params.path));

% --- Executes on button press in archDetailsbutton.
function archDetailsbutton_Callback(hObject, eventdata, handles)
% hObject    handle to archDetailsbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stopWindowButtonMotion(handles)
ArchitectureWnd;

% --- Executes on button press in explainSatisfactionButton.
function explainSatisfactionButton_Callback(hObject, eventdata, handles)
% hObject    handle to explainSatisfactionButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global zeResult results2load
results2load = 1;
if isempty(zeResult.getExplanations)
    explain_arch_slow
end
stopWindowButtonMotion(handles)
ExplainSatisfaction

% --- Executes on button press in explainCostButton.
function explainCostButton_Callback(hObject, eventdata, handles)
% hObject    handle to explainCostButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global zeResult results2load
results2load = 1;
if isempty(zeResult.getExplanations)
    explain_arch_slow
end
stopWindowButtonMotion(handles)
ExplainCost

function stopWindowButtonMotion(handles)
set(handles.sensitivity_fig,'WindowButtonMotionFcn','');