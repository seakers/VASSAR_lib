function comparison = SCHED_compare_archs(arch1,arch2)
%% SCHED_compare_archs.m
%
% a1 = SCHED_get_arch_from_results(results,3)
% Usage: SCHED_compare_archs(a1,used_params.ref_sel_arch)

global params
fprintf('************************************************************\n');
fprintf('************************************************************\n');
fprintf('Arch1: Discounted value = %f, Data continuity = %f\n',arch1.discounted_value,arch1.data_continuity);
fprintf('Arch2: Discounted value = %f, Data continuity = %f\n',arch2.discounted_value,arch2.data_continuity);
fprintf('************************************************************\n');
fprintf('Arch1: %s\n',SCHED_arch_to_str(arch1.arch));
fprintf('Arch2: %s\n',SCHED_arch_to_str(arch2.arch));
fprintf('************************************************************\n');

% diff = arch2.arch - arch1.arch; % [ 0 0 -1 0 1] 1 means 2 has instrument i but not 1, -1 the opposite
% instr_1has_2doesnt = StringArraytoStringWithSpaces(params.instrument_list(diff==-1));
% instr_2has_1doesnt = StringArraytoStringWithSpaces(params.instrument_list(diff==1));
% fprintf('Instruments that arch1 has and arch2 doesnt:\n');
% fprintf('%s\n',instr_1has_2doesnt);
% 
% fprintf('Instruments that arch2 has and arch1 doesnt:\n');
% fprintf('%s\n',instr_2has_1doesnt);
% fprintf('************************************************************\n');
% 
%  R = input('Would you like to evaluate both architectures to get lists?(y/n): ','s');
%  if strcmp(R,'y')
%      fprintf('\n');
%      r = global_jess_engine();
%      [s1,c1,comparison.lists1] = SEL_evaluate_architecture_with_lists(r,params,arch1.arch);
%      [s2,c2,comparison.lists2] = SEL_evaluate_architecture_with_lists(r,params,arch1.arch);
%  else
%      comparison =  [];
%  end
 fprintf('End of comparison\n');
 fprintf('************************************************************\n');


end
