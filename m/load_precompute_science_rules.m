function load_precompute_science_rules
global params
r = global_jess_engine();
subobjective_scores_singles = RBES_get_parameter('subobjective_scores_singles');
pairs_subobjective_scores = RBES_get_parameter('pairs_subobjective_scores');
special_subobjective_scores = RBES_get_parameter('special_subobjective_scores');

pnam = params.panel_names;
for i = 1:length(subobjective_scores_singles)
    subobj = subobjective_scores_singles{i};
    call = ['(defrule PRECOMPUTE-SCIENCE::single-' params.instrument_list{i} ...
                        ' (CAPABILITIES::Manifested-instrument (Name ' params.instrument_list{i}  '))' ...
                        ' => '];
    for p = 1:params.npanels
        for o = 1:length(subobj{p})
            for so = 1:length(subobj{p}{o})
                score = subobj{p}{o}(so);
                if score == 1
                    str = [pnam{p} num2str(o) '-' num2str(so)];
                    var_name = ['?*subobj-' str '*'];
                    call = [call ' (assert (REASONING::fully-satisfied (subobjective ' str ') (taken-by ' params.instrument_list{i} ')))'];
                    call = [call ' (bind ' var_name ' (max ' var_name ' 1.00))'];
                end
            end
        end
        
    end
    call = [call ')'];
    r.eval(call);
end

kk = 2;% we are interested in pairs
payloads = combnk(params.instrument_list,kk);% this is a (N*(N-1),2) cell

for i = 1:length(pairs_subobjective_scores)
    subobj = pairs_subobjective_scores{i};
    payload = payloads(i,:);
    call = ['(defrule PRECOMPUTE-SCIENCE::pair-' payload{1} '-' payload{2}...
                        ' (CAPABILITIES::Manifested-instrument (Name ' payload{1}  '))' ...
                        ' (CAPABILITIES::Manifested-instrument (Name ' payload{2}  '))' ...
                        ' => '];
    for p = 1:params.npanels
        for o = 1:length(subobj{p})
            for so = 1:length(subobj{p}{o})
                score = subobj{p}{o}(so);
                if score == 1
                    str = [pnam{p} num2str(o) '-' num2str(so)];
                    var_name = ['?*subobj-' str '*'];
                    call = [call ' (assert (REASONING::fully-satisfied (subobjective ' str ') (taken-by ' payload{1} '-syn-' payload{2} ')))'];                  
                    call = [call ' (bind ' var_name ' (max ' var_name ' 1.00))'];
                end
            end
        end
        
    end
    call = [call ')'];
    r.eval(call);
end
special_subobjective_scores = params.special_subobjective_scores;
list = special_subobjective_scores.entrySet.iterator;

while(list.hasNext())
    entr = list.next;
    payload = cell(entr.getKey());
    nins = length(payload);
    payl_name = payload{1};
    for jj = 2:nins
        payl_name = [payl_name '-' char(payload(jj))];
    end
    subobjs = entr.getValue().iterator;
    call = ['(defrule PRECOMPUTE-SCIENCE::special-' payl_name];
%                         ' (CAPABILITIES::Manifested-instrument (Name ' payload{1}  '))' ...
%                         ' (CAPABILITIES::Manifested-instrument (Name ' payload{2}  '))' ...
    for jj = 1:nins
        call = [call ' (CAPABILITIES::Manifested-instrument (Name ' payload{jj}  '))'];
    end
    call = [call ' => '];
    while subobjs.hasNext()
        str = subobjs.next();
        var_name = ['?*subobj-' str '*'];
        call = [call ' (assert (REASONING::fully-satisfied (subobjective ' str ') (taken-by "' payl_name '-syn"'  ')))'];                  
        call = [call ' (bind ' var_name ' (max ' var_name ' 1.00))'];
    end
    call = [call ')'];
    r.eval(call);
end
end