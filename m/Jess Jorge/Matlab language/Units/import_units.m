function [] = import_units()
% Adds syms representing common units to the workspace of the caller
% function. All are defined in terms of basic syms which are persistent
% (see get_basic_units). This means one can pass units between two
% different functions that call "import_units," and said units will
% recognize each other. In this sense, one can program as if they were just
% part of the Matlab language :)

    get_basic_units();
    
    m = W*s/N;
    kg = N*s^2/m;

    kW = 1000*W;

    A = W/V;
    Ohm = V/A;

    mOhm = Ohm/1000;

    mm = m/1000;

    g = kg/1000;

    euros = 1.4*dollars;

    min = 60*s;
    h = 60*min;
    mA = A/1000;
    C = 1/h;

    Hz = 2*pi*rad/s;
    rpm = Hz*s/min;
    krpm = 1000*rpm;

    g0 = 9.8*m/s^2;
    kp = kg*g0;
    
    deg = pi*rad/180;
    
    
    all_units = who();
    
    for i = 1:length(all_units)
        assignin('caller', all_units{i}, eval(all_units{i}));
    end
end