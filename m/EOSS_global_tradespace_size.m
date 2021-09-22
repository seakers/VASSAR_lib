%% EOSS_global_tradespace_size.m
Nvec = 2:30;
narc_vec = zeros(length(Nvec),1);
bellies = zeros(length(Nvec),1);
factos = zeros(length(Nvec),1);
products = zeros(length(Nvec),1);
for i = 1:length(Nvec)
    N = Nvec(i);
    narc = 0;
    for ni = 1:N
    narc_ni = 0;
    for ns = 1:ni
        narc_ni = narc_ni + stirling(ni,ns)*factorial(ns);
    end
    narc = narc + nchoosek(N,ni)*narc_ni;
    end
    narc_vec(i) = narc;
    bellies(i) = Bell(N);
    factos(i) = factorial(N);
    products(i) = (2^N)*Bell(N)*factorial(N);
end
semilogy(Nvec,narc_vec,'g',Nvec,bellies,'r',Nvec,factos,'b',Nvec,products,'k');