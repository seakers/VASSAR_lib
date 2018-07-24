function varargout = EON_explanation_facility(varargin)
% EON_EXPLANATION_FACILITY MATLAB code for EON_explanation_facility.fig
%      EON_EXPLANATION_FACILITY, by itself, creates a new EON_EXPLANATION_FACILITY or raises the existing
%      singleton*.
%
%      H = EON_EXPLANATION_FACILITY returns the handle to a new EON_EXPLANATION_FACILITY or the handle to
%      the existing singleton*.
%
%      EON_EXPLANATION_FACILITY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EON_EXPLANATION_FACILITY.M with the given input arguments.
%
%      EON_EXPLANATION_FACILITY('Property','Value',...) creates a new EON_EXPLANATION_FACILITY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EON_explanation_facility_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EON_explanation_facility_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help EON_explanation_facility

% Last Modified by GUIDE v2.5 01-Sep-2014 17:32:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EON_explanation_facility_OpeningFcn, ...
                   'gui_OutputFcn',  @EON_explanation_facility_OutputFcn, ...
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


% --- Executes just before EON_explanation_facility is made visible.
function EON_explanation_facility_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EON_explanation_facility (see VARARGIN)

% Choose default command line output for EON_explanation_facility
    handles.output = hObject;
    
    % puts figure toolbar
    set(handles.EON_Main,'Toolbar','figure');

    global r;
    global results;
    global resMngr;
    global resCol;
    global zeArch;
    global hm;
    global AE;
    global params;
    global cores;
    
    cores = 1;

    r = jess.Rete;
    results = [];
    
    resMngr = [];
    resCol = [];
    zeArch = [];
    set(gcf,'MenuBar','figure');
    if ~exist('params','var') || isempty(params)
%         folder = 'C:\Users\DS925\Dropbox\Nozomi - Dani\RBES SMAP for IEEEAero14';
        folder =  'C:\Users\Nozomi\Dropbox\Nozomi - Dani\EON_PATH_orig';
%         folder = 'C:\Users\SEAK1\Dropbox\Nozomi - Dani\EON_PATH';
        params = rbsa.eoss.local.Params(folder,'FUZZY-ATTRIBUTES','test','normal','');%C:\\Users\\Ana-Dani\\Dropbox\\EOCubesats\\RBES_Cubesats7" OR C:\\Users\\dani\\My Documents\\My Dropbox\\EOCubesats\\RBES_Cubesats7
        AE = rbsa.eoss.ArchitectureEvaluator.getInstance;
        AE.init(cores);
    end
 
% Update handles structure
    guidata(hObject, handles);

% UIWAIT makes EON_explanation_facility wait for user response (see UIRESUME)
% uiwait(handles.EON_Main);


% --- Outputs from this function are returned to the command line.
function varargout = EON_explanation_facility_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in buttonUpdatePlot. UPDATE PLOT
function buttonUpdatePlot_Callback(hObject, eventdata, handles)
% hObject    handle to buttonUpdatePlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global archs;
global results;
global resCol;

archs = get_all_archs;

archs_str = cell(1, resCol.getResults.size);

% for i = 1:length(archs)-1
% %     archs_str{i} = archs{i}.getVariable('id');
%      archs_str{i} = ['Architecture ' num2str(archs{i}.getId)];
% end

update_buttons_status( handles, 'off' );

x_var = 'benefit';
y_var = 'life-cycle cost';

tmp =  get( handles.txtGroupFunction, 'String' );
grp_fcn = get( handles.txtGroupFunction, 'Value' );
grp_fcn = char(tmp(grp_fcn));
tmp = get( handles.comboParetoFront, 'String' );
pareto = get( handles.comboParetoFront, 'Value' );
pareto = tmp{pareto};
tmp2 = get( handles.fuzzy_crisp_scores, 'String' );
fuzzy = get( handles.fuzzy_crisp_scores, 'Value' );
fuzzy = tmp2{fuzzy};
if strcmp( pareto, 'Yes' )
    pareto = true;
else
    pareto = false;
end
if strcmp( fuzzy, 'Fuzzy' )
    fuzzy = true;
else
    fuzzy = false;
end
RBES_plot25( handles, handles.axes, archs, results, {x_var,y_var}, grp_fcn, pareto,fuzzy);

function RBES_plot25(handles,ax,archs,results, inaxis,filter_func,PARETO,FUZZY)
    global ref_arch ref_label resCol
    
    cla(ax);
    
    if FUZZY
        narch = length(archs);
        xvals = zeros(narch,1);
        yvals = zeros(narch,1);
        for i = 1:narch
            xvals(i) = results.get(i-1).getScience;
            yvals(i) = results.get(i-1).getCost;
        end
%         [x_pareto, y_pareto, inds, ~ ] = pareto_front([-xvals yvals] );
        i_pareto = paretofront([-xvals yvals]);
        x_vals2 = xvals(i_pareto);
        y_vals2 = yvals(i_pareto);
        [~, I] = sort(x_vals2);
%         set( handles.num_archs_pf,'String', num2str(length(inds)) );
%         plot( x_vals2(I) , y_vals2(I), 'r--','Parent',ax,'ButtonDownFcn',  {@axes_ButtonDownFcn,archs(inds),x_vals2(I),y_vals2(I),handles});
        narchfront = length(I);
        pareto_archs = archs(i_pareto);
        pareto_archs = pareto_archs (I);
        fuzzyxvals = cell(narchfront,1);
        fuzzyyvals = cell(narchfront,1);
        for i = 1:narchfront
            fuzzyxvals{i} = pareto_archs{i}.getResult.getFuzzy_science();
            fuzzyyvals{i} = pareto_archs{i}.getResult.getFuzzy_cost();
        end
        [~,meanx,meany] = plot_fuzzy_vars(fuzzyxvals,fuzzyyvals);
        xlim( [0 1] );
        ylim( [0 1.2*max(yvals)] );
        hold on;
        set(ax,'ButtonDownFcn','');
        plot( meanx, meany, 'r.','Parent',ax,'ButtonDownFcn',  {@axes_ButtonDownFcn_fuzzy,pareto_archs,meanx,meany,fuzzyxvals,fuzzyyvals,handles});
        set(handles.EON_Main,'WindowButtonMotionFcn',{@axes_WindowButtonMotionFcn,meanx,meany,handles});
        set(handles.axes,'ButtonDownFcn',{@axes_ButtonDownFcn_fuzzy,archs,meanx,meany,fuzzyxvals,fuzzyyvals,handles});
    else
    
        MARKERS = {'x','o','d','s','p','.',...
            'x','o','d','s','p','.',...
            'x','o','d','s','p','.',...
            'x','o','d','s','p','.',...
            'x','o','d','s','p','.'};
        
        COLORS = {'b','m','k','g','c','r',...
            'm','k','g','c','r','b',...
            'k','g','c','r','b','m',...
            'g','c','r','b','m','k',...
            'c','r','b','m','k','g'};
        narch = length(archs);
        xvals = zeros(narch,1);
        yvals = zeros(narch,1);
        for i = 1:1000
            
            xvals(i) = results.get(i-1).getScience;
            yvals(i) = results.get(i-1).getCost;
        end
        if isempty(filter_func) || strcmp(filter_func,'') || strcmp(filter_func,' ')
            labels = {'Pareto Front','Architectures'};
            vals = ones(narch,1);
        else
            eval(['[~,labels] = ' filter_func '(archs{1})']);
            if PARETO
                labels = ['Pareto front' labels];
            end
            vals = cellfun(str2func(filter_func),archs);
        end
        unique_vals = unique(vals);
        n = length(unique_vals);
        indexes = cell(n,1);
        markers = MARKERS(1:length(unique_vals));
        colors = COLORS(1:length(unique_vals));
        
        %plot reference architectures (search from back b/c ref archs inserted at back)
        ref_colors = {'b','r','c','g'};
        [a,b]=size(ref_arch);
        for i = 1:b
            for j = resCol.getResults.size-1:-1:0
                if resCol.getResults.get(j).getArch.getId==ref_arch{i}.getId
                    sci = resCol.getResults.get(j).getScience;
                    cost = resCol.getResults.get(j).getCost;
                    scatter(sci,cost,50,'Marker','h','MarkerEdgeColor',ref_colors{i},'LineWidth',2,...
                        'Parent',ax);
                    hold on
                    break;
                end
            end
        end
        legend(ref_label,'Location','Best');
        labels = [ref_label labels];
        
        if PARETO
            [x_pareto, y_pareto, inds, ~ ] = pareto_front([xvals yvals] , {'LIB', 'SIB'});
            plot( x_pareto, y_pareto, 'r--','Parent',ax,'ButtonDownFcn',  {@axes_ButtonDownFcn,archs(inds),x_pareto,y_pareto,handles});
        end
        for i = 1 : n
            indexes{i} = (vals == unique_vals(i));
            scatter(xvals(indexes{i}),yvals(indexes{i}),'Marker',markers{i},'MarkerEdgeColor',colors{i},...
                'Parent',ax,'ButtonDownFcn', {@axes_ButtonDownFcn,archs(indexes{i}),xvals(indexes{i}),yvals(indexes{i}),handles});
            xlim( [0 1] );
        end
        
        % set mouse moving and selection function
        set(handles.EON_Main,'WindowButtonMotionFcn',{@axes_WindowButtonMotionFcn,xvals,yvals,handles});
        set(handles.axes,'ButtonDownFcn',{@axes_ButtonDownFcn,archs,xvals,yvals,handles});
        
        grid on;
        xlabel(inaxis{1});
        ylabel(inaxis{2});
        legend(labels,'Location','Best');
    end

function axes_WindowButtonMotionFcn(src,event,x,y,handles)
global marker_closestArch_handle
cp = get(handles.axes,'CurrentPoint');
xmouse = cp(1,1);
ymouse = cp(1,2);
[~,ind] = min( abs((x - xmouse)/(max(x)-min(x))).^2+abs((y - ymouse)/(max(y)-min(y))).^2 );
try
    delete(marker_closestArch_handle);
end
marker_closestArch_handle = plot(x(ind),y(ind),'bs','LineWidth', 1, 'MarkerSize', 10 );

function axes_ButtonDownFcn(src,eventdata,archs,x,y,handles)

global architecture zeResult zeArch marker_handles compare_marker_handles

if isempty(get(handles.EON_Main,'WindowButtonMotionFcn'));
     set(handles.EON_Main,'WindowButtonMotionFcn',{@axes_WindowButtonMotionFcn,x,y,handles});
end

% Find the closest point arch to the mouse click
mouse = get( handles.axes, 'CurrentPoint' );
xmouse = mouse(1,1);
ymouse = mouse(1,2);
[~,ind] = min( abs((x - xmouse)/(max(x)-min(x))).^2+abs((y - ymouse)/(max(y)-min(y))).^2 );

% Set the architecture for analysis
update_buttons_status( handles, 'off' );
architecture = [];
zeArch = archs{ind};
zeResult = zeArch.getResult;

%create_element_hierarchy;
update_buttons_status( handles, 'on' );


%Highlighting the selected points
%if in comparision mode
if get(handles.comp_mode,'Value')==1
    if strcmp(get(handles.arch1,'String'),'Architecture 1')
        try
            delete(marker_handles);
        end
        marker_handles = plot(x(ind),y(ind),'gs','LineWidth', 3, 'MarkerSize', 10 );
        compare_marker_handles = plot(x(ind),y(ind),'kd','LineWidth', 3, 'MarkerSize', 10 );
    else
        try
            delete(marker_handles);
        end
        marker_handles = plot(x(ind),y(ind),'gs','LineWidth', 3, 'MarkerSize', 10 );
    end
    enter_compare_mode(handles);
    enter_compare_mode(handles);
else %if not in compare mode
    try
        delete(marker_handles);
        delete(compare_marker_handles);
    end
    marker_handles = plot(x(ind),y(ind),'gs','LineWidth', 3, 'MarkerSize', 10 );
end

function axes_ButtonDownFcn_fuzzy(src,eventdata,archs,x,y,fzx,fzy,handles)

global architecture;
global zeResult;
global zeArch;
global marker_handles;

% Find the closest point arch to the mouse click
mouse = get( handles.axes, 'CurrentPoint' );
xmouse = mouse(1,1);
ymouse = mouse(1,2);
[~,ind] = min( abs((x - xmouse)/(max(x)-min(x))).^2+abs((y - ymouse)/(max(y)-min(y))).^2 );

% Set the architecture for analysis
update_buttons_status( handles, 'off' );
architecture = [];
zeArch = archs{ind};
zeResult = zeArch.getResult;

%create_element_hierarchy;
try
    for i = 1:length(marker_handles)
        delete(marker_handles{i});
    end
end
marker_handles = {};
marker_handles{1} = plot(x(ind),y(ind),'ms', 'MarkerSize', 10 );
fx = fzx{ind}.getNum_val;
errxD = fzx{ind}.getInterv.getMin;
errxU = fzx{ind}.getInterv.getMax;
fy= fzy{ind}.getNum_val;
erryD = fzy{ind}.getInterv.getMin;
erryU = fzy{ind}.getInterv.getMax;
h=ploterr(fx,fy,{errxD,errxU},{erryD,erryU},'g.');
set(h(2),'Color','g'), set(h(3),'Color','g'), set(h(1),'MarkerSize',15), set(h(1),'MarkerFaceColor','g');
marker_handles{2} = h;
update_buttons_status( handles, 'on' );


% --- Executes on button press in buttonPrintPlot. PRINT PLOT
function buttonPrintPlot_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPrintPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global marker_handles compare_marker_handles marker_closestArch_handle params

try
    delete(marker_handles);
    delete(compare_marker_handles);
    delete(marker_closestArch_handle);
end

tmp =  get( handles.txtGroupFunction, 'String' );
grp_fcn = get( handles.txtGroupFunction, 'Value' );
grp_fcn = char(tmp(grp_fcn));
if isempty(grp_fcn);
    grp_fcn = 'baseline';
end

hfig = figure('visible', 'off');
hax_new = copyobj(handles.axes, hfig);

set(hax_new, 'Position', get(0, 'DefaultAxesPosition'),'units','normalized');
set(hax_new, 'Position', [1000 1000 700 500]);
set(hax_new, 'Position', get(0, 'DefaultAxesPosition'),'units','normalized'); 
%for some reason have to resize to some arbitrary position and then use the default
[FILENAME, PATHNAME, FILTERINDEX] = uiputfile({'*.png';'*.emf'},'Save as', grp_fcn);
cd(PATHNAME);
if FILTERINDEX == 1
    print(hfig, '-dpng', FILENAME);
elseif FILTERINDEX == 2 
    print(hfig, '-dmeta', FILENAME);
end
cd(char(params.path));

% --- Executes on selection change in comboxVar.
function comboxVar_Callback(hObject, eventdata, handles)
% hObject    handle to comboxVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns comboxVar contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comboxVar

% --- Executes during object creation, after setting all properties.
function comboxVar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comboxVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in comboyVar.
function comboyVar_Callback(hObject, eventdata, handles)
% hObject    handle to comboyVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns comboyVar contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comboyVar


% --- Executes during object creation, after setting all properties.
function comboyVar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comboyVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in comboParetoFront.
function comboParetoFront_Callback(hObject, eventdata, handles)
% hObject    handle to comboParetoFront (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns comboParetoFront contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comboParetoFront

% --- Executes during object creation, after setting all properties.
function comboParetoFront_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comboParetoFront (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function txtGroupFunction_Callback(hObject, eventdata, handles)
% hObject    handle to txtGroupFunction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtGroupFunction as text
%        str2double(get(hObject,'String')) returns contents of txtGroupFunction as a double


% --- Executes during object creation, after setting all properties.
function txtGroupFunction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtGroupFunction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%list of filter names
set(hObject, 'String', [{'','has_GEO_filter','has_ATMS_filter','num_orbits_filter',...
    'num_sats_filter','num_sats_per_orbit_filter','in_ISS_orbit_filter'}] );


% --- Executes on button press in buttonArchitecture.
function buttonArchitecture_Callback(hObject, eventdata, handles)
% hObject    handle to buttonArchitecture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stopWindowButtonMotion(handles)
ArchitectureWnd;

% --- Executes on button press in buttonSatisfaction.
function buttonSatisfaction_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSatisfaction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global zeResult results2load
results2load = 1;
if isempty(zeResult.getExplanations)
    explain_arch_slow
end
stopWindowButtonMotion(handles)
ExplainSatisfaction

% --- Executes on button press in buttonCost.
function buttonCost_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global zeResult results2load
results2load = 1;
if isempty(zeResult.getExplanations)
    explain_arch_slow
end
stopWindowButtonMotion(handles)
ExplainCost

% --- Executes on button press in buttonSCDesign.
function buttonSCDesign_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSCDesign (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stopWindowButtonMotion(handles)
ExplainSCDesign

% % --- Executes on selection change in comboSelectArch.
% function popupmenu1_Callback(hObject, eventdata, handles)
% % hObject    handle to comboSelectArch (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: contents = cellstr(get(hObject,'String')) returns comboSelectArch contents as cell array
% %        contents{get(hObject,'Value')} returns selected item from comboSelectArch

function comboSelectArch_Callback(hObject, eventdata, handles)
% hObject    handle to comboSelectArch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns comboSelectArch contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comboSelectArch

global results;
global archs;
global zeArch;

selArch = get( handles.comboSelectArch, 'Value' );
results = archs{selArch}.getResult;
zeArch = archs{selArch};

%create_element_hierarchy;
update_buttons_status( handles, 'on' );



function update_buttons_status( handles, status )

set( handles.buttonArchitecture, 'Enable', status );
% set( handles.buttonFacts, 'Enable', status );
set( handles.buttonSatisfaction, 'Enable', status );
set( handles.buttonCost, 'Enable', status );
% set( handles.buttonSchedule, 'Enable', status );
set( handles.buttonSCDesign, 'Enable', status );
%set( handles.buttonWindows, 'Enable', status );
set( handles.buttonEvalArch, 'Enable', status );
set( handles.buttonEvaluateNewArchitecture, 'Enable', status );
set(handles.buttonSensitivity,'Enable',status);

if strcmp('on',status)
    set(handles.comp_mode,'Enable','on');
else
    set(handles.comp_mode,'Enable',status);
end



% --- Executes during object creation, after setting all properties.
function comboSelectArch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comboSelectArch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonEvalArch.
function buttonEvalArch_Callback(hObject, eventdata, handles)
% hObject    handle to buttonEvalArch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global zeArch;
global resCol;
global zeResult;
global results;
global AE
fprintf('evaluating Architecture\n');
% zeArch = archs{get(handles.comboSelectArch, 'Value')};
zeArch.setEval_mode('DEBUG');
res = AE.evaluateArchitecture(zeArch,'Fast');
for i = 0:resCol.getResults.size-1
    if strcmp( resCol.getResults.get(i).getArch.getId, zeArch.getId )
        resCol.results{i} = res;
    end
end
zeResult = res;
results = res;

% --- Executes on button press in buttonEvaluateNewArchitecture.
function buttonEvaluateNewArchitecture_Callback(hObject, eventdata, handles)
% hObject    handle to buttonEvaluateNewArchitecture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stopWindowButtonMotion(handles)
NewArchitectureWnd;

% --- Executes on button press in pushbutton1. LOAD FILE
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global results;
global archs;
global resMngr;
global resCol;
global ref_arch ref_label

%clearvars -global results architecture resCol x y

[FileName,PathName,FilterIndex] = uigetfile( './*.rs*' );

resMngr = rbsa.eoss.ResultManager.getInstance();
resCol = resMngr.loadResultCollectionFromFile( [PathName FileName] );

%load in the reference files and push results in resCol
[ref_arch,ref_label]=setReferenceArchs();

results = resCol.getResults;


set( handles.txtFilePath, 'String', char(resCol.getFilePath) );
set( handles.txtInputFile, 'String', FileName );
set( handles.txtTimeStamp, 'String', char(resCol.getStamp) );

archs = get_all_archs;
% metrics_labels = {'Benefit','Lifecyle cost'};
% metrics = {'benefit','lifecycle-cost'};
% hm = java.util.HashMap;
% for i = 1:length(metrics)
%     hm.put(metrics_labels{i},metrics{i});
% end
% % Check is a metric has been computed
% if ~isempty(archs{i}.getOtherData)
%     for i = 1:length(metrics)
%         if archs{i}.getOtherData.keySet.contains(metrics{i}) == 1
%             metrics(i) = [];
%         end
%     end
% end
archs_str = cell(1, resCol.getResults.size);
for i = 1:length(archs)
%     archs_str{i} = archs{i}.getVariable('id');
%     archs_str{i} = ['Architecture ' num2str(i)]
%     archs_str{i} = ['Architecture ' num2str(archs{i}.getId)];
end

% Set tehe combobox     to select architectures
update_buttons_status( handles, 'off' );
% results = [];

% Set the combobox for the x-axis
% set( handles.comboxVar, 'String', [{'benefit'} metrics_labels] );
set( handles.comboxVar, 'String', [{'benefit','lifecycle-cost'}] );

% Set the combobox for the y-axis
% set( handles.comboyVar, 'String', [{'lifecycle-cost'} metrics_labels] );
set( handles.comboyVar, 'String', [{'lifecycle-cost','benefit'}] );
% Set the combobox for pareto front
set( handles.comboParetoFront, 'String', {'Yes','No'} );
% Set the combobox for crisp or fuzzy values
set( handles.fuzzy_crisp_scores, 'String', {'Crisp','Fuzzy'} );
% Compute extra information needed
%compute_other_metrics(metrics);

   


function txtFilePath_Callback(hObject, eventdata, handles)
% hObject    handle to txtFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtFilePath as text
%        str2double(get(hObject,'String')) returns contents of txtFilePath as a double


% --- Executes during object creation, after setting all properties.
function txtFilePath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtInputFile_Callback(hObject, eventdata, handles)
% hObject    handle to txtInputFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtInputFile as text
%        str2double(get(hObject,'String')) returns contents of txtInputFile as a double


% --- Executes during object creation, after setting all properties.
function txtInputFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtInputFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtTimeStamp_Callback(hObject, eventdata, handles)
% hObject    handle to txtTimeStamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtTimeStamp as text
%        str2double(get(hObject,'String')) returns contents of txtTimeStamp as a double


% --- Executes during object creation, after setting all properties.
function txtTimeStamp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtTimeStamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonSaveRC.
function buttonSaveRC_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSaveRC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global resMngr resCol params
dt = datestr(now,'yyyy-mm-dd_HH-MM-SS');
path = strcat(char(params.path),'\results\',dt,'_test.rs');
resCol.setFilePath(path);
resMngr.saveResultCollection(resCol);

% --- Executes on button press in comp_arch.
function comp_arch_Callback(hObject, eventdata, handles)
% hObject    handle to comp_arch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global compArch1 compResult1 compArch2 compResult2 zeArch zeResult results2load

results2load = 2;
if isempty(compResult1.getExplanations)
    zeArch = compArch1;
    zeResult = compResult1;
    explain_arch_slow
    compResult1 = zeResult;
end
results2load = 1;
if isempty(compResult2.getExplanations)
    zeArch = compArch2;
    zeResult = compResult2;
    explain_arch_slow
    compResult2 = zeResult;
end
stopWindowButtonMotion(handles)
CompareSatisfaction;


% --- Executes on button press in comp_mode.
function comp_mode_Callback(hObject, eventdata, handles)
% hObject    handle to comp_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of comp_mode
global compare_marker_handles
arch1 = 'Architecture 1';
arch2 = 'Architecture 2';

%reset fields when inactivated
if get(hObject,'Value')==0
    set(handles.arch1,'String',arch1);
    set(handles.arch2,'String',arch2);
    set(handles.comp_arch,'Enable','off');
    try
        delete(compare_marker_handles);
    end
end


function bool = enter_compare_mode(handles)
%fills in Architecture 1 and Architecture 2 fields in order to compare
global zeArch zeResult compArch1 compResult1 compArch2 compResult2
if strcmp(get(handles.arch1,'String'),'Architecture 1');
    compArch1 = zeArch;
    compResult1 = zeResult;
    set(handles.arch1,'String',char(zeArch.getKey));
    bool = 0;
    set(handles.comp_arch,'Enable','off');
else strcmp(get(handles.arch2,'String'),'Architecture 2');
    compArch2 = zeArch;
    compResult2 = zeResult;
    set(handles.arch2,'String',char(zeArch.getKey));
    bool = 0;
    set(handles.comp_arch,'Enable','on');
end


% --- Executes on button press in buttonSensitivity.
function buttonSensitivity_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSensitivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stopWindowButtonMotion(handles)
Sensitivity;

function stopWindowButtonMotion(handles)
set(handles.EON_Main,'WindowButtonMotionFcn','');


% --- Executes on selection change in fuzzy_crisp_scores.
function fuzzy_crisp_scores_Callback(hObject, eventdata, handles)
% hObject    handle to fuzzy_crisp_scores (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fuzzy_crisp_scores contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fuzzy_crisp_scores


% --- Executes during object creation, after setting all properties.
function fuzzy_crisp_scores_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fuzzy_crisp_scores (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
