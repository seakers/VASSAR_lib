function [] = for_each_subdir(command_string, param)
% For each immediate subdirectory of the current one, change into it and
% call eval(command_string). param is there so it can be referenced by the
% command string.
%
% Example call:
%     for_each_subdir('disp(pwd())');
    
    %iterate over the subdirectories.
    subdirs = dir('.');
    for i = 1:length(subdirs)
        if ~subdirs(i).isdir, continue; end;
        if strcmp(subdirs(i).name, '.'), continue; end;
        if strcmp(subdirs(i).name, '..'), continue; end;
        if strcmp(subdirs(i).name, 'html'), continue; end; % Matlab publishing

        cd(subdirs(i).name);
            eval(command_string);
        cd('..');
    end
end