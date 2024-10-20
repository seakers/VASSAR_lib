function [total_miss,partial_miss,partial_scores] = RBES_missing_subobjectives(subobj_scores,TALK)
global params
% TALK = 1;
%% Individual requirement satisfaction
% subobjective_scores = cell(size(params.subobjectives));
nsubobj = RBES_count_subobj;
partial_miss = zeros(nsubobj,1);
partial_scores = zeros(nsubobj,1);
total_miss = zeros(nsubobj,1);
n = 1;
for p =1:params.npanels
    for o = 1:params.num_objectives_per_panel(p)
        for so = 1:length(params.subobjectives{p}{o})
            tmp = subobj_scores{p}{o}(so);
            if tmp < 1.0
                if tmp == 0.0
                    if TALK
                        subobje = params.subobjectives{p}{o}{so};
                        fprintf('Subobj %s (%s) is completely missed\n',char(subobje),char(RBES_subobj_to_meas(subobje(8:end))));
                    end
                    total_miss(n) = 1;
                else
                    if TALK
                        subobje = params.subobjectives{p}{o}{so};
                        fprintf('Subobj %s (%s) is partially missed, score = %f \n',char(subobje),char(RBES_subobj_to_meas(subobje(8:end))), tmp);
                    end
                    partial_miss(n) = 1;
                    partial_scores(n) = tmp;
                end
            end
            n = n + 1;
        end
    end
end
end