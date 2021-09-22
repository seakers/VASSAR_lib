function [success] = jess_remove_template(template)
    try
        j = global_jess_engine();
        j.removeDeftemplate(template);
        success = true;
    catch
        success = false;
    end
end