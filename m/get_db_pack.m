function ret = get_db_pack(varargin)
persistent db_pack
if(isempty(db_pack))
    if(nargin==0)
        db_pack = java.util.HashMap;
    else
        load(varargin{1});
    end
end
ret = db_pack;
end

