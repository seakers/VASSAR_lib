function init_pop = create_init_pop(pop_size)
%% create_init_pop.m
% Creates a matrix of size pop_size x N_INSTR where every row is one
% possible architecture given by the number of satellite assigned to each
% instrument.
% Example:  init_pop(1,:) = [1,1,1,1,1,1,1] is an architecture with 1sat
%           init_pop(2,:) = [1,1,2,3,4,4,4] is an arch with 4 sat
%           init_pop(3,:) = [1,2,3,4,5,6,7] is an arch with 7 sat

% The goal is to have a heterogenous population with architectures with 1
% to N_INSTR satellites.

init_pop = ones(pop_size,N_INSTR);

for i = 1:pop_size
    tmp = ones(1,N_INSTR);
    for n = 2:N_INSTR
%         tmp(n) = int8(1+round(max(tmp)*rand));
        tmp(n) = 1+round(max(tmp)*rand);
    end
    init_pop(i,:) = tmp;
end

%% Overwrite first architecture with one known feasible architecture
init_pop(1,:) = ones(1,N_INSTR);

%% Check for duplicates
% init_pop_nodup = unique(init_pop);
% num_duplicate = size(init_pop,1) - size(init_pop_nodup,1);
% if  num_duplicate > 0 % if there were duplicates
%     % we need to add additional architectures to the initial population
%     
% end


return
    