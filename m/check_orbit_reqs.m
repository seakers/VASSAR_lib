function bool = check_orbit_reqs(instr,orbit,varargin)
global params;

instr_list = params.packaging_instrument_list;
index = strcmp(instr,instr_list);
if strcmp(orbit,varargin{index})
    bool = 1;
else
    bool = 0;
end

end