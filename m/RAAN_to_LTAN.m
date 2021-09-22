function LTAN = RAAN_to_LTAN( RAAN )
%LTAN_to_RAAN Transform LTAN to RAAN
%   LTAN = 12*(RAAN_rad+0.115)/pi
RAAN_rad = RAAN*pi/180;
LTAN = 12*(RAAN_rad+0.115)/pi;
end

