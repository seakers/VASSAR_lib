function list = get_instrument_list(varargin)
    persistent instrument_list;
    
    if nargin == 0 % GET
        if isempty(instrument_list)
            list = [];
        else
            list = instrument_list;
        end
    elseif nargin >0
        thelist = varargin;
        instrument_list = thelist;
        list = instrument_list;
    end
end