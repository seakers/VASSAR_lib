function comparison = SEL_compare_archs(arch1,arch2)
%% SEL_compare_archs.m
%
% a1 = SEL_get_arch_from_results(results,3)
% Usage: SEL_compare_archs(a1,used_params.ref_sel_arch)

global params
fprintf('************************************************************\n');
fprintf('************************************************************\n');
fprintf('Arch1: Science = %f, Cost = %f, #instruments = %d\n',arch1.science,arch1.cost,sum(arch1.arch));
fprintf('Arch2: Science = %f, Cost = %f, #instruments = %d\n',arch2.science,arch2.cost,sum(arch2.arch));
fprintf('Arch1 has %2.1f pct higher science and %2.1f pct higher cost than arch2, with %d more instruments\n',100*(arch1.science-arch2.science)/arch2.science,100*(arch1.cost-arch2.cost)/arch2.cost,sum(arch1.arch)-sum(arch2.arch));

fprintf('************************************************************\n');

arr = params.instrument_list(logical(arch1.arch));
str = StringArraytoStringWithSpaces(arr);
fprintf('Arch1: Payload = %s\n',str);
arr = params.instrument_list(logical(arch2.arch));
str = StringArraytoStringWithSpaces(arr);
fprintf('Arch2: Payload = %s\n',str);
fprintf('************************************************************\n');

diff = arch2.arch - arch1.arch; % [ 0 0 -1 0 1] 1 means 2 has instrument i but not 1, -1 the opposite
tmp = params.instrument_list(diff==-1);
if ~isempty(tmp), instr_1has_2doesnt = StringArraytoStringWithSpaces(tmp);else instr_1has_2doesnt = [];end

tmp = params.instrument_list(diff==1);
if ~isempty(tmp), instr_2has_1doesnt = StringArraytoStringWithSpaces(tmp);else instr_2has_1doesnt = [];end

fprintf('Instruments that arch1 has and arch2 doesnt:\n');
fprintf('%s\n',instr_1has_2doesnt);

fprintf('Instruments that arch2 has and arch1 doesnt:\n');
fprintf('%s\n',instr_2has_1doesnt);
fprintf('************************************************************\n');

 R = input('Would you like to evaluate both architectures to get lists?(y/n): ','s');
 if strcmp(R,'y')
     fprintf('\n');
     r = global_jess_engine();
     [s1,c1,comparison.lists1] = SEL_evaluate_architecture_with_lists(r,params,arch1.arch);
     [s2,c2,comparison.lists2] = SEL_evaluate_architecture_with_lists(r,params,arch1.arch);
 else
     comparison =  [];
 end
 fprintf('End of comparison\n');
 fprintf('************************************************************\n');


end
