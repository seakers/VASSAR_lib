function new_seq = mutate_one_bit(seq)
N = length(RBES_get_parameter('instrument_list'));

bi = de2bi(seq,N);
pos =  randi(N,1);
bi(pos)=1-bi(pos);
new_seq = bi2de(bi);
end