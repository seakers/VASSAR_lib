function [archs,results] = SEL_evaluate_architectures()
%% SEL_evaluate_architectures.m
% global params
r = global_jess_engine();
fact_archs = r.listFacts();
ii = 1;
N = SEL_count_architectures;
instrument_list = RBES_get_parameter('instrument_list');
n = length(instrument_list);
r.eval('(unwatch all)');
sciences = zeros(N,1);
costs = zeros(N,1);
archs = zeros(N,n);
seqs = zeros(N,1);
risks = zeros(N,1);
fairness = zeros(N,1);
while(fact_archs.hasNext())
    f_arc = fact_archs.next();
    templ = f_arc.getDeftemplate.getName();
    if ~strcmp(templ,'HARD-CONSTRAINTS::SEL-ARCH')
        continue;
    else
        
%         fact_id = f_arc.getFactId();
%         r.eval(['(bind ?ins (fact-slot-value ' num2str(fact_id) ' selected-instruments))']);

        % risk metric from instrument trls
        list = f_arc.getSlotValue('selected-instruments').listValue(r.getGlobalContext());
        myList = jess.Value(list, jess.RU.LIST);
        r.store('LIST',myList);
        jess bind ?ins (fetch LIST);
        jess bind ?trls (get-instrument-list-trls ?ins);
        tmp = r.eval('?trls').javaObjectValue(r.getGlobalContext());
        trls = cell2mat(cell(tmp.toArray));
        risks(ii) = sum(trls<5)/length(trls);
        
        % science, cost and fairness metrics
        seqs(ii) = f_arc.getSlotValue('sequence').floatValue(r.getGlobalContext());
        arc = de2bi(seqs(ii),n);
        archs(ii,:) = arc;
        fprintf('Evaluating arch %d from %d: %s\n',ii,N,SEL_arch_to_str(arc));

        res = SEL_evaluate_architecture3(logical(arc));% this retracts the fact because it resets!!
        sciences(ii) = res.science;
        costs(ii) = res.cost;
        fairness(ii) = min(res.panel_scores);
%         java.lang.System.gc;
%         r.retract(f_arc);
        ii = ii + 1;
    end
end


% Compile results
results.sciences = sciences;
results.costs = costs;
results.programmatic_risks = risks;
results.utilities = RBES_compute_utilities3(results,{'sciences','costs','programmatic_risks'},{'LIB','SIB','SIB'},[0.4 0.4 0.20]);
results.pareto_rankings = RBES_compute_pareto_rankings([-sciences costs]);
results.fairness = fairness;% these are the min(panel_scores) that we want to be >0 in order to guarantee fairness
java.lang.System.gc;
end
