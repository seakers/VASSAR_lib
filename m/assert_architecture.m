function assert_architecture(arch)
type = arch.type;

seq = arch.seq;
if isfield(arch,'utility')
    u = arch.utility;
else
    u = [];
end

if isfield(arch,'science')
    s = arch.science;
else
    s = [];
end

if isfield(arch,'discounted_value')
    d = arch.discounted_value;
else
    d = [];
end

if isfield(arch,'data_continuity')
    dc = arch.data_continuity;
else
    dc = [];
end

if isfield(arch,'cost')
    c = arch.cost;
else
    c = [];
end


if isfield(arch,'pareto_ranking')
    p = arch.pareto_ranking;
else
    p = [];
end

if isfield(arch,'risk')
    ri = arch.risk;
else
    ri = [];
end

if isfield(arch,'launch_risk')
    ri2 = arch.launch_risk;
else
    ri2 = [];
end

if isfield(arch,'fairness')
    f = arch.fairness;
else
    f = [];
end

if isfield(arch,'fit')
    fi = arch.fit;
else
    fi = [];
end

if isfield(arch,'instrument_orbits')
    orb = arch.instrument_orbits;
else
    orb = [];
end

if isfield(arch,'lv_pack_factors')
    pac = arch.lv_pack_factors;
else
    pac = [];
end

r = global_jess_engine();
if (strcmp(type,'selection'))
    instr = arch.instruments;
    if(isempty(seq))
        r.eval(['(assert (HARD-CONSTRAINTS::SEL-ARCH (selected-instruments ' instr ' ) ))']);
    elseif isempty(u)
        r.eval(['(assert (HARD-CONSTRAINTS::SEL-ARCH (selected-instruments ' instr ' ) (sequence  ' num2str(seq) ' ) ))']);
    elseif isempty(fi)
        r.eval(['(assert (HARD-CONSTRAINTS::SEL-ARCH (selected-instruments ' instr ' ) (sequence  ' num2str(seq)  ...
            ') (science ' num2str(s) ' ) (cost ' num2str(c) ' ) (utility ' num2str(u) ' ) (pareto-ranking ' num2str(p)  ' )' ...
            ' (programmatic-risk ' num2str(ri)  ' )  (fairness ' num2str(f)  ' )))']);
    else
        r.eval(['(assert (HARD-CONSTRAINTS::SEL-ARCH (selected-instruments ' instr ' ) (sequence  ' num2str(seq)  ...
            ') (science ' num2str(s) ' ) (cost ' num2str(c) ' ) (fit ' num2str(fi) ') (utility ' num2str(u) ' ) (pareto-ranking ' num2str(p)  ' )' ...
            ' (programmatic-risk ' num2str(ri)  ' )  (fairness ' num2str(f)  ' )))']);
    end    
elseif (strcmp(type,'packaging'))
    if(isempty(u))
        r.eval(['(assert (HARD-CONSTRAINTS::PACK-ARCH (assignments (create$ ' num2str(seq) ' )) (str "' PACK_arch_to_str(seq) '")))']);
    elseif (isempty(dc))
        r.eval(['(assert (HARD-CONSTRAINTS::PACK-ARCH (assignments (create$ ' num2str(seq) ' )) (str "' PACK_arch_to_str(seq) '") ' ...
            '(science ' num2str(s) ' ) (cost ' num2str(c) ' ) (utility ' num2str(u) ' ) (pareto-ranking ' num2str(p)  ' )' ...
            ' (programmatic-risk ' num2str(ri)  ' )  (launch-risk ' num2str(ri2)  ')' ...
            '))']);
    elseif isempty(orb)
        r.eval(['(assert (HARD-CONSTRAINTS::PACK-ARCH (assignments (create$ ' num2str(seq) ' )) (str "' PACK_arch_to_str(seq) '") ' ...
            '(science ' num2str(s) ' ) (cost ' num2str(c) ' ) (utility ' num2str(u) ' ) (pareto-ranking ' num2str(p)  ' )' ...
            ' (programmatic-risk ' num2str(ri)  ' ) (data-continuity ' num2str(dc)  ' ) (launch-risk ' num2str(ri2)  ')' ...
            '))']);
    else
        r.eval(['(assert (HARD-CONSTRAINTS::PACK-ARCH (assignments (create$ ' num2str(seq) ' )) (str "' PACK_arch_to_str(seq) '") ' ...
            '(science ' num2str(s) ' ) (cost ' num2str(c) ' ) (utility ' num2str(u) ' ) (pareto-ranking ' num2str(p)  ' )' ...
            ' (programmatic-risk ' num2str(ri)  ' ) (data-continuity ' num2str(dc)  ' ) (launch-risk ' num2str(ri2)  ')' ...
            ' (instrument-orbits (create$ ' StringArraytoStringWithSpaces(orb) ' )) ' ...
            ' (launch-pack-factors (create$ ' num2str(pac') ' )) ' ...
            '))']);
    end

elseif (strcmp(type,'assigning'))
    if(isempty(u))
        r.eval(['(assert (HARD-CONSTRAINTS::ASSIGN-ARCH (assignments (create$ ' num2str(seq) ' )) (str "' ASSIGN_arch_to_str(seq) '")))']);
    else
        r.eval(['(assert (HARD-CONSTRAINTS::ASSIGN-ARCH (assignments (create$ ' num2str(seq) ' )) (str "' ASSIGN_arch_to_str(seq) '") ' ...
            '(science ' num2str(s) ' ) (cost ' num2str(c) ' ) (utility ' num2str(u) ' ) (pareto-ranking ' num2str(p)  ' )' ...
            '))']);
    end
    
elseif (strcmp(type,'scheduling'))
    if(isempty(u))
        r.eval(['(assert (HARD-CONSTRAINTS::PERMUTING-ARCH (sequence (create$ ' num2str(seq) ' )) (str "' SCHED_arch_to_str(seq) '")))']);
    else
        r.eval(['(assert (HARD-CONSTRAINTS::PERMUTING-ARCH (sequence (create$ ' num2str(seq) ' )) (str "' SCHED_arch_to_str(seq) '") ' ...
            ' (utility ' num2str(u) ' ) (pareto-ranking ' num2str(p)  ' )' ...
            ' (discounted-value ' num2str(d)  ' ) (data-continuity ' num2str(dc)  ' ) (programmatic-risk ' num2str(ri)  ' ) (fairness ' num2str(f)  ')' ...
            '))']);
    end
end