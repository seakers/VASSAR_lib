function orbit_str = RBES_Select_Orbit
%% RBES_Select_Orbit.m
% This function finds all the missions asserted that do not have assigned
% orbits and uses the orbit selection rules to find the optimal orbit for
% each mission.
%
% Daniel Selva, Sep 3 2011

%% Run orbit selection module
% This asserts all possible mission orbits
% and gives values to global variables of goodness of each orbit to each
% instrument-mission

% global params
orbit_str = [];
r = global_jess_engine();

r.eval('(focus ORBIT-SELECTION)');
r.run;

%% Assign optimal orbits

facts = r.listFacts(); % iterator
mission_map = java.util.HashMap;
while facts.hasNext()
    f = facts.next();
    if ~strcmp(f.getDeftemplate,'[deftemplate ORBIT-SELECTION::orbit]')
        continue
    end
    orb = char(f.getSlotValue('orb').stringValue(r.getGlobalContext()));
    miss = char(f.getSlotValue('in-mission').stringValue(r.getGlobalContext()));
    var = char(f.getSlotValue('penalty-var').stringValue(r.getGlobalContext()));
    %str = char(f.getSlotValue('of-instrument').stringValue(r.getGlobalContext()));
    if mission_map.containsKey(miss)
        map = mission_map.get(miss);
    else
        mission_map.put(miss,java.util.HashMap);
        map = mission_map.get(miss); 
    end
    penalty = r.eval(var).floatValue(r.getGlobalContext());
    if map.containsKey(orb)
        pen = map.get(orb);
        map.put(orb,pen+penalty);
    else
        map.put(orb,penalty);
    end
end

tmp2 = mission_map.entrySet.iterator;
best_orbits = java.util.HashMap;% mission -> best orbit arraylist
while(tmp2.hasNext())% for each mission
    entr = tmp2.next();
    miss = entr.getKey;
    mmap = entr.getValue;%map containing all the orbits for one mission
    tmp = mmap.entrySet.iterator;
    min_penalty = Inf;
    best_orbit = java.util.ArrayList;
    best_orbits.put(miss,best_orbit);
    while(tmp.hasNext())% for each orbit in one mission
        entry = tmp.next();%orbit -> penalty
        if entry.getValue < min_penalty
            best_orbit = java.util.ArrayList;
            best_orbit.add(entry.getKey);
            best_orbits.put(miss,best_orbit);
            min_penalty = entry.getValue;
        elseif entry.getValue == min_penalty
            best_orbit.add(entry.getKey);
            best_orbits.put(miss,best_orbit);
        end
    end
end

%% arbitrarily choose first of top orbits and retract all unnecessary MANIFEST::Mission facts using rules
top_orbits = best_orbits.clone();
tmp = best_orbits.entrySet.iterator;
while tmp.hasNext()
    miss = tmp.next();
    many_orbits = miss.getValue;
    top_orbits.put(miss.getKey,many_orbits(1));
    str = many_orbits.iterator.next;% remove up to first dash
    tmp2 = find(str=='-');
    tmp3 = find(miss.getKey=='-');
    if isempty(tmp3)
        orbit_str = str(tmp2(1)+1:end);
    else
        orbit_str = str(tmp2(1+length(tmp3))+1:end);
    end
    % add rule to retract all unnecessary facts
    call = ['(defrule ORBIT-SELECTION::remove-suboptimal-rules-' char(miss.getKey)...
    ' "Remove Mission facts that have suboptimal orbits" ' ...
    ' ?miss <- (MANIFEST::Mission (Name ' char(miss.getKey) ') ' ...
    ' (in-orbit ?orb&:(neq ?orb "' char(orbit_str) '")))' ...
    ' =>' ...
    ' (retract ?miss)' ...
    ' )'];
    r.eval(call);
end
r.eval('(focus ORBIT-SELECTION)');
r.run;

% remove rules
list_rules = r.listDefrules();
while list_rules.hasNext()
    rule = list_rules.next().getName();
    if rule.startsWith('ORBIT-SELECTION::remove-suboptimal-rules')
        r.removeDefrule(rule)
    end
end
    
%% retract all ORBIT-SELECTION::orbit facts
facts = r.listFacts(); % iterator
while facts.hasNext()
    f = facts.next();
    if ~strcmp(f.getDeftemplate,'[deftemplate ORBIT-SELECTION::orbit]')
        continue
    else
        r.retract(f);
    end
end
clear facts f mission_map map mmap tmp2 best_orbit best_orbits min_penalty top_orbits many_orbits list_rules rule 

end