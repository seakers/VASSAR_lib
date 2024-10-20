function txt_list = txt_array_to_jess_list(txt_array)
% txt_array = '[0.1,2.5,3]';
% Example: txt_list = txt_array_to_jess_list('[0.1,2.5,3]');
% fprintf('txt_array_to_jess_list %s\n',txt_array);
tmp = regexprep(txt_array, ',', ' ');
tmp2 = tmp(2:end-1);
txt_list = ['(create$ ' tmp2 ')'];
end