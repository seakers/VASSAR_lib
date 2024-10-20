function merged = merge_sats(orig,s1,s2)
merged = orig;
sat1 = orig{s1};
sat2 = orig{s2};
merged{min(s1,s2)} = unique([sat1 sat2]);
merged{max(s1,s2)} = [];
end