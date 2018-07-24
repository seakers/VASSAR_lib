function ind = absent(decisions,inst)
%finds the architectures that have the instrument absent
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
    for j = 1:norb
        if mat(inst,j) == 1
            ind(i) = false;
            break;
        end
    end
end