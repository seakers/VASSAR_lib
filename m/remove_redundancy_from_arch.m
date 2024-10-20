function new_seq = remove_redundancy_from_arch(seq)
%% remove_redundancy_from_arch.m
global params

% get list of objectives satisfied
instr_list = params.instrument_list(logical(de2bi(seq,length(params.instrument_list))));
obj_list = RBES_objectives_from_instrument_list(instr_list);

% sort objectives from most satisfied to least satisfied
[sorted_elements,~] = sort_array_elements_by_nocurrences(obj_list);

% take the most satisfied and find the instruments who satisfy them
obj = sorted_elements{1};
candidate_instruments = params.objectives_to_instruments.get(obj);

% sort these instruments by number of other objectives they satisfy
num_objs = zeros(candidate_instruments.size,1);
for i = 1:candidate_instruments.size
    obj_list2 = params.instruments_to_objectives.get(candidate_instruments.get(i-1));
    num_objs(i) = obj_list2.size;
end

% pick the instrument that satisfied fewer objectives other than that one
[~,in] = min(num_objs);
instr = candidate_instruments.get(in-1);
% disp(instr);

% remove that instrument from sequence
pos = strcmp(params.instrument_list,instr);
bi = de2bi(seq,length(params.instrument_list));
bi(pos) = false;
new_seq = bi2de(bi);
end