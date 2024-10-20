function distances = SEL_compute_distances_to_ref(archs)
narc = size(archs,1);
distances = zeros(narc,1);
ref = SEL_ref_arch();
for i = 1:narc
    distances(i) = sum((archs(i,:)-ref).^2);
end
end