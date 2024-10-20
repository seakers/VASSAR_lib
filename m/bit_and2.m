function res = bit_and2(mask,seq)
N = length(RBES_get_parameter('instrument_list'));

a = de2bi(mask,N);
b = de2bi(seq,N);
c = a & b;
res = sum(c);
end