function [archs,strs] = SEL_assert_full_factorial(instruments)
global params
n = length(instruments);
nall = length(params.instrument_list);
archs = zeros(2^n-1,nall);
strs = cell(2^n-1,1);

for d = 1:2^n-1
    mask = de2bi(d,n);
    instrs = instruments(logical(mask));
    str = StringArraytoStringWithSpaces(instrs);
    archs(d,:) = SEL_str_to_arch(str);
    strs{d} = str;
    arch.type = 'selection';
    arch.instruments = str;
    arch.seq = bi2de(archs(d,:));
    assert_architecture(arch);
end

end