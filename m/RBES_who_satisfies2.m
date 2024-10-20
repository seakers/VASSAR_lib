function candidate_instruments = RBES_who_satisfies2(subobj)
%% RBES_who_satisfies2.m
global params
candidate_instruments = params.subobjectives_to_instruments.get(subobj);
end