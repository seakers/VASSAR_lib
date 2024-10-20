function get_info_mission()
my_jess_query('MANIFEST::Mission','standard-bus');
my_jess_query('MANIFEST::Mission','in-orbit');
my_jess_query('MANIFEST::Mission','launch-vehicle');
my_jess_query('MANIFEST::Mission','mission-cost#');
my_jess_query('MANIFEST::Mission','satellite-mass#');
my_jess_query('MANIFEST::Mission','satellite-BOL-power#');
end