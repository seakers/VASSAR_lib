function RBES_how_is_subobj_satisfied(subobj)
r = global_jess_engine();
call = ['(bind ?results (run-query* REASONING::who-satisfies-subobj ' subobj '))'];
r.eval(call);
jess bind ?count 0
jess while (?results next) (bind ?who (?results getString who)) (bind ?count (+ ?count 1)) (printout t ?count ":" ?who crlf);
% jess bind ?who (?results getString who);
% jess bind ?att (?results getString att);

% who = jess_value(r.eval('?who'));
% att = jess_value(r.eval('?att'));
end