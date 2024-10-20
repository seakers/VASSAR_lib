%% selection_packaging_size.m
function narc = selection_packaging_size(N)
    narc = 0;
    for ni = 1:N
        narc_ni = 0;
        for ns = 1:ni
            narc_ni = narc_ni + stirling(ni,ns);
        end
        narc = narc + nchoosek(N,ni)*narc_ni;
    end
end