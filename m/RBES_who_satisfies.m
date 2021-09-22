function candidate_instruments = RBES_who_satisfies(obj)
%% RBES_who_satisfies.m
global params
candidate_instruments = params.objectives_to_instruments.get(obj);
end