%% JSR_archs_for_show_penalties3.m
%% EOS reference arch (Fig 5 - left)
TERRA.payload = {'ASTER','CERES','CERES-B','MISR','MODIS','MOPITT'};
TERRA.orbit = 'SSO-800-AM';
TERRA.mass = 3503;
TERRA.cost = 1011;
TERRA.lv = 'Atlas5';
TERRA.penalties.mech = 1;TERRA.penalties.th = 1;TERRA.penalties.rb = 0;
TERRA.penalties.adcs = 0;TERRA.penalties.scan = 1;TERRA.penalties.emc = 0;

AQUA.payload = {'AIRS','AMSR-E','AMSU-A','CERES-C','HSB','MODIS-B'};
AQUA.orbit = 'SSO-800-PM';
AQUA.mass = 2782;
AQUA.cost = 872;
AQUA.lv = 'Delta7920';
AQUA.penalties.mech = 1;AQUA.penalties.th = 1;AQUA.penalties.rb = 0;
AQUA.penalties.adcs = 0;AQUA.penalties.scan = 1;AQUA.penalties.emc = 0;

AURA.payload = {'HIRDLS','MLS','OMI','TES'};
AURA.orbit = 'SSO-800-PM';
AURA.mass = 2242;
AURA.cost = 725;
AURA.lv = 'Delta7920';
AURA.penalties.mech = 0;AURA.penalties.th = 1;AURA.penalties.rb = 0;
AURA.penalties.adcs = 1;AURA.penalties.scan = 1;AURA.penalties.emc = 0;

eos_ref{1} = TERRA;
eos_ref{2} = AQUA;
eos_ref{3} = AURA;

%% EOS best arch (Fig 5 - left)
SAT1.payload = {'ASTER','CERES','CERES-B','MISR','MODIS'};
SAT1.orbit = 'SSO-800-AM';
SAT1.mass = 2878;
SAT1.cost = 844;
SAT1.lv = 'Delta7920';
SAT1.penalties.mech = 0;SAT1.penalties.th = 1;SAT1.penalties.rb = 0;
SAT1.penalties.adcs = 0;SAT1.penalties.scan = 1;SAT1.penalties.emc = 0;

SAT2.payload = {'AIRS','AMSU-A','HSB','MLS','MODIS-B','OMI'};
SAT2.orbit = 'SSO-800-PM';
SAT2.mass = 2969;
SAT2.cost = 1070;
SAT2.lv = 'Delta7920';
SAT2.penalties.mech = 0;SAT2.penalties.th = 1;SAT2.penalties.rb = 0;
SAT2.penalties.adcs = 1;SAT2.penalties.scan = 1;SAT2.penalties.emc = 0;

SAT3.payload = {'AMSR-E','CERES-C','HIRDLS','MOPITT','TES'};
SAT3.orbit = 'SSO-800-PM';
SAT3.mass = 2669;
SAT3.cost = 667;
SAT3.lv = 'Delta7920';
SAT3.penalties.mech = 1;SAT3.penalties.th = 1;SAT3.penalties.rb = 0;
SAT3.penalties.adcs = 1;SAT3.penalties.scan = 1;SAT3.penalties.emc = 0;

eos_best{1} = SAT1;
eos_best{2} = SAT2;
eos_best{3} = SAT3;

%% Decadal reference arch
ASC.payload = {'ASC_IRR','ASC_GCR','ASC_LID'};
ASC.orbit = 'SSO-400-AM';
ASC.mass = 1604;
ASC.cost = 841;
ASC.lv = 'Delta7320';
ASC.penalties.mech = 0;ASC.penalties.th = 0;ASC.penalties.rb = 0;
ASC.penalties.adcs = 1;ASC.penalties.scan = 1;ASC.penalties.emc = 0;

CLAR.payload = {'CLAR_GPS','CLAR_VNIR','CLAR_TIR'};
CLAR.orbit = 'LEO-600-polar';
CLAR.mass = 806;
CLAR.cost = 990;
CLAR.lv = 'Taurus';
CLAR.penalties.mech = 0;CLAR.penalties.th = 1;CLAR.penalties.rb = 1;
CLAR.penalties.adcs = 0;CLAR.penalties.scan = 1;CLAR.penalties.emc = 0;

DESD.payload = {'DESD_LID','DESD_SAR'};
DESD.orbit = 'SSO-600-DD';
DESD.mass = 4826;
DESD.cost = 4341;
DESD.lv = 'Atlas5';
DESD.penalties.mech = 1;DESD.penalties.th = 0;DESD.penalties.rb = 0;
DESD.penalties.adcs = 1;DESD.penalties.scan = 1;DESD.penalties.emc = 0;

HYSP.payload = {'HYSP_VIS','HYSP_TIR'};
HYSP.orbit = 'SSO-600-AM';
HYSP.mass = 577;
HYSP.cost = 759;
HYSP.lv = 'Taurus';
HYSP.penalties.mech = 0;HYSP.penalties.th = 0;HYSP.penalties.rb = 1;
HYSP.penalties.adcs = 0;HYSP.penalties.scan = 1;HYSP.penalties.emc = 0;

ICE.payload = {'ICE_LID'};
ICE.orbit = 'SSO-400-AM';
ICE.mass = 1299;
ICE.cost = 591;
ICE.lv = 'Delta7320';
ICE.penalties.mech = 0;ICE.penalties.th = 0;ICE.penalties.rb = 0;
ICE.penalties.adcs = 1;ICE.penalties.scan = 1;ICE.penalties.emc = 0;

SMAP.payload = {'SMAP_MWR','SMAP_RAD'};
SMAP.orbit = 'SSO-600-DD';
SMAP.mass = 778;
SMAP.cost = 752;
SMAP.lv = 'TaurusXL';
SMAP.penalties.mech = 1;SMAP.penalties.th = 0;SMAP.penalties.rb = 0;
SMAP.penalties.adcs = 1;SMAP.penalties.scan = 1;SMAP.penalties.emc = 0;

decadal_ref{1} = ASC;
decadal_ref{2} = CLAR;
decadal_ref{3} = DESD;
decadal_ref{4} = HYSP;
decadal_ref{5} = ICE;
decadal_ref{6} = SMAP;

%% Decadal alternative arch 1
ASC.payload = {'ASC_IRR','ASC_GCR','ASC_LID'};
ASC.orbit = 'SSO-400-AM';
ASC.mass = 1604;
ASC.cost = 841;
ASC.lv = 'Delta7320';
ASC.penalties.mech = 0;ASC.penalties.th = 0;ASC.penalties.rb = 0;
ASC.penalties.adcs = 1;ASC.penalties.scan = 1;ASC.penalties.emc = 0;

CLAR.payload = {'CLAR_GPS','CLAR_VNIR','CLAR_TIR'};
CLAR.orbit = 'LEO-600-polar';
CLAR.mass = 806;
CLAR.cost = 990;
CLAR.lv = 'Taurus';
CLAR.penalties.mech = 0;CLAR.penalties.th = 1;CLAR.penalties.rb = 1;
CLAR.penalties.adcs = 0;CLAR.penalties.scan = 1;CLAR.penalties.emc = 0;

DESD.payload = {'DESD_LID'};
DESD.orbit = 'SSO-400-AM';
DESD.mass = 1572;
DESD.cost = 665;
DESD.lv = 'Delta7320';
DESD.penalties.mech = 0;DESD.penalties.th = 0;DESD.penalties.rb = 0;
DESD.penalties.adcs = 1;DESD.penalties.scan = 1;DESD.penalties.emc = 0;

DESD2.payload = {'DESD_SAR'};
DESD2.orbit = 'SSO-800-DD';
DESD2.mass = 1326;
DESD2.cost = 1322;
DESD2.lv = 'Delta7320';
DESD2.penalties.mech = 1;DESD2.penalties.th = 0;DESD2.penalties.rb = 0;
DESD2.penalties.adcs = 0;DESD2.penalties.scan = 1;DESD2.penalties.emc = 0;

HYSP.payload = {'HYSP_VIS','HYSP_TIR'};
HYSP.orbit = 'SSO-600-AM';
HYSP.mass = 577;
HYSP.cost = 759;
HYSP.lv = 'Taurus';
HYSP.penalties.mech = 0;HYSP.penalties.th = 0;HYSP.penalties.rb = 1;
HYSP.penalties.adcs = 0;HYSP.penalties.scan = 1;HYSP.penalties.emc = 0;

ICE.payload = {'ICE_LID'};
ICE.orbit = 'SSO-400-AM';
ICE.mass = 1299;
ICE.cost = 591;
ICE.lv = 'Delta7320';
ICE.penalties.mech = 0;ICE.penalties.th = 0;ICE.penalties.rb = 0;
ICE.penalties.adcs = 1;ICE.penalties.scan = 1;ICE.penalties.emc = 0;

SMAP.payload = {'SMAP_MWR','SMAP_RAD'};
SMAP.orbit = 'SSO-600-DD';
SMAP.mass = 778;
SMAP.cost = 752;
SMAP.lv = 'TaurusXL';
SMAP.penalties.mech = 1;SMAP.penalties.th = 0;SMAP.penalties.rb = 0;
SMAP.penalties.adcs = 1;SMAP.penalties.scan = 1;SMAP.penalties.emc = 0;

decadal_1{1} = ASC;
decadal_1{2} = CLAR;
decadal_1{3} = DESD;
decadal_1{4} = DESD2;
decadal_1{5} = HYSP;
decadal_1{6} = ICE;
decadal_1{7} = SMAP;

%% Decadal alternative arch 2
ASC.payload = {'ASC_IRR','ASC_GCR','ASC_LID','CLAR_TIR'};
ASC.orbit = 'SSO-400-AM';
ASC.mass = 2885;
ASC.cost = 1315;
ASC.lv = 'Delta7920';
ASC.penalties.mech = 0;ASC.penalties.th = 1;ASC.penalties.rb = 0;
ASC.penalties.adcs = 1;ASC.penalties.scan = 1;ASC.penalties.emc = 0;


DESD.payload = {'DESD_LID'};
DESD.orbit = 'SSO-400-AM';
DESD.mass = 1572;
DESD.cost = 665;
DESD.lv = 'Delta7320';
DESD.penalties.mech = 0;DESD.penalties.th = 0;DESD.penalties.rb = 0;
DESD.penalties.adcs = 1;DESD.penalties.scan = 1;DESD.penalties.emc = 0;

DESD2.payload = {'DESD_SAR','CLAR_GPS'};
DESD2.orbit = 'SSO-800-DD';
DESD2.mass = 1372;
DESD2.cost = 1394;
DESD2.lv = 'Delta7320';
DESD2.penalties.mech = 1;DESD2.penalties.th = 0;DESD2.penalties.rb = 0;
DESD2.penalties.adcs = 0;DESD2.penalties.scan = 1;DESD2.penalties.emc = 0;

HYSP.payload = {'HYSP_VIS','HYSP_TIR'};
HYSP.orbit = 'SSO-600-AM';
HYSP.mass = 577;
HYSP.cost = 759;
HYSP.lv = 'Taurus';
HYSP.penalties.mech = 0;HYSP.penalties.th = 0;HYSP.penalties.rb = 1;
HYSP.penalties.adcs = 0;HYSP.penalties.scan = 1;HYSP.penalties.emc = 0;

ICE.payload = {'ICE_LID','CLAR_VNIR'};
ICE.orbit = 'SSO-400-AM';
ICE.mass = 1820;
ICE.cost = 1836;
ICE.lv = 'Delta7420';
ICE.penalties.mech = 0;ICE.penalties.th = 0;ICE.penalties.rb = 1;
ICE.penalties.adcs = 1;ICE.penalties.scan = 1;ICE.penalties.emc = 0;

SMAP.payload = {'SMAP_MWR','SMAP_RAD'};
SMAP.orbit = 'SSO-600-DD';
SMAP.mass = 778;
SMAP.cost = 752;
SMAP.lv = 'TaurusXL';
SMAP.penalties.mech = 1;SMAP.penalties.th = 0;SMAP.penalties.rb = 0;
SMAP.penalties.adcs = 1;SMAP.penalties.scan = 1;SMAP.penalties.emc = 0;

decadal_2{1} = ASC;
decadal_2{2} = DESD;
decadal_2{3} = DESD2;
decadal_2{4} = HYSP;
decadal_2{5} = ICE;
decadal_2{6} = SMAP;

%% Decadal alternative arch 3
ASC.payload = {'ASC_IRR','ASC_GCR','ASC_LID','CLAR_GPS'};
ASC.orbit = 'SSO-400-AM';
ASC.mass = 1666;
ASC.cost = 887;
ASC.lv = 'Delta7920';
ASC.penalties.mech = 0;ASC.penalties.th = 0;ASC.penalties.rb = 0;
ASC.penalties.adcs = 1;ASC.penalties.scan = 1;ASC.penalties.emc = 0;


DESD.payload = {'DESD_LID'};
DESD.orbit = 'SSO-400-AM';
DESD.mass = 1572;
DESD.cost = 665;
DESD.lv = 'Delta7320';
DESD.penalties.mech = 0;DESD.penalties.th = 0;DESD.penalties.rb = 0;
DESD.penalties.adcs = 1;DESD.penalties.scan = 1;DESD.penalties.emc = 0;

DESD2.payload = {'DESD_SAR','CLAR_VNIR'};
DESD2.orbit = 'SSO-800-DD';
DESD2.mass = 1699;
DESD2.cost = 1832;
DESD2.lv = 'Delta7420';
DESD2.penalties.mech = 1;DESD2.penalties.th = 0;DESD2.penalties.rb = 1;
DESD2.penalties.adcs = 0;DESD2.penalties.scan = 1;DESD2.penalties.emc = 0;

HYSP.payload = {'HYSP_VIS','HYSP_TIR','CLAR_TIR'};
HYSP.orbit = 'SSO-600-AM';
HYSP.mass = 985;
HYSP.cost = 1121;
HYSP.lv = 'MinotaurIV';
HYSP.penalties.mech = 0;HYSP.penalties.th = 1;HYSP.penalties.rb = 1;
HYSP.penalties.adcs = 0;HYSP.penalties.scan = 1;HYSP.penalties.emc = 0;

ICE.payload = {'ICE_LID'};
ICE.orbit = 'SSO-400-AM';
ICE.mass = 1299;
ICE.cost = 591;
ICE.lv = 'Delta7320';
ICE.penalties.mech = 0;ICE.penalties.th = 0;ICE.penalties.rb = 0;
ICE.penalties.adcs = 1;ICE.penalties.scan = 1;ICE.penalties.emc = 0;

SMAP.payload = {'SMAP_MWR','SMAP_RAD'};
SMAP.orbit = 'SSO-600-DD';
SMAP.mass = 778;
SMAP.cost = 752;
SMAP.lv = 'TaurusXL';
SMAP.penalties.mech = 1;SMAP.penalties.th = 0;SMAP.penalties.rb = 0;
SMAP.penalties.adcs = 1;SMAP.penalties.scan = 1;SMAP.penalties.emc = 0;

decadal_3{1} = ASC;
decadal_3{2} = DESD;
decadal_3{3} = DESD2;
decadal_3{4} = HYSP;
decadal_3{5} = ICE;
decadal_3{6} = SMAP;
