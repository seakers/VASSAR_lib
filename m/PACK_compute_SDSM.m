function [S_DSM] = PACK_compute_SDSM()
global params

N = length(params.packaging_instrument_list);% num of instruments
payloads = combnk(params.packaging_instrument_list,2);% this is a (N*(N-1),2) cell
S_DSM = zeros(N,N);

n = 1;
for i = 1:N
    for j = 1:N
        if i < j
            fprintf('Computing synergy between %s and  %s...\n',payloads{n,1},payloads{n,2});
            ind1 = find(strcmp(params.packaging_instrument_list,payloads{n,1}),1);
            ind2 = find(strcmp(params.packaging_instrument_list,payloads{n,2}),1);
            S_DSM(ind1,ind2) = RBES_compute_synergy(payloads{n,1},payloads{n,2},0);
            n = n + 1;
        end
    end
end

filepath = params.path_save_results;
RBES_graph_DSM(params.packaging_instrument_list,S_DSM,'green-red',[filepath 'S_DSM.gv']);
end
        