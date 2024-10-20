function [success] = jess_remove_rule(rule)
    try
        j = global_jess_engine();
        j.removeDefrule(rule);
        success = true;
    catch
        success = false;
    end
end