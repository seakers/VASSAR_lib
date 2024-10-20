function [system] = eqs_system(eqs)
    list = {};
    if nargin, list = eqs; end;
    
    system.new = @new_eq;
    function [eq] = new_eq(lhs, rhs)
        m_lhs = lhs;
        m_rhs = rhs;

        eq.lhs = @access_lhs;
        function out = access_lhs(in)
            if nargin, m_lhs = in; end;
            out = m_lhs;
        end

        eq.rhs = @access_rhs;
        function out = access_rhs(in)
            if nargin, m_rhs = in; end;
            out = m_rhs;
        end

        eq.as_constraint = @substract;
        function out = substract()
            out = m_lhs - m_rhs;
        end
        
        list = [list {eq}];
    end

    system.union = @union_of_sys;
    function [un] = union_of_sys(sys)
        un = eqs_system([list sys.all()]);
    end
    
    system.all = @all_eqs;
    function [eq_cell] = all_eqs()
        eq_cell = list;
    end
end