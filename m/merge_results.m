function [new_results,new_archs] = merge_results(archs1,results1,archs2,results2)
new_archs = [archs1;archs2];
names = fieldnames(results1);
new_results = results1;
for i = 1:length(names)
    values1 = getfield(results1,names{i});
    values2 = getfield(results2,names{i});
    setfield(new_results,names{i},[values1;values2]);
end
end