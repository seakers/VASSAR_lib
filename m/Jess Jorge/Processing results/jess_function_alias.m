function [] = jess_function_alias(jess_function, matlab_function)
    % Now the Matlab function could be called asynchronously from another
    % thread. For Matlab to recognize the function, this folder must be
    % temporarily set as the working directory.
    % So Jess will tell Matlab to come here, call the callback handler, and
    % return to wherever it was.
    
    function_dir = pwd();
%     [thisdir, ~, ~] = fileparts(mfilename('fullpath'));
    function_dir = ['"' regexprep(function_dir, '\', '\\\') '"'];
    
    jess({'deffunction' jess_function '($?argv)' ...
            '(bind ?previous-dir (matlabf pwd))' ...
            '(matlabf cd' function_dir ')' ...
            '(matlabf' matlab_function '$?argv)' ...
            '(matlabf cd ?previous-dir)'});
end