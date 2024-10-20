function assert_hard_constraint(varargin)
type = varargin{1};
value = varargin{2};
if nargin > 2
    value2 = varargin{3};
end

r = global_jess_engine();
if (strcmp(type,'fix-instruments'))
    r.eval(['(assert (HARD-CONSTRAINTS::FIX-INSTRUMENTS (instruments ' value ' )))']);
elseif (strcmp(type,'or-instruments'))
    r.eval(['(assert (HARD-CONSTRAINTS::OR-INSTRUMENTS (instruments ' value ' )))']);
elseif (strcmp(type,'group-instruments'))
    r.eval(['(assert (HARD-CONSTRAINTS::GROUP-INSTRUMENTS (instruments ' value ' )))']);
elseif (strcmp(type,'xor-instruments'))
    r.eval(['(assert (HARD-CONSTRAINTS::XOR-INSTRUMENTS (instruments ' value ' )))']);
elseif (strcmp(type,'support-instruments'))
    r.eval(['(assert (HARD-CONSTRAINTS::SUPPORT-INSTRUMENTS (instruments ' value ' )))']);
elseif (strcmp(type,'not-instruments'))
    r.eval(['(assert (HARD-CONSTRAINTS::NOT-INSTRUMENTS (instruments ' value ' )))']);%N-out-of-K-instruments
 elseif (strcmp(type,'N-out-of-K-instruments'))
    r.eval(['(assert (HARD-CONSTRAINTS::EXACTLY-N-OUT-OF-K-CONSTRAINT (instruments ' value ' ) (N ' value2 ')))'])
    
elseif (strcmp(type,'together-instruments'))
    r.eval(['(assert (HARD-CONSTRAINTS::TOGETHER-INSTRUMENTS (instruments ' value ' )))']);
elseif (strcmp(type,'apart-instruments'))
    r.eval(['(assert (HARD-CONSTRAINTS::APART-INSTRUMENTS (instruments ' value ' )))']);
elseif (strcmp(type,'alone-instruments'))
    r.eval(['(assert (HARD-CONSTRAINTS::ALONE-INSTRUMENTS (instruments ' value ' )))']);
elseif (strcmp(type,'max-instrs-per-sat'))
    r.eval(['(assert (HARD-CONSTRAINTS::MAX-INSTRS-PER-SAT (max-instruments-per-satellite# ' value ' )))']);
elseif (strcmp(type,'max-sats'))
    r.eval(['(assert (HARD-CONSTRAINTS::MAX-SATS (max-sats# ' value ' )))']);

elseif (strcmp(type,'before-constraints'))
    value = num2str(SCHED_str_to_arch(value));
    value2 = num2str(SCHED_str_to_arch(value2));
    r.eval(['(assert (HARD-CONSTRAINTS::BEFORE-CONSTRAINT (element ' value ' ) (before ' value2 ' )))']);
elseif (strcmp(type,'after-constraints'))
    value = num2str(SCHED_str_to_arch(value));
    value2 = num2str(SCHED_str_to_arch(value2));
    r.eval(['(assert (HARD-CONSTRAINTS::AFTER-CONSTRAINT (element ' value ' ) (after ' value2 ' )))']);
elseif (strcmp(type,'between-constraints'))
    value = num2str(SCHED_str_to_arch(value));
    value2 = num2str(SCHED_str_to_arch(value2));
    r.eval(['(assert (HARD-CONSTRAINTS::BETWEEN-CONSTRAINT (element ' value ' ) (between ' value2 ' )))']);
elseif (strcmp(type,'not-between-constraints'))
    value = num2str(SCHED_str_to_arch(value));
    value2 = num2str(SCHED_str_to_arch(value2));
    r.eval(['(assert (HARD-CONSTRAINTS::NOT-BETWEEN-CONSTRAINT (element ' value ' ) (not-between ' value2 ' )))']);


elseif (strcmp(type,'before-date-constraints'))
    value = num2str(SCHED_str_to_arch(value));
    r.eval(['(assert (HARD-CONSTRAINTS::BEFORE-DATE-CONSTRAINT (element ' value ' ) (before ' value2 ' )))']);
elseif (strcmp(type,'after-date-constraints'))
    value = num2str(SCHED_str_to_arch(value));
    r.eval(['(assert (HARD-CONSTRAINTS::AFTER-DATE-CONSTRAINT (element ' value ' ) (after ' value2 ' )))']);
elseif (strcmp(type,'between-dates-constraints'))
    value = num2str(SCHED_str_to_arch(value));
    r.eval(['(assert (HARD-CONSTRAINTS::BETWEEN-DATES-CONSTRAINT (element ' value ' ) (between ' value2 ' )))']);
elseif (strcmp(type,'not-between-dates-constraints'))
    value = num2str(SCHED_str_to_arch(value));
    r.eval(['(assert (HARD-CONSTRAINTS::NOT-BETWEEN-DATES-CONSTRAINT (element ' value ' ) (not-between ' value2 ' )))']);
    
elseif (strcmp(type,'contiguity-constraints'))
    value = num2str(SCHED_str_to_arch(value));
    r.eval(['(assert (HARD-CONSTRAINTS::CONTIGUITY-CONSTRAINT (elements ' value ' )))']);
elseif (strcmp(type,'non-contiguity-constraints'))
    value = num2str(SCHED_str_to_arch(value));
    r.eval(['(assert (HARD-CONSTRAINTS::NON-CONTIGUITY-CONSTRAINT (elements ' value ' )))']);
elseif (strcmp(type,'subsequence'))
    value = num2str(SCHED_str_to_arch(value));
    r.eval(['(assert (HARD-CONSTRAINTS::SUBSEQUENCE-CONSTRAINT (subsequence ' value ' )))']);

elseif (strcmp(type,'by-beginning-constraints'))
    value = num2str(SCHED_str_to_arch(value));
    r.eval(['(assert (HARD-CONSTRAINTS::BY-BEGINNING-CONSTRAINT (elements ' value ' )))']);
elseif (strcmp(type,'by-end-constraints'))
    value = num2str(SCHED_str_to_arch(value));
    r.eval(['(assert (HARD-CONSTRAINTS::BY-END-CONSTRAINT (elements ' value ' )))']);
elseif (strcmp(type,'fix-position-constraints'))
    value = num2str(SCHED_str_to_arch(value));
    r.eval(['(assert (HARD-CONSTRAINTS::FIX-POSITION-CONSTRAINT (element ' value ' ) (position ' value2 ' )))']);
    

else
end

end
