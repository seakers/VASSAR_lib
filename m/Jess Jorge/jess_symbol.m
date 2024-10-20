function [symbol] = jess_symbol(s)
% Just replaces non-allowed characters for '-', so the returned string is
% usable as a Jess symbol.
% Replaces spaces and parentheses with dashes. Should probably
% also consider other special characters.

    symbol = regexprep(s, ' |\(|\)', '-');
end