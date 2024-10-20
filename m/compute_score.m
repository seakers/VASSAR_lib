function score = compute_score(value,thresholds,scores,type)
    thr_vec = regexp(thresholds(2:end-1),',','split');
    sco_vec = str2double(regexp(scores(2:end-1),',','split'));
%     if ~isempty(str2double(thr_vec(1)))
%         thr_vec = str2double(thr_vec);        
%         if thr_vec(1) > thr_vec(end)
%             type = 'LIB';
%         else
%             type = 'SIB';
%         end
%     else
%         type = 'TXT';
%     end
    
    if strcmp(value,'nil')
        score = 0.0;
        return
    end
    switch type
        case 'LIB'
            thr_vec = str2double(thr_vec); 
            assigned = false;
            for i = 1:length(thr_vec)
                if value>=thr_vec(i)
                    score = sco_vec(i);
                    assigned = true;
                    break;
                end
            end
            if ~assigned
                score = sco_vec(end);
            end
        case 'SIB'
            thr_vec = str2double(thr_vec); 
            assigned = false;
            for i = 1:length(thr_vec)
                if value<=thr_vec(i)
                    score = sco_vec(i);
                    assigned = true;
                    break;
                end
            end
            if ~assigned
                score = sco_vec(end);
            end
        case 'OL'
            assigned = false;
            for i = 1:length(thr_vec)
                if strcmp(value,thr_vec{i}) || strcmp(value,['"' thr_vec{i} '"'])
                    score = sco_vec(i);
                    assigned = true;
                    break;
                end
            end
            if ~assigned
                score = sco_vec(end);
            end    
        case 'BOOL'
             if strcmp(value,thr_vec{1}) || strcmp(value,['"' thr_vec{1} '"'])
                 score = sco_vec(1);
             else
                 score = sco_vec(2);
             end
        otherwise
            error('compute_score::Unsupported type of attribute %s\n',type);
    end
end
