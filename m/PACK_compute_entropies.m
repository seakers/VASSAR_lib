function entropies = PACK_compute_entropies(archs)
narc = size(archs,1);
entropies = zeros(narc,1);
for i = 1:narc
    entropies(i) = PACK_entropy(archs(i,:));
end
end