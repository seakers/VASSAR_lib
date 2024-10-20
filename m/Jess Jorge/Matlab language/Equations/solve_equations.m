function [sol] = solve_equations(eqs, varargin)
    constraints = cellfun(@(eq)eq.as_constraint(), eqs.all(), 'uniformOutput', false);
    sol = solve(constraints{:},varargin{:});
end