function struct = set_subobj_score(struct,subobj,val)
[p,o,so] = RBES_subobj_to_indexes(subobj(8:end));
struct{p}{o}(so) = val;
end