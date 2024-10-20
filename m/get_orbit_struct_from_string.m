function orbit = get_orbit_struct_from_string(str)
[typ,h,inc,raan] = get_orbit_params(str);
orbit.altitude = h;
orbit.i = inc;
orbit.raan = raan;
orbit.type = typ;
orbit.nsatsperplane = 1;
orbit.nplanes = 1;
orbit.e = 0;
end