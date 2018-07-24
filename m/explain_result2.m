function explain_result2(res,AE,params)
    exp = res.getExplanations;
    subobj_scores = res.getSubobjective_scores2;
    it = exp.keySet.iterator;
    while it.hasNext
        subobj = it.next;
        score = subobj_scores.get(subobj);
        if score < 1.0
            
            capa_vs_req(res,subobj,AE,params);
        end
    end
end