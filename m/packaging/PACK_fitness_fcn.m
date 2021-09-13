function fitness = PACK_fitness_fcn(x,hObject)
%% PACK_fitness_fcn_multi.m
handles = guidata(hObject);
n = length(handles.NUM_archs);% this is a counter of architectures evaluated

%% Check interruptions
fid = fopen('control_matlab.txt','r');
s = fscanf(fid,'%s\n');
fclose(fid);
if strcmp(s(end-3:end),'stop')
    fprintf('Stopping...\n');
    keyboard();
end 

%% Check memory every 20 evaluations (stop if needed)
if mod(n,20) == 0
    mx = num2str(round(java.lang.Runtime.getRuntime.maxMemory/1024/1024));
    tot = num2str(round(java.lang.Runtime.getRuntime.totalMemory/1024/1024));
    free =num2str(round(java.lang.Runtime.getRuntime.freeMemory/1024/1024));
    if tot >= mx && free <= 50
        archs = handles.NUM_archs;
        sciences = handles.NUM_sciences;
        costs = handles.NUM_costs;
        save('intermediate_GA_results.mat','archs','sciences','costs');
        keyboard();
    end
end

%% Fix and plot
x2 = PACK_fix(x);
set(handles.rand_arch,'String',num2str(x2));
RBES_Plot_Pack_arch(handles.axes4,x2,handles.params);guidata(hObject, handles);pause(0.33);

%% Evaluate architecture
fprintf('Evaluating arch: ');fprintf('%d-',x2);fprintf('...');
arch.packaging = x2;
[science,total_cost,nsat] = PACK_evaluate_architecture(handles.r,handles.params,arch);
if nsat<max(x2) % case where one sat was too big, not accounted for by RBES, forbidden becasue packaging, not selection
    total_cost = 4000;% this is the cost of a regular arch with all instruments
end
fitness = -science/0.1 + total_cost/4000;

%% Save last 200 architectures evaluated
if n >= 200
    n = 0;% start from the beginning, to have a sort of circular array
    archs = handles.NUM_archs;
    sciences = handles.NUM_sciences;
    costs = handles.NUM_costs;
    save('intermediate_GA_results200.mat','archs','sciences','costs');
    handles.NUM_archs{n+1} = x2;
    handles.NUM_sciences(n+1) = science;
    handles.NUM_costs(n+1) = total_cost;

else % continue, don't save
    handles.NUM_archs{n+1} = x2;
    handles.NUM_sciences(n+1) = science;
    handles.NUM_costs(n+1) = total_cost;
end

%% Print
fprintf('science = %f cost = %f, unfitness = %f\n',science,total_cost/1000,fitness);
return
