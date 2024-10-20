function txt_list = txt_array_to_cell_txt_array(txt_array)
% txt_array = '[0.1,2.5,3]';
% Example: txt_list = txt_array_to_cell_txt_array('["hola","si"]')
txt_list = depack_cellofcells(regexp(txt_array(2:end-1),'''([^'']+)''','tokens'));

end