function [heatMap] = flipMapXY(heatMap,dims)
%FLIPMAP Summary of this function goes here
%   Detailed explanation goes here

if(nargin<2)
    globals;
    dims = params.heatMapDims;
end
nKps = size(heatMap,2)/(dims(1)*dims(2));
for i=1:size(heatMap,1)
    hMap = permute(reshape(heatMap(i,:),[dims(1),dims(2),nKps]),[2 1 3]);
    hMap = hMap(:);
    heatMap(i,:) = hMap';
end

end