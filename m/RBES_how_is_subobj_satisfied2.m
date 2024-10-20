function who = RBES_how_is_subobj_satisfied2(subobj)
global params
TALK = 1;


[p,o,so] = RBES_subobj_to_indexes(subobj);

%% Single instruments
ninstr = length(params.subobjective_scores_singles);
for i = 1:ninstr
    subobj_scores = params.subobjective_scores_singles{i};
    score = subobj_scores{p}{o}(so);
    if score > 0.0
        if score == 1.0
            if TALK,fprintf('Subobj %s is fully satisfied by %s \n',subobj,params.instrument_list{i});who = params.instrument_list{i};return;end
        else
            if TALK,fprintf('Subobj %s is partially satisfied by %s, score = %f \n',subobj,params.instrument_list{i},score);who = params.instrument_list{i};end
        end
    end
end

% if exist('who','var')
%     return;
% end
%% Pairs
n = 1;
for i = 1:ninstr
    for j = i+1:ninstr
         subobj_scores = params.pairs_subobjective_scores{n};   
         score = subobj_scores{p}{o}(so);  
         if score > 0.0
            who = [params.instrument_list{i} '-' params.instrument_list{j}];
            if score == 1.0           
                if TALK,fprintf('Subobj %s is fully satisfied by %s \n',subobj,who);end               
            else
                if TALK,fprintf('Subobj %s is partially satisfied by %s, score = %f \n',subobj,who,score);end
            end
         end
        n = n + 1;
    end
end
if ~exist('who','var')
    who = 'no one';
end
%% Specials
end

