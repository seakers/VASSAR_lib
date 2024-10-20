function str = SEL_arch_to_str(arch)
global params
str = StringArraytoStringWithSpaces(params.instrument_list(logical(arch)));
end