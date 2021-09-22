%% RBES_sensitivity_analysis_instrument_attributes.m
function sensit_results = RBES_sensitivity_analysis_instrument_attributes_Iridium(params, instr, arch)
%% RBES_sensitivity_analysis_instrument_attributes.m
% This function takes a string representing the name of an instrument as an
% input. Then, it recovers all the relevant instrument attributes from the
% database, and then it loops over the attributes, changing their value and
% rerunning the analysis.
%
% Daniel Selva, August 13th 2011
%

%% 0) Run reference case
RBES_Init_Params_Iridium;
[r,params] = RBES_Init_WithRules(params);
fprintf('Evaluating ref architecture...\n');
[r,ref_score,panel_scores,data_continuity_score,params] = Evaluate_Iridium_architecture(r,arch,params);
fprintf('Done, scores = %f %f\n',ref_score,data_continuity_score);

%% Run all other cases

% 1) get all attributes of instrument from excel...
filename = params.capability_rules_xls;
[~,txt]= xlsread(filename,'CHARACTERISTICS');
row = txt(strcmp(txt(:,1),instr),:); % Returns the whole row corresponding to instrument

% .. and all their possible values
g = GlobalVariables;
attribs = java.util.HashMap;
accepted = java.util.HashMap;

for i = 2:length(row)
    struct = regexp(row(i),'(?<att>.+)\s(?<val>.+)','names');% struct.att = attribute, struct.val = value
    if ~strcmp(struct{1}.val,'nil') %if an attribute has value nil, assume it's not relevant for this instrument
        attr = g.instrumentAttributeSet.get(struct{1}.att);% returns an attribute object of that type
        if strcmp(attr.type,'FR') % do not treat free numerical attributes for now
        else % treat NL, OL, Booleans, LIB2,3,5, etc
            attribs.put(struct{1}.att,struct{1}.val);
            accepted.put(struct{1}.att,attr.acceptedValues);
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
        
        %% Assert one Mission per satellite
        for i = 1:length(arch)
            if arch(i) >0
                params.number_of_missions = params.number_of_missions + 1;
                % Retrieve instrument names
                instr_list_str = [];
                n = length(params.payload_list{arch(i)}.instruments);

                for j = 1:n
                    instr_list_str = [instr_list_str ' ' params.payload_list{arch(i)}.instruments{j}];
                end

                % Retrieve orbital parameters
                vars = params.IridiumSatelliteParameters.get(i).toArray;% [raan, ano, launchdate]
                call = ['(assert (MANIFEST::Mission (Name ' params.satellite_names '-' num2str(i) ')' ...
                    ' (orbit-altitude# ' num2str(params.Iridium_altitude) ')' ...
                    ' (orbit-inclination ' num2str(params.Iridium_inclination) ')' ...
                    ' (orbit-RAAN ' num2str(vars(1)) ')' ...
                    ' (orbit-anomaly# ' num2str(vars(2)) ')' ...
                    ' (instruments ' instr_list_str ')' ...
                    ' (lifetime ' num2str(params.lifetime) ')' ...
                    ' (launch-date ' num2str(vars(3)) ')' ...
                    '))'];
                r.eval(call);
                if arch(i)>6 % more than one instrument
                    call = ['(assert (SYNERGIES::cross-registered-instruments '...
                ' (instruments ' instr_list_str ') '...
                ' (degree-of-cross-registration spacecraft) '...
                ' (platform ' params.satellite_names '-' num2str(i) ' ) '...
                '))' ];
                    r.eval(call);
                end
            end
        end

        results = RBES_Evaluate_Manifest(r,params);
        score = results.score;
        fprintf('... score = %f\n',score);
        hm.put(this_value,score);
    end
    sensit_results.put(this_attrib,hm);
end

%% Plot results
PLOT = 0;
if PLOT
    res = sensit_results.entrySet.iterator;
    while(res.hasNext())
        one_att = res.next();
        att = one_att.getKey;
        hm = one_att.getValue;
        vals = hm.entrySet.iterator;
        labels = cell(1,hm.entrySet.size);
        values = zeros(1,hm.entrySet.size);

        for i = 1:hm.entrySet.size
            nn = vals.next();
            labels{i} = nn.getKey();
            fprintf('%s\n',labels{i});
            values(i) = nn.getValue();
        end

        % sort values before plot
        [sorted_values,order] = sort(values,'descend');
        sorted_labels = labels(order);
        scrsz = get(0,'ScreenSize');
        figure1 = figure('Position',[1 0 scrsz(3) scrsz(4)]);

        % Create axes
        axes1 = axes('Parent',figure1,'FontSize',12,'FontName','Arial');

        plot(1:length(values),sorted_values,'b-','Parent',axes1);
        set(gca,'XTick',1:length(values));
        set(gca,'XTickLabel',sorted_labels,'FontSize',16);
    %     xlabel('Attribute value','FontSize',12);
        ylabel('Science benefit','FontSize',16);
        title(att,'FontSize',20);
        grid on;
        print('-dmeta',[instr  '-SA-' att(1:5) '.emf']);
    end
end
end
