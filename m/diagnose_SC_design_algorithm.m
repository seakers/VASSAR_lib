%% diagnose_SC_design_algorithm.m
function diagnose_SC_design_algorithm()
    r = global_jess_engine;
    c = r.getGlobalContext;
    [sats,~] = get_all_data('MANIFEST::Mission',{'id'},{'single-char'},0);
    for i = 1:length(sats)
        sat = sats{i};
        % Payload requirements
        disp('*************** Payload requirements');
        required_slots = {'payload-mass#','payload-power#','payload-data-rate#'};
        required_multislots = {'payload-dimensions'};
        for j = 1:length(required_slots)
            tmp = char(sat.getSlotValue(required_slots{j}).stringValue(c));
            if strcmp(tmp,'nil')
                disp(['!NOK ' required_slots{j} ' was not assigned']);
            else
                disp(['OK ' required_slots{j} ' = ' tmp]);
            end
        end
        for j = 1:length(required_multislots)
            tmp = char(sat.getSlotValue(required_multislots{j}).listValue(c));
            if isempty(tmp)
                disp(['!NOK ' required_multislots{j} ' was not assigned']);
            else
                disp(['OK ' required_multislots{j} ' = ' tmp]);
            end
        end
        % Orbit
        disp('*************** Orbit parameters');
        required_slots = {'orbit-type','orbit-semimajor-axis','orbit-altitude#','orbit-inclination','orbit-RAAN','orbit-eccentricity'};
        required_multislots = {'payload-dimensions'};
        for j = 1:length(required_slots)
            tmp = char(sat.getSlotValue(required_slots{j}).stringValue(c));
            if strcmp(tmp,'nil')
                disp(['!NOK ' required_slots{j} ' was not assigned']);
            else
                disp(['OK ' required_slots{j} ' = ' tmp]);
            end
        end
        for j = 1:length(required_multislots)
            tmp = char(sat.getSlotValue(required_multislots{j}).listValue(c));
            if isempty(tmp)
                disp(['!NOK ' required_multislots{j} ' was not assigned']);
            else
                disp(['OK ' required_multislots{j} ' = ' tmp]);
            end
        end
        
        % Preliminary design
         disp('*************** Preliminary design parameters');
         disp('payload mass & dimensions -> bus mass -> satellite dry mass, dimensions -> moments of inertia');
        required_slots = {'payload-mass#','bus-mass','satellite-dry-mass'};
        required_multislots = {'instruments','payload-dimensions','satellite-dimensions','moments-of-inertia'};
        for j = 1:length(required_slots)
            tmp = char(sat.getSlotValue(required_slots{j}).stringValue(c));
            if strcmp(tmp,'nil')
                disp(['!NOK ' required_slots{j} ' was not assigned']);
            else
                disp(['OK ' required_slots{j} ' = ' tmp]);
            end
        end
        for j = 1:length(required_multislots)
            tmp = char(sat.getSlotValue(required_multislots{j}).listValue(c));
            if isempty(tmp)
                disp(['!NOK ' required_multislots{j} ' was not assigned']);
            else
                disp(['OK ' required_multislots{j} ' = ' tmp]);
            end
        end
        
        % ADCS subsystem
        adcs_mass = jess_value(sat.getSlotValue('ADCS-mass#'));
        if strcmp(adcs_mass,'nil')
            disp('*************** ADCS was not designed');
            required_slots = {'ADCS-requirement','satellite-dry-mass','ADCS-type','Isp-injection','Isp-ADCS',...
                'propellant-injection','propellant-ADCS','residual-dipole','slew-angle',...
                'orbit-semimajor-axis','drag-coefficient','worst-sun-angle'};
            required_multislots = {'satellite-dimensions','moments-of-inertia'};
            for j = 1:length(required_slots)
                tmp = char(sat.getSlotValue(required_slots{j}).stringValue(c));
                if strcmp(tmp,'nil')
                    disp(['!NOK ' required_slots{j} ' was not assigned']);
                else
                    disp(['OK ' required_slots{j} ' = ' tmp]);
                end
            end
            for j = 1:length(required_multislots)
                tmp = char(sat.getSlotValue(required_multislots{j}).listValue(c));
                if isempty(tmp)
                    disp(['!NOK ' required_multislots{j} ' was not assigned']);
                else
                    disp(['OK ' required_multislots{j} ' = ' tmp]);
                end
            end
%             adcs_req = jess_value(sat.getSlotValue('ADCS-requirement'));
%             adcs_typ = jess_value(sat.getSlotValue('ADCS-type'));
%             isp_inj = jess_value(sat.getSlotValue('Isp-injection'));
%             isp_adcs = jess_value(sat.getSlotValue('Isp-ADCS'));
%             prop_inj = jess_value(sat.getSlotValue('propellant-injection'));
%             prop_adcs = jess_value(sat.getSlotValue('propellant-ADCS'));
%             dipole = jess_value(sat.getSlotValue('residual-dipole'));
%             slew_angle = jess_value(sat.getSlotValue('slew-angle'));
        end
        
        % Power subsystem
        eps_mass = jess_value(sat.getSlotValue('EPS-mass#'));
        if strcmp(eps_mass,'nil')
            disp('*************** EPS was not designed');
        end
        
         % Propulsion subsystem
        prop_mass = jess_value(sat.getSlotValue('propulsion-mass#'));
        if strcmp(prop_mass,'nil')
            disp('*************** Propulsion was not designed');
            required_slots = {'propellant-injection','propellant-ADCS','Isp-injection','Isp-ADCS',...
               'satellite-dry-mass','delta-V-injection','delta-V','propellant-mass-injection','propellant-mass-ADCS',...
                'delta-V-drag','lifetime','delta-V-ADCS','delta-V-deorbit','deorbiting-strategy'};
            required_multislots = {'satellite-dimensions','moments-of-inertia'};
            for j = 1:length(required_slots)
                tmp = char(sat.getSlotValue(required_slots{j}).stringValue(c));
                if strcmp(tmp,'nil')
                    disp(['!NOK ' required_slots{j} ' was not assigned']);
                else
                    disp(['OK ' required_slots{j} ' = ' tmp]);
                end
            end
            for j = 1:length(required_multislots)
                tmp = char(sat.getSlotValue(required_multislots{j}).listValue(c));
                if isempty(tmp)
                    disp(['!NOK ' required_multislots{j} ' was not assigned']);
                else
                    disp(['OK ' required_multislots{j} ' = ' tmp]);
                end
            end
        end
        
        % Launch vehicle not assigned
        lv = jess_value(sat.getSlotValue('launch-vehicle'));
        if strcmp(lv,'nil')
            disp('*************** LV was not assigned');
        end
    end
    
    
    
end