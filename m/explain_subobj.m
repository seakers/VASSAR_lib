function explain_subobj( exp, subobj )
%explain_subobj Provides explanation of subobjective satisfaction
%   Provides detail of what attributes are missing and why
    sat = jess_value(exp.get(subobj).getSlotValue('satisfaction'));
    fprintf('--- Subobj %s: sat = %.3f\n',subobj,sat);
    attr_scores = cell2mat(jess_value(exp.get(subobj).getSlotValue('attrib-scores')));
    if isempty(attr_scores)
        fprintf('Missing capabilities\n');
        return;
    end
    attr_names = jess_value(exp.get(subobj).getSlotValue('attributes'));
    reasons = jess_value(exp.get(subobj).getSlotValue('reasons'));
    for i = 1:length(reasons)
        if attr_scores(i) < 1.0
            fprintf('Attr %s score %.3f because %s\n',attr_names{i},attr_scores(i),reasons{i});
        end
    end
    fprintf('---\n');
end

