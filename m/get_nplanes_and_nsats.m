function [num_planes,num_sat_per_planes,h,inc,fov] = get_nplanes_and_nsats(list_of_orbits)
n = length(list_of_orbits);
planes_map = java.util.HashMap;
for i = 1:n
    orbit = list_of_orbits(i);% (fov,h,inc,raan,ano)
    plane = java.util.ArrayList;
    plane.add(orbit(2));plane.add(orbit(3));plane.add(orbit(4));
    if planes_map.containsKey(plane)  % existing plane
        anos = planes_map.get(plane);
        if ~anos.contains(orbit(5)) % new satellite in plane
            anos.add(orbit(5));
            planes_map.put(plane,anos);
            num_sat_per_planes = anos.size;
        end       
    else % new plane
        anos = java.util.ArrayList;
        anos.add(orbit(5));
        planes_map.put(plane,anos);
        num_sat_per_planes = 1;
    end
    

end
fov = orbit(1);
h = orbit(2);
inc = orbit(3);
num_planes = planes_map.size;
return
