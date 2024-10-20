%% RBES_sensitivity_analysis_instrument_attributes.m
function sensit_results = RBES_sensitivity_analysis_instrument_attributes(r, params, instr)
%% RBES_sensitivity_analysis_instrument_attributes.m
% This function takes a string representing the name of an instrument as an
% input. Then, it recovers all the relevant instrument attributes from the
% database, and then it loops over the attributes, changing their value and
% rerunning the analysis.
%
% Daniel Selva, August 13th 2011
%

% 1) get all attributes of instrument from excel...
filename = params.capability_rules_xls;
[~,txt]= xlsread(filename,'CHARACTERISTICS');
row = txt(strcmp(txt(:,1),instr),:); % Returns the whole row corresponding to instrument

% .. and all their possible values
g = GlobalVariables;
attribs = java.util.HashMap;
accepted = java.util.HashMap;

for i = 2:length(row)
    tmp = (regexp(row(i),'.+".+"','once'));
    len = length(tmp{1});
    if len > 0 % contains a "" characters
        struct = regexp(row(i),'(?<att>.+)\s"(?<val>.+)"','names');% struct.att = attribute, struct.val = value
        if ~strcmp(struct{1}.val,'nil') %if an attribute has value nil, assume it's not relevant for this instrument
        attr = g.instrumentAttributeSet.get(struct{1}.att);% returns an attribute object of that type
        if strcmp(attr.type,'FR') || strcmp(struct{1}.att,'Intent') % do not treat free numerical attributes for now
%             num0 =  struct{1}.val;
%             num_up = num0*1.2;
%             num_down = num0*0.8;
%             accepted.put(struct{1}.att,nums);
        else % treat NL, OL, Booleans, LIB2,3,5, etc
            tmp = ['"' struct{1}.val '"'];
            attribs.put(struct{1}.att,tmp);
            accepted.put(struct{1}.att,attr.acceptedValues);
        end
        end
    else
        struct = regexp(row(i),'(?<att>.+)\s(?<val>.)','names');% struct.att = attribute, struct.val = value
        if ~strcmp(struct{1}.val,'nil') %if an attribute has value nil, assume it's not relevant for this instrument
        attr = g.instrumentAttributeSet.get(struct{1}.att);% returns an attribute object of that type
        if strcmp(attr.type,'FR') % do not treat free numerical attributes for now
%             num0 =  struct{1}.val;
%             num_up = num0*1.2;
%             num_down = num0*0.8;
%             accepted.put(struct{1}.att,nums);
        else % treat NL, OL, Booleans, LIB2,3,5, etc
            attribs.put(struct{1}.att,struct{1}.val);
            accepted.put(struct{1}.att,attr.acceptedValues);
        end
        end
    end
    
    
end


    
% 4) for each attribute
it = accepted.entrySet.iterator;
sensit_results = java.util.HashMap;% key = attrib, value = hm see below
while(it.hasNext()) % for each attribute to be modified
    % retrieve list of values
    entry = it.next();
    this_attrib = entry.getKey;
    fprintf('Analyzing sensitivity to attribute %s...\n',this_attrib);
    values = entry.getValue.keySet.iterator;%
    
   hm = java.util.HashMap;% key = possible value, value = score with this value
    while(values.hasNext()) % for each possible value that this_attrib can take
        this_value = values.next();
        fprintf('.... Considering value %s ... ',this_value);
        r.reset;
        
        % 3) Find all instruments facts with this name
        facts = r.listFacts();
        facts_to_mod = java.util.ArrayList;
        while facts.hasNext()
                f = facts.next();
                if f.getName().startsWith('CAPABILITIES::Manifested-instrument') || f.getName().startsWith('DATABASE::Instrument')
                    name = jess_attr('Name',f);
                    if strfind(instr,name)
                        facts_to_mod.add(f.getFactId());
                    end
                end
        end
        fa = facts_to_mod.iterator;
        
        while fa.hasNext() % for all instruments of this name...
            this_fact = fa.next();% integer with id of the fact of instrument
             % modify this instrument fact, this attribute, with this value
             call = ['(modify ' num2str(this_fact) ' (' this_attrib ' ' this_value '))'];
             r.eval(call);
             % and rerun the system      
             
        end
        params.number_of_missions = 0;
        
        %% Assert one Mission
        params.number_of_missions = 1;

        call = ['(assert (MANIFEST::Mission (Name ' char(params.satellite_names) ')' ...
            ' (instruments ' instr ')' ...
            ' (lifetime ' num2str(params.lifetime) ')' ...
            ' (launch-date 2015)' ...
            '))'];
        r.eval(call);


        results = RBES_Evaluate_Manifest(r,params);
        score = results.score;
        fprintf('... score = %f\n',score);
        hm.put(this_value,score);
    end
    sensit_results.put(this_attrib,hm);
end
% 5) plot results
