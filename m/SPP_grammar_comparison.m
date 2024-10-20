%% SPP_grammar_comparison.m
function [avg_time, std_time, avg_n, std_n] = SPP_grammar_comparison(ITS,m)
r = global_jess_engine();
times = zeros(1,ITS);
narcs = zeros(1,ITS);
for i = 1:ITS
    jess batch "C:\\Users\\dani\\Documents\\My Dropbox\\PhD\\PhD dissertation\\Thesis CLIPS code\\code2.clp";
%     jess batch "C:\\Users\\dani\\Documents\\My Dropbox\\PhD\\PhD dissertation\\Thesis CLIPS code\\code3.clp";
    pause(5);
    tic;
    jess run;
    times(i) = toc;
    tmp = r.eval('(count-query-results TEST::count-SPP-architectures)');
    narcs(i) = jess_value(tmp)/Bell(m);
    fprintf('It %d: t = %f, arcs = %f\n',i,times(i),narcs(i));
end
avg_time = mean(times);std_time=std(times);
avg_n = mean(narcs);std_n = std(narcs);
% figure;boxplot(times);
% figure;boxplot(narcs);
end
