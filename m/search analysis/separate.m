function ind = separate(decisions,insts)
%finds the architectures that have the array of instruments insts separate
%from all payloads

%number of instruments
ninst = 12;
%number of orbits
norb = 5;

ind = true(size(decisions,1),1);

for i=1:size(decisions,1)
    %reshape the vector to a nxm matrix where n is the number of
    %instruments and m is the number of orbits
    mat = reshape(decisions(i,:),norb,ninst)';
    together = true;
    for j = 1:norb
        for k=1:length(insts)
            if (mat(insts(k),j) == 0)
                together = false;
                break;
            end
        end
        if together
            ind(i) = false;
            continue;
        end
    end
    
end