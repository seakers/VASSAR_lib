function new = PACK_fix_archs(archs)
narc = size(archs,1);
for i = 1:narc
    new(i,:) = PACK_fix(archs(i,:));
end
end
