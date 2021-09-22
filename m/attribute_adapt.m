function val_out = attribute_adapt(val_in)

    
if strncmp(val_in,'Very wide (>2000km)',6)
    val_out = 'Very-wide-2000km';
elseif strncmp(val_in,'Wide',4)
    val_out = 'Wide-1000km';
elseif strncmp(val_in,'Medium (~100km)',14)
    val_out = 'Medium-100km';
elseif strncmp(val_in,'Narrow(~10km)',5)
    val_out = 'Narrow-10km';
    
elseif strncmp(val_in,'Very High',6)
    val_out = 'Highest';
elseif strncmp(val_in,'High',4)
    val_out = 'High';
elseif strncmp(val_in,'Medium',6)
    val_out = 'Medium';
elseif strncmp(val_in,'Low',3)
    val_out = 'Low';
elseif strncmp(val_in,'Very Low',6)
    val_out = 'Lowest';
    
elseif strncmp(val_in,'Hyperspectral(>100 channels)',13)
    val_out = 'Hyperspectral';
elseif strncmp(val_in,'Multispectral(~10-30 channels)',13)
    val_out = 'Multispectral';
elseif strncmp(val_in,'Multiband (2-7 channels',9)
    val_out = 'Multiband';
elseif strncmp(val_in,'Single band',5)
    val_out = 'Single-band';
    
elseif strncmp(val_in,'Multi-polarization',9)
    val_out = 'yes';
elseif strncmp(val_in,'Single polarization',5)
    val_out = 'no';
    
elseif strncmp(val_in,'High accuracy on-board calibration',9)
    val_out = 'Advanced';
elseif strncmp(val_in,'Some on-board calibration',5)
    val_out = 'Some';
elseif strncmp(val_in,'No on-board calibration',5)
    val_out = 'None';
else
    val_out = 'None';
    
    
end
return

