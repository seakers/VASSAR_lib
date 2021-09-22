function [new_results,new_archs] = SEL_look_around(these_archs,results,archs)
r = global_jess_engine();
instrument_list = RBES_get_parameter('instrument_list');

%% SEARCH
narc = length(these_archs);
seqs = zeros(1,narc);
for i = 1:narc
    a1 = SEL_get_arch_from_results(results,archs,these_archs(i));
    seqs(i) = get_seq_from_instr(instrument_list(logical(a1.arch')));
    call = ['(defrule SEARCH-HEURISTICS::mutation-swap-one-bit-sequence-' num2str(seqs(i)) ...
        '"This mutation function swaps the value of a single bit" ' ...
        '?arch <- (HARD-CONSTRAINTS::SEL-ARCH (sequence ' num2str(seqs(i)) ')) '...
        ' => ' ...
        ' (bind ?N ' num2str(length(instrument_list)) ' ) ' ...
        ' (for (bind ?i 0) (< ?i ?N) (++ ?i) ' ...
        ' (bind ?new-seq (matlabf mutate_one_bit ' num2str(seqs(i)) ')) ' ...
        ' (bind ?new-instr (explode$ (matlabf get_instr_from_seq ?new-seq))) ' ...
        ' (duplicate ?arch (sequence ?new-seq) (selected-instruments ?new-instr))))']; 
    r.eval(call);
    
end

jess focus SEARCH-HEURISTICS;
jess run;

% remove rules
for i = 1:narc
    call = ['(undefrule SEARCH-HEURISTICS::mutation-swap-one-bit-sequence-' num2str(seqs(i)) ')'];
    r.eval(call);
end

%% FILTER
% Apply hard constraints (run HARD-CONSTRAINTS)
% Add hard constraints
assert_hard_constraint('fix-instruments','AIRS AMSU-A HSB');% 607
assert_hard_constraint('xor-instruments','SCANSCAT SEAWINDS');
assert_hard_constraint('xor-instruments','GGI DORIS');
assert_hard_constraint('xor-instruments','MLS SAFIRE');% 610
assert_hard_constraint('xor-instruments','GLAS GLRS');
assert_hard_constraint('not-instruments','IPEI XIE GOS');
assert_hard_constraint('group-instruments','ALT-SSALT TMR'); % 613

% tic;
jess focus HARD-CONSTRAINTS;
jess run;

%% EVALUATION
% Evaluate them all
[new_archs,new_results] = SEL_evaluate_architectures;% archs are the binary arrays

end
