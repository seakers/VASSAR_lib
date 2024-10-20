function RBES_explanations
global params
r = global_jess_engine();
if params.WATCH, fprintf('Explanations...\n'); end
r.eval('(focus REASONING)');
r.run(10000);
end