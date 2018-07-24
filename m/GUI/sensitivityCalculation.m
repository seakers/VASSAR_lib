function sensitivityCalculation(handles)
global AE params archs resCol zeArch zeResult results2load edited_cap

update_buttons_status(handles,'off')

panelWeights = params.panel_weights;

archs2rescore = zeros(1,resCol.getResults.size);
archs2load = java.util.ArrayList;
%find all results that need to be rescored
results = resCol.getResults;
for i=0:results.size-1
    res = results.get(i);
    if(isempty(res.getExplanations))
        load = 0;
        j=1;
        while load==0 || j==length(edited_cap)
            if edited_cap(j)==1;
                inst = char(params.instrument_list(j));
                if res.getArch.containsInst(inst)
                    archs2rescore(i+1) = 1;
                    archs2load.add(res.getArch);
                    load = 1;
                end
            end
            j=j+1;
        end
    end
end
results2load = sum(archs2rescore);

%remove the unloaded results from resCol so that AE can evaluate them
%with a parallel process. only loads the affected architectures that
%haven't been previously loaded
for i=length(archs2rescore):-1:1
    if archs2rescore(i) == 1
        results.remove(i-1);
    end
end

h = msgbox(strcat('Loading  ',num2str(results2load),' archs'));
AE.clearResults;
AE.setPopulation(archs2load);
AE.evaluatePopulationSlow;
loadedResults = AE.getResults;
results.addAll(loadedResults);
close(h);

[sorted_subobj,index_for_sorting] = alphabetically_sort_subobj;
h = msgbox(strcat('Computing new scores...'));
[rescoredCol]=sensitivity_for_modified_instruments(sorted_subobj,index_for_sorting);
close(h)
filter_func='';
inaxis = {'benefit','lifecycle-cost'};

RBES_plot25(handles,handles.sensiAxes,archs,rescoredCol.getResults,inaxis,filter_func,true,rescoredCol);

function [rescoredCol]=sensitivity_for_modified_instruments(sorted_subobj,index_for_sorting)
global params resCol sensitivity_inst edited_cap edited_wts sensitivity_wts

% matlabpool('open','local');

%create local variables from global ones
local_edited_cap = edited_cap;
local_edited_wts = edited_wts;
local_sensitivity_wts = sensitivity_wts;
ninstr = params.ninstr; 
instrument_list = params.instrument_list;
objWeights = params.obj_weights;
subobjWeights = params.subobj_weights;
subobjectives = params.subobjectives;
panelNames = params.panel_names;
panelWts = params.panel_weights;
%look through each result
resultStack = resCol.getResults;
results = cell(resultStack.size,1);
archs = cell(resultStack.size,1);
res_subObjScore = cell(resultStack.size,1);
rescoredSci = cell(resultStack.size,1);
for i=0:resultStack.size-1
    results{i+1} = resultStack.get(i);
    archs{i+1} = resultStack.get(i).getArch;
    res_subObjScore{i+1} = resultStack.get(i).getSubobjective_scores;
end

% try
    for i=1:length(results)
        res = results{i};
        subObjScore = res_subObjScore{i};
        %copy subObjScore
        new_subObjScore = java.util.ArrayList;
        for n=0:subObjScore.size-1
            new_subObjScore.add(n,subObjScore.get(n));
        end
        
        score_changed = isScoreAffected(archs{i},ninstr,instrument_list,local_edited_cap,sensitivity_inst,index_for_sorting,new_subObjScore);
        
        if score_changed
            %recompute total science score
            [science,panel_scores] = recompute_science(objWeights,subobjWeights,subobjectives,panelNames,panelWts,local_edited_wts,local_sensitivity_wts,new_subObjScore,index_for_sorting,sorted_subobj);
            rescoredSci{i} = science;
        elseif local_edited_wts
            [science,panel_scores] = recompute_science(objWeights,subobjWeights,subobjectives,panelNames,panelWts,local_edited_wts,local_sensitivity_wts,new_subObjScore,index_for_sorting,sorted_subobj);
            rescoredSci{i} = science;
        else
            rescoredSci{i} = res.getScience; %if no change the original result
        end
    end
% catch
%     matlabpool('close');
%     msgID = 'MYFUN:BadIndex';
%     msg = 'Something went wrong in parfor loop during rescoring';
%     baseException = MException(msgID,msg);
%     throw(baseException)
% end

rescoredCol = rbsa.eoss.ResultCollection;
for i=1:resultStack.size
    res = results{i};
    if ~isempty(rescoredSci{i})
        rescoredCol.pushResult(rbsa.eoss.Result(res.getArch,rescoredSci{i},res.getCost));        
    else
        %if no change, just push original result
        rescoredCol.pushResult(res);
    end
end

function changed = isScoreAffected(arch,ninstr,instr_list,editedCap,sensiInstr,index_for_sorting,new_subObjScore)
global params

changed = false;
%find result's payload
payload = zeros(1,length(editedCap));
for j=1:ninstr
    inst = char(instr_list(j));
    if editedCap(j)==1
        if arch.containsInst(inst);
            payload(j)=1;
        end
    end
end

%cycle through payload
for j=1:ninstr
    if payload(j)==1
        edited_attr = sensiInstr{j};
        [a,b]=size(edited_attr);
        %cycle through cells to find which attributes were edited
        for r=2:a
            for c = 2:b
                if ~isempty(edited_attr{r,c})
                    [subobjs,subobj_ind] = find_subobj_with_meas(edited_attr{r,1});
                    %iterate through relevant subobjs
                    for k = 1:length(subobjs)
                        meas_rule = params.requirement_rules.get(subobjs{k}).get(edited_attr{1,c});
                        %check to see if attribute is relevant to
                        %measurement
                        if ~isempty(meas_rule)
                            type = meas_rule.get(0);
                            thresholds = meas_rule.get(1);
                            scores = meas_rule.get(2);
                            new_meas_score = compute_score(edited_attr{r,c},thresholds,scores,type);
                            subobj_num = index_for_sorting(subobj_ind(1));
%                             [ret1,~] = capa_vs_req_for_sensitivity(res,subobjs{k},edited_attr{1,c},edited_attr{r,c},AE,params);
                            new_subObjScore.set(subobj_num-1,new_meas_score);
                            changed = true;
                        end
                    end
                end
            end
        end
    end
end

function [subobjs,index] = find_subobj_with_meas(measurement)
%reutrns the subobjectives that have desired measurement. index is the
%index of the returnd subobjectives with respect to the
%params.subobjectives list.
global params
subobjs={};
index=[];
counter=1;
%iterate through all panels (eg WEA)
for i=0:params.subobjectives.size-1
    %iterate through all panel objectives (eg WEA1)
    for j=0:params.subobjectives.get(i).size-1
        %iterate through all subobjectives (eg WEA1-1)
        for k=0:params.subobjectives.get(i).get(j).size-1
            subObj=params.subobjectives.get(i).get(j).get(k);
            meas = params.subobjectives_to_measurements.get(subObj);
            if strcmp(char(meas),measurement);
                subobjs = [subobjs; subObj];
                index = [index;counter];
            end
            counter = counter+1;
        end
    end
end

function [sorted_subobj,index_for_sorting] = alphabetically_sort_subobj()
%need to sort alphabetically because results.getSubobjective_scores is in
%alphabetical order
global params
subobjs = {};
panel_iter = params.subobjectives.iterator;
while panel_iter.hasNext
    obj_iter = panel_iter.next.iterator;
    while obj_iter.hasNext
        subobj_iter = obj_iter.next.iterator;
        while subobj_iter.hasNext
            subobjs = [subobjs;char(subobj_iter.next)];
        end
    end    
end
sorted_subobj = sort(subobjs);
%doing DIY index because index for sort() function wasn't correct
index_for_sorting = zeros(length(sorted_subobj),1);
for i = 1:length(sorted_subobj)
     index_for_sorting(i) = find(strncmp(sorted_subobj,subobjs{i},length(subobjs{i})));
end

function [science,panel_scores] = recompute_science(objWeights,subobjWeights,subobjectives,panelNames,panelWts,local_edited_wts,local_sensitivity_wts,res_subObjScore,index_for_sorting,sorted_subobj)

panel_scores = zeros(1,panelNames.size);

if local_edited_wts
    panelWeights = java.util.ArrayList;
    npanels = panelNames.size;
    for i=1:npanels
        panelWeights.add(i-1,local_sensitivity_wts{i+1,2});
    end
else
    panelWeights = panelWts;
end

counter = 1;
science = 0;
%iterate over panels
for i = 0:panelWeights.size-1
    panel_weight = panelWeights.get(i);
    panel = subobjectives.get(i);
    panel_scores(1,i+1) = 0;
    %iterate over objectives
    for j = 0:panel.size-1
        obj = panel.get(j);
        obj_score_weight = objWeights.get(i).get(j);
        obj_score = 0;
        %iterate over subobjectives
        for k = 0:obj.size-1
            subObj_weight = subobjWeights.get(i).get(j).get(k);
            subObj_score = res_subObjScore.get(index_for_sorting(counter)-1);
            obj_score = obj_score+ subObj_weight*subObj_score;
            counter=counter+1;
        end
        panel_scores(1,i+1) = panel_scores(1,i+1) + obj_score_weight*obj_score;
    end
    science = science + panel_weight*panel_scores(1,i+1);
end

%%%%%
% the plotting code below

function RBES_plot25(handles,ax,archs,results, inaxis,filter_func,PARETO,resCollection)
    global hm
    global ref_arch ref_label
    
    cla(ax);
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
    for i = 1:narch
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
    ref_colors = {'b','r','c'};
    [a,b]=size(ref_arch);
    for i = 1:b
        for j = resCollection.getResults.size-1:-1:0
            if resCollection.getResults.get(j).getArch.getId==ref_arch{i}.getId
                sci = resCollection.getResults.get(j).getScience;
                cost = resCollection.getResults.get(j).getCost;
                scatter(sci,cost,50,'Marker','p','MarkerEdgeColor',ref_colors{i},'LineWidth',2,...
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
    set(handles.sensitivity_fig,'WindowButtonMotionFcn',{@axes_WindowButtonMotionFcn,xvals,yvals,handles});
    set(handles.sensiAxes,'ButtonDownFcn',{@axes_ButtonDownFcn,archs,xvals,yvals,handles});
    
    grid on;
    xlabel(inaxis{1});
    ylabel(inaxis{2});
    legend(labels,'Location','Best');

function axes_WindowButtonMotionFcn(src,event,x,y,handles)
global marker_closestArch_handle
cp = get(handles.sensiAxes,'CurrentPoint');
xmouse = cp(1,1);
ymouse = cp(1,2);
[~,ind] = min( abs((x - xmouse)/(max(x)-min(x))).^2+abs((y - ymouse)/(max(y)-min(y))).^2 );
try
    delete(marker_closestArch_handle);
end
marker_closestArch_handle = plot(x(ind),y(ind),'bs','LineWidth', 1, 'MarkerSize', 10 );

function axes_ButtonDownFcn(src,eventdata,archs,x,y,handles)

global architecture zeResult zeArch marker_handles compare_marker_handles

% Find the closest point arch to the mouse click
mouse = get( handles.sensiAxes, 'CurrentPoint' );
xmouse = mouse(1,1);
ymouse = mouse(1,2);
[~,ind] = min( abs((x - xmouse)/(max(x)-min(x))).^2+abs((y - ymouse)/(max(y)-min(y))).^2 );

% Set the architecture for analysis
% update_buttons_status( handles, 'off' );
architecture = [];
zeArch = archs{ind};
zeResult = zeArch.getResult;

update_buttons_status(handles, 'on');

% Highlighting the selected points
try
    delete(marker_handles);
    delete(compare_marker_handles);
end
marker_handles = plot(x(ind),y(ind),'gs','LineWidth', 3, 'MarkerSize', 10 );

function [x_pareto y_pareto i_pareto i_dominated] =  pareto_front(data, obj)
k = 1;
i_dominated = [];

for arch_i = 1 : size(data,1)
    for arch_j = 1 : size(data,1)
        
        count_i = 0;
        count_j = 0;
        
        for dec = 1:size(obj,2)
            
            if((strcmp(obj(dec), 'SIB')))
                if(data(arch_i, dec) > data(arch_j, dec))
                    count_j = count_j + 1;
                elseif(data(arch_i, dec) < data(arch_j, dec))
                    count_i = count_i + 1;
                end
            elseif (strcmp(obj(dec), 'LIB'))
                if(data(arch_i, dec) < data(arch_j, dec))
                    count_j = count_j + 1;
                elseif(data(arch_i, dec) > data(arch_j, dec))
                    count_i = count_i + 1;
                end
            end
        end
        
        if (count_i == 0 && count_j > 0)
            i_dominated(k) = arch_i;
            k = k+1;
        end
        
    end
    
end

i_dominated = unique(i_dominated);
i_pareto = setdiff(1:1:size(data,1),i_dominated);

% get the pareto frontier points
x_pareto = data(i_pareto,1);
y_pareto = data(i_pareto,2);

% Order the pareto frontier points
[x_pareto,I]=sort(x_pareto');
x_pareto = x_pareto';
y_pareto= y_pareto(I);

function update_buttons_status( handles, status )
set( handles.archDetailsbutton, 'Enable', status );
set( handles.explainSatisfactionButton, 'Enable', status );
set( handles.explainCostButton, 'Enable', status );

