function create_satisfaction_tree( tree )

    global zeResult;
    
    % Create the root node
    sat = zeResult.getScience;
    str = [ 'Architecture - Sat = ' char(sat) ];
    root = uitreenode( 'v0', handle(tree), str, [], false);
    
    % Create the stakeholder level
    stk_facts = zeResult.getFacts( 'SATISFACTION', 'STAKEHOLDER' );
    tmp = get_facts_values( stk_facts, {'id','satisfaction','weight'} );
    id  = tmp(1,:);
    sat = tmp(2,:);
    wgt = tmp(3,:);
    
    ob_facts = zeResult.getFacts( 'SATISFACTION', 'OBJECTIVE' );
    us_facts = zeResult.getFacts( 'SATISFACTION', 'USER' );
    for i = 1:length(id)
        % Create the stakeholder facts
        node = uitreenode( 'v0', [ 'Stakeholder ' id{i} ], [ 'Stakeholder ' id{i} ], [], false );
        node.add( uitreenode( 'v0', [ 'Satisfaction = ' sat{i} ], [ 'Satisfaction = ' sat{i} ], [], true ) );
        node.add( uitreenode( 'v0', [ 'Weight = ' wgt{i} ], [ 'Weight = ' wgt{i} ], [], true ) );
        root.add( node );
        
        % Create the objective, user and service level
        add_objectives( ob_facts, us_facts, node, id{i} );        
    end
    
    % Build the tree
    tree.setRoot(root);
    tree.expand(root);

end

function add_objectives( ob_facts, us_facts, parent_node, parent_name )
    
    % Get the objectives
    f = find_facts( ob_facts, 'parent', parent_name );
    tmp1 = get_facts_values( f, {'id','satisfaction','weight'} );
    tmp2 = get_facts_values( f, {'users-id','users-weight','users-satisfaction' } );
    
    for i = 1:size( tmp1, 2 )
        
        % Create the objective node
        ob_node = uitreenode( 'v0', [ 'Objective ' tmp1{1,i} ], [ 'Objective ' tmp1{1,i} ], [], false );
        ob_node.add( uitreenode( 'v0', [ 'Satisfaction = ' tmp1{2,i} ], [ 'Satisfaction = ' tmp1{2,i} ], [], true ) );
        ob_node.add( uitreenode( 'v0', [ 'Weight = ' tmp1{3,i} ], [ 'Weight = ' tmp1{3,i} ], [], true ) );
        parent_node.add( ob_node );
        
        % Create the subobjective nodes
        add_objectives( ob_facts, us_facts, ob_node, tmp1{1,i} );
        
        % Create the user nodes
        usr_i = regexp( tmp2{1,i}, ' ', 'split' );
        usr_w = regexp( tmp2{2,i}, ' ', 'split' );
        usr_s = regexp( tmp2{3,i}, ' ', 'split' );
        for j = 1:size( usr_i, 2 )
            usr_node = uitreenode( 'v0', [ 'User ' usr_i{j} ], [ 'User ' usr_i{j} ], [], false );
            usr_node.add( uitreenode( 'v0', [ 'Satisfaction = ' usr_s{j} ], [ 'Satisfaction = ' usr_s{j} ], [], true ) );
            usr_node.add( uitreenode( 'v0', [ 'Weight = ' usr_w{j} ], [ 'Weight = ' usr_w{j} ], [], true ) );
            ob_node.add( usr_node );
            
            % Create the service nodes
            f2 = find_facts( us_facts, 'id', usr_i{j} );
            tmp3 = get_facts_values( f2, {'services-id','services-satisfaction','services-weight' } );
            for k = 1:size( tmp3, 2 )
                sr_node = uitreenode( 'v0', [ 'Service ' tmp3{1,k} ] , [ 'Service ' tmp3{1,k} ], [], false );
                sr_node.add( uitreenode( 'v0', [ 'Satisfaction = ' tmp3{2,k} ], [ 'Satisfaction = ' tmp3{2,k} ], [], true ) );
                sr_node.add( uitreenode( 'v0', [ 'Weight = ' tmp3{3,k} ], [ 'Weight = ' tmp3{3,k} ], [], true ) );
                usr_node.add( sr_node );
            end
        end
        
    end    
	
end