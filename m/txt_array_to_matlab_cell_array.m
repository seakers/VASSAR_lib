function arr = txt_array_to_matlab_cell_array(txt_array)
% Example: 
% txt_array = '['SSO','polar']';
% txt_list = txt_array_to_matlab_cell_array(txt_array);
arr = regexp(txt_array(2:end-1),',','split');

end