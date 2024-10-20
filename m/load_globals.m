function [r] = load_globals(r)
[num,txt]= xlsread('C:\Documents and Settings\Dani\My Documents\PhD\research\projects\Rule-based System Architecting\ObjectiveDefinition','GlobalVariables');
pref = '(defglobal ';
mid = ' = ';
suff = ')';
for i = 1:length(txt)
    call = [pref txt{i} mid num2str(num(i)) suff];
    r.eval(call);
end
return