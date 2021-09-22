function ret = get_value_hashmap()
persistent hm
if isempty(hm)
    hm = java.util.HashMap;
    full = Interval('interval',1.0,1.0);
    most = Interval('interval',0.66,1.0);
    half = Interval('interval',0.4,0.6);
    some = Interval('interval',0.33,0.5);
    marginal = Interval('interval',0.0,0.33);
    hm.put(full,'Full');
    hm.put(most,'Most');
    hm.put(half,'Half');
    hm.put(some, 'Some');
    hm.put(marginal,'Marginal');    
end
ret = hm;
end