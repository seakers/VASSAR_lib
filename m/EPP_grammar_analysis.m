%% EPP_grammar_analysis.m
m_vec = 6:9;
% r2 = jess.Rete;
P = 0.8;


%% Deterministic results

fprintf('deterministic results\n:');
t_vec = zeros(1,length(m_vec));
narcs = zeros(1,length(m_vec));
avg_time_per_arch = zeros(1,length(m_vec));

for i = 1:length(m_vec)
    
    m = m_vec(i);
    fprintf('#elements = %d...',m);
    r2.eval('(clear)');
    r2.eval('(defmodule TEST)');
    r2.eval('(deftemplate TEST::PERMUTING-ARCH (multislot sequence))');
    r2.eval(['(deffunction rare-randb (?p) (return (< (random) (* ?p 65536))))']);
   %% all 
    call = ['(defrule TEST::enumerate-all-partitions ' ...
        '"This rule enumerates all possible subsets in a set of m elements" ' ...
        '?arch <- (TEST::PERMUTING-ARCH (sequence $?seq)) ' ...
        '(test (< (length$ $?seq) ' num2str(m) ' ))' ...
        '=> ' ...
        '(retract ?arch)   ' ...
        '  (bind ?n (length$ ?seq))' ...
        '(for (bind ?i 1) (<= ?i ' num2str(m) ' ) (++ ?i)  ' ...
        '(if (eq (member$ ?i ?seq) FALSE) then  ' ...
          '  (bind ?new-seq (insert$ ?seq (+ ?n 1) ?i)) ' ...
       ' (assert (TEST::PERMUTING-ARCH (sequence ?new-seq))) ' ...
           ' )' ...
        ')' ... 
        ')'];

    r2.eval(call);

    %% 
    call = '(defquery TEST::count-EPP-architectures (TEST::PERMUTING-ARCH (sequence $?seq)))';
    r2.eval(call);
    
    r2.reset;
    r2.eval('(assert (TEST::PERMUTING-ARCH (sequence (create$ ))))');
    r2.eval('(focus TEST)');
    r2.eval('(unwatch all)');
    pause(1);
    tic;
    r2.run;
    t_vec(i) = toc;
    tmp = r2.eval('(count-query-results TEST::count-EPP-architectures)');
    narcs(i) = jess_value(tmp);
    avg_time_per_arch(i) = t_vec(i)/narcs(i);
    fprintf(' time = %f, arcs = %f, time per arch = %f\n',t_vec(i),narcs(i),avg_time_per_arch(i));
end

%% Random results
fprintf('Random results for P  = %d\n:',P);
t_vec2 = zeros(1,length(m_vec));
narcs2 = zeros(1,length(m_vec));
avg_time_per_arch2 = zeros(1,length(m_vec));
NITS = 20;
for i = 1:length(m_vec)
    
    m = m_vec(i);
    fprintf('#elements = %d\n',m);
    t_vec3 = zeros(1,NITS);
    narcs3 = zeros(1,NITS);
    avg_time_per_arch3 = zeros(1,NITS);
    for it = 1:NITS
        fprintf('#it = %d...',it);
        r2.eval('(clear)');
        r2.eval('(defmodule TEST)');
        r2.eval('(deftemplate TEST::PERMUTING-ARCH (multislot sequence))');
        r2.eval('(deffunction rare-randb (?p) (return (< (random) (* ?p 65536))))');


        call = ['(defrule TEST::enumerate-some-partitions ' ...
            '"This rule enumerates all possible subsets in a set of m elements" ' ...
            '?arch <- (TEST::PERMUTING-ARCH (sequence $?seq) ) ' ...
            '(test (< (length$ $?seq) ' num2str(m) ' ))' ...
            '=> ' ...
            '(retract ?arch)   ' ...
            '(bind ?n (length$ ?seq))' ...
            '(for (bind ?i 1) (<= ?i ' num2str(m) ') (++ ?i)  ' ...
            '(if (eq (member$ ?i ?seq) FALSE) then  ' ...
              '  (bind ?new-seq (insert$ ?seq (+ ?n 1) ?i)) ' ...
           ' (if (rare-randb ' num2str(P) ' ) then (assert (TEST::PERMUTING-ARCH (sequence ?new-seq)))) ' ...
               ' )' ...
            ')' ... 
            ')'];
        r2.eval(call);

        call = '(defquery TEST::count-EPP-architectures (TEST::PERMUTING-ARCH (sequence $?seq)))';
        r2.eval(call);

        r2.reset;
        r2.eval('(assert (TEST::PERMUTING-ARCH (sequence (create$ ))))');
        r2.eval('(focus TEST)');
        r2.eval('(unwatch all)');
        pause(1);
        tic;
        r2.run;
        t_vec3(it) = toc;
        tmp = r2.eval('(count-query-results TEST::count-EPP-architectures)');
        narcs3(it) = jess_value(tmp);
        avg_time_per_arch3(it) = t_vec3(it)/narcs3(it);
        fprintf(' time = %f, arcs = %f, time per arch = %f\n',t_vec3(it),narcs3(it),avg_time_per_arch3(it));
    end
    t_vec2(i) = mean(t_vec3);
    narcs2(i) = mean(narcs3);
    avg_time_per_arch2(i) = mean(avg_time_per_arch3);
    fprintf('Avg time = %f, arcs = %f, time per arch = %f\n',t_vec2(i),narcs2(i),avg_time_per_arch2(i));
end
%% plot
close all;
figure;
plot(m_vec,t_vec,'bx-',m_vec,t_vec2,'rx-');
grid on
xlabel('# elements','FontSize',18)
ylabel('time to enumerate subsets (s)','FontSize',18);
leg = legend({'full factorial',['random P = ' num2str(P)]},'Location','Best');
set(leg,'FontSize',18);
% print('-dmeta','C:\Users\dani\Documents\My Dropbox\PhD\PhD dissertation\figures\EPP_grammar_performance2.emf');
print('-dmeta','C:\Users\Ana-Dani\Dropbox\PhD\PhD dissertation\figures\EPP_grammar_performance2.emf');


figure;
plot(m_vec,narcs,'bx-',m_vec,narcs2,'rx-');
grid on
xlabel('# elements','FontSize',18);
ylabel('# architectures enumerated','FontSize',18);
leg = legend({'full factorial',['random P = ' num2str(P)]},'Location','Best');
set(leg,'FontSize',18);
% print('-dmeta','C:\Users\dani\Documents\My Dropbox\PhD\PhD dissertation\figures\EPP_grammar_performance3.emf');
print('-dmeta','C:\Users\Ana-Dani\Dropbox\PhD\PhD dissertation\figures\EPP_grammar_performance3.emf');



