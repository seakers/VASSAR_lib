function [archs2,values2,specials2] = RBES_retrieve_architectures(type,options)
%% RBES_retrieve_architectures.m
%
% Usage:
% options.values = {'science','cost','utility','pareto-ranking'};
% [archs,values] = RBES_retrieve_architectures('selection',options);% values(i,j) contaisn metric j for arch i
% sciences = values(:,1);
% costs = values(:,2);
% utilities = values(:,3);
% pareto_rankings = values(:,4);


global params
r = global_jess_engine();
% preallocate
MAX_ARCHS = 10000;

nmetrics = length(options.values);
values = zeros(MAX_ARCHS,nmetrics);
specials = cell(MAX_ARCHS,1);
if strcmp(type,'selection')
    n = length(params.instrument_list);
elseif strcmp(type,'packaging')
    n = length(params.packaging_instrument_list);
elseif strcmp(type,'scheduling')
    n = params.SCHEDULING_num_missions;
elseif strcmp(type,'assigning')
    n = length(params.assign_instrument_list);
end
archs = zeros(MAX_ARCHS,n);
% loop
fact_archs = r.listFacts();
ii = 1;
if strcmp(type,'selection')
    while(fact_archs.hasNext())
        f_arc = fact_archs.next();
        templ = f_arc.getDeftemplate.getName();
        if ~strcmp(templ,'HARD-CONSTRAINTS::SEL-ARCH')
            continue;
        else
            
            for nn = 1:nmetrics
                values(ii,nn) = f_arc.getSlotValue(options.values{nn}).floatValue(r.getGlobalContext());
            end
            seq = f_arc.getSlotValue('sequence').floatValue(r.getGlobalContext());
            arc = de2bi(seq,n);
            archs(ii,:) = arc;
            ii = ii + 1;
        end
    end
elseif strcmp(type,'packaging')
    while(fact_archs.hasNext())
        f_arc = fact_archs.next();
        templ = f_arc.getDeftemplate.getName();
        if ~strcmp(templ,'HARD-CONSTRAINTS::PACK-ARCH')
            continue;
        else
            
            for nn = 1:nmetrics
                values(ii,nn) = f_arc.getSlotValue(options.values{nn}).floatValue(r.getGlobalContext());
            end
            specials{ii} = jess_value(f_arc.getSlotValue('instrument-orbits'));
            arc = cell2mat(jess_value(f_arc.getSlotValue('assignments')));
            archs(ii,:) = arc;
            ii = ii + 1;
        end
    end
elseif strcmp(type,'assigning')
    while(fact_archs.hasNext())
        f_arc = fact_archs.next();
        templ = f_arc.getDeftemplate.getName();
        if ~strcmp(templ,'HARD-CONSTRAINTS::ASSIGN-ARCH')
            continue;
        else
            
            for nn = 1:nmetrics
                values(ii,nn) = f_arc.getSlotValue(options.values{nn}).floatValue(r.getGlobalContext());
            end
%             specials{ii} = jess_value(f_arc.getSlotValue('instrument-orbits'));
            arc = cell2mat(jess_value(f_arc.getSlotValue('assignments')));
            archs(ii,:) = arc;
            ii = ii + 1;
        end
    end    
elseif strcmp(type,'scheduling')
    while(fact_archs.hasNext())
        f_arc = fact_archs.next();
        templ = f_arc.getDeftemplate.getName();
        if ~strcmp(templ,'HARD-CONSTRAINTS::PERMUTING-ARCH')
            continue;
        else
            
            for nn = 1:nmetrics
                values(ii,nn) = f_arc.getSlotValue(options.values{nn}).floatValue(r.getGlobalContext());
            end
            seq = cell2mat(jess_value(f_arc.getSlotValue('sequence')));
            archs(ii,:) = seq;
            ii = ii + 1;
        end
    end
end

% remove excess values
values(ii:end,:) = [];
archs(ii:end,:) = [];
specials(ii:end,:) = [];
% remove duplicates
[archs2,ind,~] = unique(archs,'rows');
values2 = zeros(length(ind),nmetrics);
for nn = 1:nmetrics
    values2(:,nn) = values(ind,nn);
end
specials2 = specials(ind);

end