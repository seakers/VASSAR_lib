function [science,cost,u] = RBES_eval_pack(r,params,arch)
db_pack = get_db_pack(params.db_pack_file);
%arch = archit.packaging;
if db_pack.containsKey(arch)
    metrics = db_pack.get(arch);
    science = metrics(1);
    cost = metrics(2);
    
else
    [science,cost,~] = PACK_evaluate_architecture(r,params,arch);
end
u_science = (science - 0.06)./(0.09- 0.06);
au_cost = (cost - 3500)./(4300- 3500);% negative utility
u = params.WEIGHTS*[u_science; 1 - au_cost];

end

    