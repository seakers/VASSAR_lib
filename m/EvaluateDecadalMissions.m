%% EvaluateDecadalMissions.m
% RBES_Init_Params_Decadal;
% [r,params] = RBES_Init_WithRules(params);

%% Tier I missions
mission_set{1} = create_test_mission('CLARREO',{'CLAR_TIR','CLAR_VNIR','CLAR_GPS'},2015,8,[]);% CLARREO
mission_set{2} = create_test_mission('SMAP',{'SMAP_RAD','SMAP_MWR'},2015,8,[]);% SMAP 
mission_set{3} = create_test_mission('ICESAT-II',{'ICE_LID'},2015,8,[]);% ICESAT
mission_set{4} = create_test_mission('DESDYNI',{'DESD_SAR','DESD_LID'},2015,8,[]);% DESDYINI
orbit = get_constellation_orbit(800,'polar','NA','LEO',6,1);
mission_set{5} = create_test_mission('GPSRO',{'GPS'},2015,8,orbit);% GPSRO

%% Tier II missions

mission_set{6} = create_test_mission('HYSPIRI',{'HYSP_TIR','HYSP_VIS'},2015,8,[]);% HYSPIRI
mission_set{7} = create_test_mission('ASCENDS',{'ASC_LID','ASC_GCR','ASC_IRR'},2015,8,[]);% ASCENDS
mission_set{8} =  create_test_mission('SWOT',{'SWOT_KaRIN','SWOT_RAD','SWOT_MWR'},2015,8,[]);% SWOT
mission_set{9} =  create_test_mission('GEO-CAPE',{'GEO_STEER','GEO_WAIS','GEO_GCR'},2015,8,[]);% GEO-CAPE
mission_set{10} = create_test_mission('ACE',{'ACE_CPR','ACE_POL','ACE_ORCA','ACE_LID'},2015,8,[]);% ACE
mission_set{11} = create_test_mission('XOVWM',{'XOV_SAR','XOV_RAD','XOV_MWR'},2015,8,[]);% ACE

%% Tier III missions
% 
mission_set{12} = create_test_mission('PATH',{'PATH_GEOSTAR'},2015,8,[]);% PATH 
mission_set{13} = create_test_mission('SCLP',{'SCLP_SAR','SCLP_MWR'},2015,8,[]);% SCLP
mission_set{14} = create_test_mission('GACM',{'GACM_DIAL','GACM_VIS','GACM_SWIR','GACM_MWSP'},2015,8,[]);% GACM
mission_set{15} = create_test_mission('3D-WINDS',{'3D_CLID','3D_NCLID'},2015,8,[]);% 3D-WINDS
mission_set{16} = create_test_mission('GRACE-II',{'GRAC_RANG'},2015,8,[]);% GRACE
mission_set{17} = create_test_mission('LIST',{'LIST_LID'},2015,8,[]);% LIST

%% Evaluate
 [score_vec,panel_scores_mat,data_continuity_score_vec,lists,cost_vec,subobjective_scores,dc_matrices,orbits] = RBES_Evaluate_MissionSet(mission_set);
 [combined_score,combined_pan,combined_obj,combined_subobj] = RBES_combine_subobj_scores(subobjective_scores);