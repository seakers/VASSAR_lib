function RBES_assert_architectures(varargin)
global params
    type = varargin{1};
if nargin == 3
    archs = varargin{2};
    results = varargin{3};
elseif nargin == 4
    archs_tmp = varargin{2};
    results_tmp = varargin{3};
    ids = varargin{4};
    archs = archs_tmp(ids,:);
    names = fieldnames(results_tmp);
    results = results_tmp;
    for i = 1:length(names)
        all_values = getfield(results_tmp,names{i});
        setfield(results,names{i},all_values(ids));
    end
    
    
end
if strcmp(type,'selection')
    for i = 1:size(archs,1)
        arr = params.instrument_list(logical(archs(i,:)));
        str = StringArraytoStringWithSpaces(arr);
        arch.type = 'selection';
        arch.instruments = str;
        arch.seq = bi2de(archs(i,:));
        arch.utility = results.utilities(i);
        arch.cost = results.costs(i);
        arch.science = results.sciences(i);
        arch.risk = results.programmatic_risks(i);
        arch.fairness = results.fairness(i);
        arch.pareto_ranking = results.pareto_rankings(i);
        if isfield(results,'fits')
            arch.fit = results.fits(i);
        end
        assert_architecture(arch);
    end
elseif strcmp(type,'packaging')
    for i = 1:size(archs,1)
        arch.type = 'packaging';
        arch.seq = archs(i,:);
        arch.utility = results.utilities(i);
        arch.cost = results.costs(i);
        arch.science = results.sciences(i);
        arch.risk = results.programmatic_risks(i);
        arch.launch_risk = results.launch_risks(i);
        arch.pareto_ranking = results.pareto_rankings(i);
        if isfield(results,'instrument_orbits'), arch.instrument_orbits = results.instrument_orbits{i};end
        if isfield(results,'lv_pack_factors'), arch.lv_pack_factors = results.lv_pack_factors{i};end
        if params.DATA_CONTINUITY == 1
            if isfield(results,'data_continuities'), arch.data_continuity = results.data_continuities(i);end
        else
            arch.data_continuity = 0;
        end
        assert_architecture(arch);
    end
elseif strcmp(type,'assigning')
    for i = 1:size(archs,1)
        arch.type = 'assigning';
        arch.seq = archs(i,:);
        arch.utility = results.utilities(i);
        arch.cost = results.costs(i);
        arch.science = results.sciences(i);
%         arch.risk = results.programmatic_risks(i);
%         arch.launch_risk = results.launch_risks(i);
        arch.pareto_ranking = results.pareto_rankings(i);
%         if isfield(results,'instrument_orbits'), arch.instrument_orbits = results.instrument_orbits{i};end
%         if isfield(results,'lv_pack_factors'), arch.lv_pack_factors = results.lv_pack_factors{i};end
%         if params.DATA_CONTINUITY == 1
%             if isfield(results,'data_continuities'), arch.data_continuity = results.data_continuities(i);end
%         else
%             arch.data_continuity = 0;
%         end
        assert_architecture(arch);
    end
    
elseif strcmp(type,'scheduling')
    for i = 1:size(archs,1)
        arch.type = 'scheduling';
        arch.seq = archs(i,:);
        arch.utility = results.utilities(i);
%         arch.cost = results.costs(i);
%         arch.science = results.sciences(i);
        arch.risk = results.programmatic_risks(i);
        arch.fairness = results.fairness(i);
        arch.pareto_ranking = results.pareto_rankings(i);
        arch.data_continuity = results.data_continuities(i);
        arch.discounted_value = results.discounted_values(i);
        assert_architecture(arch);
    end
end
end