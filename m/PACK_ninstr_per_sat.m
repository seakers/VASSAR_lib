function ninstr = PACK_ninstr_per_sat(archs)
narc = size(archs,1);
ninstr = cell(narc,1);
for i = 1:narc
    ninstr{i} = cellfun(@length,PACK_arch2sats(archs(i,:)));
%     fprintf('Arch %d: %s %s\n',i,num2str(ninstr{i}'),PACK_arch_to_str(archs(i,:)));
end
end