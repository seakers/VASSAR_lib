function orbit = get_SSO_orbit(h,raan)
orbit.altitude = h;
orbit.i = 'SSO';
orbit.raan = raan;
orbit.type = 'SSO';
orbit.nsatsperplane = 1;
orbit.nplanes = 1;
end