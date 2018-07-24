function stkCloseScenario()

    % Get all objects from the current STK scenario
    objNames = stkObjNames;
    
    % Remove all objects, including the scenario
    for i = length( objNames ):-1:1
        stkUnload( objNames{i} );
    end

end