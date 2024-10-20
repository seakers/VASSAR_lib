function vec = ArrayList2Vec(al)
    n = al.size;
    vec = zeros(1,n);
    for i = 1:n
        vec(i) = al.get(i-1);
    end
end