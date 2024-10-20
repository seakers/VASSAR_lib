%% selection_packaging_orbit_size.m
function narc = selection_packaging_orbit_size(N,np,ns,norb)
    narc = 0;
    for ni = 1:N
        narc_ni = 0;
        for nsat = 1:ni
            narc_ni = narc_ni + stirling(ni,nsat)*(np*ns*norb)^nsat;
        end
        narc = narc + nchoosek(N,ni)*narc_ni;
    end
end