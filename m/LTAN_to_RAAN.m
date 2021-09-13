function RAAN = LTAN_to_RAAN( LTAN )
%LTAN_to_RAAN Transform LTAN to RAAN
%   LTAN = 12*(RAAN_rad+0.115)/pi

RAAN_rad = pi*LTAN/12 - 0.115;
RAAN = 180/pi*RAAN_rad;
end

