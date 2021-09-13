function load_requirement_rules_new
    global params
    r = global_jess_engine();
    [~,txt]= xlsread(params.requirement_rules_xls,'Attributes');
    
    % Definition of requirement satisfaction functions
    params.req_sat_func = java.util.HashMap;
    params.req_sat_func.put('LIB_thr_only',[1 0]);
    params.req_sat_func.put('LIB_thr_goal',[1 0.5 0]);
    params.req_sat_func.put('LIB_three_values',[1 0.67 0.33 0]);
    
    % Read headers
    headers = txt(1,:);
    SUBOBJ = strcmp(headers,'Subobjective');
    MEAS = strcmp(headers,'Measurement');
    ATTR = strcmp(headers,'Attribute');
    TYP = strcmp(headers,'Type');

    THR = strcmp(headers,'Thresholds');
    SCOR = strcmp(headers,'Scores');
    JUSTIF = strcmp(headers,'Justification');
    
    % Loop
    subobjs = unique(txt(2:end,SUBOBJ));
    num_subobj = length(subobjs);
    call2 = '(deffacts REQUIREMENTS::init-subobjectives ';
    for j = 1:num_subobj
        subobj = subobjs{j};
        indexes = find(strcmp(txt(:,SUBOBJ),subobj));
        line = txt(indexes(1),:);
        meas = line{MEAS};
        call = ['(defrule REQUIREMENTS::' subobj '-attrib  ?m <- (REQUIREMENTS::Measurement (taken-by ?whom) (Parameter ' meas ') '];
        nattribs = size(txt(indexes,:),1);
        attribs = cell(1,nattribs);
        for i = 1:nattribs
            % Read one requirement
            line = txt(indexes(i),:);
            subobj = line{SUBOBJ};
            attrib = line{ATTR};
            attribs{i} = attrib;
            % Create corresponding rule
            call = [call ' (' attrib ' ?val' num2str(i) '&~nil) '];

        end
%         call = [call ') => (bind ?x (* '];
        call = [call ') => (bind ?reason "") (bind ?new-reasons (create$ ' repmat('N-A ',1,nattribs) ' ) ) '];
        justifs = cell(1,nattribs);
        for i = 1:nattribs
            line = txt(indexes(i),:);
            attrib = line{ATTR};
            justif = line{JUSTIF};
            justifs{i} = justif;
            tmp_scores = line{SCOR};
            if strncmp(tmp_scores,'[',1)
                scores = txt_array_to_matlab_array(tmp_scores);      
            else
                scores = params.req_sat_func.get(tmp_scores);
            end
            
            if attrib(end) == '#'
                NUMERIC = true;
            else
                NUMERIC = false;
            end
           
            
            if NUMERIC
                thresholds = txt_array_to_matlab_array(line{THR});
%                 call = [call ' (nth$ (find-bin-num ?val' num2str(i) ' (create$ ' num2str(thresholds) ')) (create$ ' num2str(scores) ' )) '];
                call = [call ' (bind ?x' num2str(i) ' (nth$ (find-bin-num ?val' num2str(i) ' (create$ ' num2str(thresholds) ')) (create$ ' num2str(scores) ' ))) '];
                call = [call ' (if (< ?x' num2str(i) ' 1.0) then (bind ?new-reasons (replace$ ?new-reasons ' num2str(i) ' ' num2str(i) ' ' justif ' )) (bind ?reason (str-cat ?reason " + " ' justif '))) '];
%                 att_score  = jess_value()
            else
                thresholds = txt_array_to_matlab_cell_array(line{THR});
                call = [call ' (bind ?x' num2str(i) ' (nth$ (find-bin-txt ?val' num2str(i) ' (create$ ' StringArraytoStringWithSpaces(thresholds) ')) (create$ ' num2str(scores) ' )))'];
                call = [call ' (if (< ?x' num2str(i) ' 1.0) then (bind ?new-reasons (replace$ ?new-reasons ' num2str(i) ' ' num2str(i) ' ' justif ' )) (bind ?reason (str-cat ?reason " + " ' justif '))) '];
            end
             
        
        end
%         justifs = [justifs '"'];
%         call = [call '))'];
        call = [call ' (bind ?list (create$ '];
%         call = '';
        for i = 1:nattribs
            call = [call ' ?x' num2str(i)];
        end
        call = [call ')) '];
        tmpp = regexp(subobj,'(?<parent>.+)-(?<index>.+)','names');
        call2 = [call2 ' (AGGREGATION::SUBOBJECTIVE (satisfaction 0.0) (id ' subobj ') (index ' tmpp.index ') (parent ' tmpp.parent ...
            ' ) (reasons (create$ ' repmat('N-A ',1,nattribs) ' )) ) '];
        call = [call ' (assert (AGGREGATION::SUBOBJECTIVE (id ' subobj ') (attributes ' StringArraytoStringWithSpaces(attribs) ') (index ' tmpp.index ... 
            ' ) (parent ' tmpp.parent ' ) (attrib-scores ?list) (satisfaction (*$ ?list)) (reasons ?new-reasons) (satisfied-by ?whom) (reason ?reason )))'];
        var_name = ['?*subobj-' subobj '*'];
        call = [call '(bind ' var_name ' (max ' var_name ' (*$ ?list))) '];
        call = [call ')'];
        r.eval(call);
        
    end
    call2 = [call2 ')'];
    r.eval(call2);  
end