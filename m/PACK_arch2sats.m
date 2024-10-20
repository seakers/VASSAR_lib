function sats = PACK_arch2sats(varargin)
% PACK_arch2sats.m
% Example: 
% sats = PACK_arch2sats([1,1,1,2,2,2,1,2,3])
% sats{1} = [1,2,3,7];
% sats{2} = [4,5,6,8];
% sats{3} = [9];
arch = varargin{1};
if nargin==2
    offset = varargin{2};
else
    offset = 0;
end
nsats = max(arch);
sats = cell(nsats,1);
for i = 1:nsats
    sats{i} = find(arch==i) + offset;
end
end