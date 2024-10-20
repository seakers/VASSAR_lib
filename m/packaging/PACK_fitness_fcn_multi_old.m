function metrics = PACK_fitness_fcn_multi(x,hObject)
%% PACK_fitness_fcn_multi.m
TEST = 0;
handles = guidata(hObject);
% persistent interm_results;
% if isempty(interm_results)
%     n = 0;
% else
%     n = length(interm_results);% this is a counter of architectures evaluated
% end

%% Check interruptions
fid = fopen('control_matlab.txt','r');
s = fscanf(fid,'%s\n');
fclose(fid);
if strcmp(s(end-3:end),'stop')
    fprintf('Stopping...\n');
    keyboard();
end 
% 
% %% Check memory every 10 evaluations (stop if needed)
% if (mod(n,10) == 0 && n>0)
%     mx = round(java.lang.Runtime.getRuntime.maxMemory/1024/1024);
%     tot = round(java.lang.Runtime.getRuntime.totalMemory/1024/1024);
%     free = round(java.lang.Runtime.getRuntime.freeMemory/1024/1024);
%     if((tot >= mx) && (free <= 50))
%         save('intermediate_GA_results.mat','interm_results');
%         keyboard();
%     end
% end

%% Fix and plot
x2 = PACK_fix(x);
% set(handles.rand_arch,'String',num2str(x2));
% RBES_Plot_Pack_arch(handles.axes4,x2,handles.params);guidata(hObject, handles);pause(0.33);

%% Evaluate architecture
fprintf('Evaluating arch: ');fprintf('%d-',x2);fprintf('...');
arch.packaging = x2;
if TEST
    science = rand;
    total_cost = rand;
    nsat = randi(4);
else
%     load_facts_base('global_jess_engine.mat');
%     r = global_jess_engine();
    r = handles.r;
    [science,total_cost,nsat] = PACK_evaluate_architecture(r,handles.params,arch);
%     clear r;
end

if nsat<max(x2) % case where one sat was too big, not accounted for by RBES, forbidden becasue packaging, not selection
    total_cost = 4000;% this is the cost of a regular arch with all instruments
end
% fitness = -science/0.1 + total_cost/4000;
% 
% %% Save last 20 architectures evaluated
% if n >= 20
%     save('intermediate_GA_results20.mat','interm_results');
%     clear interm_results;
% else % continue, don't save
%     interm_results.archs{n+1} = x2;
%     interm_results.sciences(n+1) = science;
%     interm_results.costs(n+1) = total_cost;
% end

%% Print
fprintf('science = %f cost = %f\n',science,total_cost/1000);
metrics(2) = -science;
metrics(1) = total_cost/1000;

return
