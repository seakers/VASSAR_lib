function val_out = attribute_adapt2(attrib_correspondance,val_in)
val_out = attrib_correspondance.get(val_in);
if(isempty(val_out))
    val_out = 'nil';
end
return