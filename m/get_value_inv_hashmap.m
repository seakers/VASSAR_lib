function ret = get_value_inv_hashmap()
persistent hm
if isempty(hm)
    hm = java.util.HashMap;
    full = Interval('interval',1.0,1.0);
    most = Interval('interval',0.66,1.0);
    half = Interval('interval',0.4,0.6);
    some = Interval('interval',0.33,0.5);
    marginal = Interval('interval',0.0,0.33);
    hm.put('Full',full);
    hm.put('Most',most);
    hm.put('Half',half);
    hm.put('Some',some);
    hm.put('Marginal',marginal);    
end
ret = hm;
end