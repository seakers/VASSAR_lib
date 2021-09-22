function res = bit_not(mask)
N = length(RBES_get_parameter('instrument_list'));

a = de2bi(mask,N);
c = ~a;
res = bi2de(c);
end