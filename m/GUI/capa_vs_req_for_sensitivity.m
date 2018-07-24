function [ret,ret2] = capa_vs_req_for_sensitivity(res,subobj,attribute,new_perf,AE,params)
%capa_vs_req Compares capabilities with requirements for a certain subobj
%   Detailed explanation goes here
    reso = AE.getResourcePool.getResource;
    ret = {};
    
    try
        ret2 = cell(res.getCapabilities.size,3);
%         rete = reso.getRete;
        rule = params.requirement_rules.get(subobj);
        ret(1,1:2) = {'Id','taken by'};
        it = rule.keySet.iterator;
        list_of_attributes = cell(1,rule.size);
        list_of_thresholds = cell(1,rule.size);
        list_of_scores = cell(1,rule.size);
        i = 1;
        while it.hasNext
            attrib = it.next;
            tmp = rule.get(attrib);
            thresholds = tmp.get(1);
            scores = tmp.get(2);
            list_of_attributes{i} = attrib;
            list_of_thresholds{i} = thresholds;
            list_of_scores{i} = scores;
            i=i+1;
        end
        ret(2:3,2) = {'{Thresholds)';'(Scores)'}; 
        ret(1,3:2+rule.size) = list_of_attributes;
        ret{1,3+rule.size} = 'Data Product Score';
        ret(2,3:2+rule.size) = list_of_thresholds;
        ret(3,3:2+rule.size) = list_of_scores;
        capas = res.getCapabilities;
%         explan = res.getExplanations;
        theparam = params.subobjectives_to_measurements.get(subobj);
%         fprintf('** Subobj %s (%s)\n',subobj,theparam);
        
        n = 1;
        OFF = 3;
        max_subobj_score = 0;
        max_subobj_fact = 'no one';
        for i = 1:capas.size
            param = jess_value(capas.get(i-1).getSlotValue('Parameter'));
            if ~strcmp(['"' param '"'],theparam)
                continue;
            end
            it = rule.keySet.iterator;
            id = jess_value(capas.get(i-1).getSlotValue('Id'));
            taken_by = jess_value(capas.get(i-1).getSlotValue('taken-by')); 
            ret(n+OFF,1:2) = {id taken_by};
%             fprintf('Fact %d taken by %s:',capas.get(i-1).getFactId,taken_by);
            j = 3;
            cum_score = 1;
            while it.hasNext
                attrib = it.next;
                tmp = rule.get(attrib);
                type = tmp.get(0);
                thresholds = tmp.get(1);
                scores = tmp.get(2);
                if strcmp(attrib,attribute)
                    value = new_perf;
                else
                    value = jess_value(capas.get(i-1).getSlotValue(attrib));
                end
                str_value = jess_str_value(capas.get(i-1).getSlotValue(attrib));
                score = compute_score(value,thresholds,scores,type);
                cum_score = cum_score*score;
                
%                 if score < 1.0
%                     fprintf(' %s = %s (score = %.2f,thresholds = %s, scores = %s) ',attrib,str_value,score,thresholds,scores);
                    ret{n+OFF,j} = [num2str(value) ' (' num2str(score) ')'];
%                 end
%                 ret{n+OFF,j} = [num2str(value) ' (' num2str(score) ')'];
                j = j + 1;
            end
            if cum_score > max_subobj_score
                max_subobj_score = cum_score;
                max_subobj_fact = taken_by;
            end
            ret{n+OFF,j} = cum_score;
            n = n + 1;
%             fprintf(' SCORE = %.4f\n',cum_score);
            
        end
%         fprintf('MAX SUBOBJ SCORE = %.4f by %s\n',max_subobj_score,max_subobj_fact);
        ret2 = cell(1,3);
        ret2{1} = subobj;
        ret2{2} = theparam;
        ret2{3} = num2str(max_subobj_score);
        ret2{4} = max_subobj_fact;
    catch ME
        AE.getResourcePool.freeResource(reso);
        disp(subobj)
        disp(attribute)
        throw(ME);        
    end       
   AE.getResourcePool.freeResource(reso);
end
