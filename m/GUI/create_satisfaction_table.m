function ret1 = create_satisfaction_table(result)
 
    global params
    global AE
    exp = result.getExplanations;
    it = exp.keySet.iterator;
    ret1 = {'Subobjective' 'Parameter' 'Score' 'Taken by'};
    while it.hasNext
        subobj = it.next;
        [~,ret2] = capa_vs_req_from_explanation_field(result,subobj,AE,params);
        ret1 = [ret1;ret2];
    end
end