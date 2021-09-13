function explain_result(res)
    exp = res.getExplanations;
    subobj_scores = res.getSubobjective_scores;
    it = exp.keySet.iterator;
    i = 0;
    while it.hasNext
        subobj = it.next;
        score = subobj_scores.get(i);
        if score < 1.0
            explain_subobj(exp,subobj)
        end
    end
end