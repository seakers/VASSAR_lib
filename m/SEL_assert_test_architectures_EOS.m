function SEL_assert_test_architectures_EOS()

jess unwatch all;
jess watch rules;
jess reset;
%% ENUMERATION
% Architectures to be considered
% % examples of given architectures
arch.type = 'selection';
arch.seq = [];
arch.instruments = 'AIRS HSB AMSU-A SEAWINDS GLAS DORIS ALT-SSALT TMR MLS';% ok 590
assert_architecture(arch);

arch.instruments = 'HSB AMSU-A SEAWINDS GLAS DORIS ALT-SSALT TMR MLS';%nok because not AIRS 591
assert_architecture(arch);

arch.instruments = 'AIRS HSB AMSU-A SCANSCAT GLAS DORIS ALT-SSALT TMR MLS';% ok (XOR SCAT) 592
assert_architecture(arch);

arch.instruments = 'AIRS HSB AMSU-A GLAS DORIS ALT-SSALT TMR MLS';% nok, no SCAT
assert_architecture(arch);

arch.instruments = 'AIRS HSB AMSU-A SEAWINDS GLAS DORIS ALT-SSALT TMR SCANSCAT MLS';% nok because 2 scat
assert_architecture(arch);

arch.instruments = 'AIRS HSB AMSU-A SEAWINDS GLAS GGI ALT-SSALT TMR MLS';% ok GGI 595
assert_architecture(arch);

arch.instruments = 'AIRS HSB AMSU-A SEAWINDS GLAS ALT-SSALT TMR MLS';% nok no GGI/DORIS
assert_architecture(arch);

arch.instruments = 'AIRS HSB AMSU-A SEAWINDS GLAS DORIS TMR MLS';%nok because TMR but no ALT 597
assert_architecture(arch);

arch.instruments = 'AIRS HSB AMSU-A SEAWINDS GLAS DORIS ALT-SSALT MLS';% nok because ALT but no TMR 
assert_architecture(arch);

arch.instruments = 'AIRS HSB AMSU-A SEAWINDS GLAS DORIS MLS';% ok because no ALT, no TMR
assert_architecture(arch);

arch.instruments = 'AIRS HSB AMSU-A SEAWINDS GLRS DORIS ALT-SSALT TMR MLS';% ok because GLRS 600
assert_architecture(arch);

arch.instruments = 'AIRS HSB AMSU-A SEAWINDS DORIS ALT-SSALT TMR MLS';% nok becasue no GLAS or GLRS
assert_architecture(arch);

arch.instruments = 'AIRS HSB AMSU-A SEAWINDS GLAS DORIS ALT-SSALT TMR IPEI MLS';% nok because IPEI 602
assert_architecture(arch);

arch.instruments = 'AIRS HSB AMSU-A SEAWINDS GLAS DORIS ALT-SSALT TMR SAFIRE';% ok SAFIRE
assert_architecture(arch);

arch.instruments = 'AIRS HSB AMSU-A SEAWINDS GLAS DORIS ALT-SSALT TMR MLS SAFIRE';% nok MLS SAFIRE 604
assert_architecture(arch);

arch.instruments = 'AIRS HSB AMSU-A SEAWINDS GLAS DORIS ALT-SSALT TMR';% nok NO MLS NOR SAFIRE 605
assert_architecture(arch);

% assert ref architecture
ref = SEL_ref_arch;
arch.instruments = get_instr_from_seq(bi2de(ref));% 606
assert_architecture(arch);
end