function orbit = get_constellation_orbit(h,i,raan,type,nsats,nplanes)
orbit.altitude = h;
orbit.i = i;
orbit.raan = raan;
orbit.type = type;
orbit.nsatsperplane = nsats;
orbit.nplanes = nplanes;
end