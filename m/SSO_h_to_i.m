function i_deg = SSO_h_to_i(h_km)
    RE = 6378000;
    kh = 10.10949;
    h = 1000.*h_km;
    cos_i = (((RE+h)./RE).^3.5)./(-kh);
    i_deg = 180.*acos(cos_i)./pi;
return