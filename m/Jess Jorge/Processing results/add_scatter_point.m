function [] = add_scatter_point(h, x, y, c, s)
%ADD_SCATTER_POINT
%   h is the scattergroup handle,
%   (x, y) the new point, c its color and s its size
%   data is temporarily the fact object (wrapped in a jess.Value)

    xx = get(h, 'XData');
    set(h, 'XData', [xx x]);
    
    yy = get(h, 'YData');
    set(h, 'YData', [yy y]);
    
    if nargin > 3
        cc = get(h, 'CData');
        set(h, 'CData', [cc; c]);
    end
    
    if nargin > 4
        ss = get(h, 'SizeData');
        set(h, 'SizeData', [ss s]);
    end
    
    drawnow expose
end