function plot_attrib(att,type)    
    [~,values] = get_all_data('REQUIREMENTS::Measurement',{att},{type},0);
    vals = depack_cellofcells(values);
    plot(vals);
end