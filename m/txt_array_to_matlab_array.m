function arr = txt_array_to_matlab_array(txt_array)
% txt_array = '[0.1,2.5,3]';
% Example: txt_list = txt_array_to_matlab_array('[0.1,2.5,3]');
arr = str2double(regexp(txt_array(2:end-1),',','split'));

end