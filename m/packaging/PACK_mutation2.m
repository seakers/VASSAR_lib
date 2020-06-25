function mutationChildren = PACK_mutation2(parents,options,GenomeLength,FitnessFcn,state,thisScore,thisPopulation,scale,shrink)
% PACK_mutation2.m
% 4 different possible mutations that occur with equal probability:
% a) one random instrument gets moved into a different random satellite
% b) a random large satellite gets broken into two by a random place
% c) two small random satellites get combined
% d) two random instruments exchange position
% 
% Daniel Selva, Oct 1st 2011

mutationChildren = zeros(length(parents),GenomeLength);
for i=1:length(parents)
    parent = thisPopulation(parents(i),:);
%     parent = thisPopulation{parents(i),:};
    new_ind = parent;
    mutated = false;
    while(~mutated)
        u = rand;
        if u<0.25
            %Single instrument
            pos = randi(length(new_ind));% instrument position to change
            old = new_ind(pos);
            new = old;
            while new==old
                new = randi(max(new_ind)+1);% can go to any previous sat or a new one
            end
            new_ind(pos) = new;
            
        elseif u<0.5
            % Break big satellite
            sats = PACK_arch2sats(new_ind);
            ninstrxsat = cellfun(@length,sats);
            bigsats = find(ninstrxsat > 3);
            if ~isempty(bigsats)
                ind = randi(length(bigsats));
                sat = bigsats(ind);% this sat index to be broken up
                sats = break_sat(sats,sat);
            end
            new_ind = PACK_sats2arch(sats);
            
        elseif u<0.75
            % Combine 2 small satellites
            sats = PACK_arch2sats(new_ind);
            ninstrxsat = cellfun(@length,sats);
            smallsats = find(ninstrxsat < 3);
            if ~isempty(smallsats)
                same = true;
                while(same)
                    ind = randi(length(smallsats),[1 2]);% indices of sats to combine
                    same = isequal(ind./max(ind),ones(1,2));
                end
                sat1 = smallsats(ind(1));% sats to combine
                sat2 = smallsats(ind(2));
                sats = merge_sats(sats,sat1,sat2);
            end
            new_ind = PACK_sats2arch(sats);
            
        else        
            % Swap 2 instruments
            same = true;
            same_sat = true;
            while(same || same_sat)
                ind = randi(length(new_ind),[1 2]);% indices of instruments to swap
                same = isequal(ind./max(ind),ones(1,2));
                same_sat = (new_ind(ind(1)) == new_ind(ind(2)));
            end
            tmp = new_ind(ind(2));%backup second instrument
            new_ind(ind(2)) = new_ind(ind(1));
            new_ind(ind(1)) = tmp;
            
        end
        new_ind = PACK_fix(new_ind);
        if ~isequal(PACK_fix(parent),new_ind)
            mutated = true;
        end
            
    end
    mutationChildren(i,:) = new_ind;
end

