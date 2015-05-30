function [kpCoords,scores] = maxLocationPredict(heatMap,bbox,dims)
%MAXPREDICT Summary of this function goes here
%   Detailed explanation goes here

assert(size(heatMap,1)==1,'Heatmap should be 1 X (Nkps*Dims)');
deltaX = (bbox(3)-bbox(1)+1)/dims(1);
deltaY = (bbox(4)-bbox(2)+1)/dims(2);
mapSize = dims(1)*dims(2);
nKps = numel(heatMap)/mapSize;

heatMap = reshape(heatMap,[mapSize,nKps]);
[scores,locs] = max(heatMap,[],1);
[kpsY,kpsX] = ind2sub([dims(2) dims(1)],locs);
kpCoords(1,:) = kpsX*deltaX - 0.5*deltaX + bbox(1);
kpCoords(2,:) = kpsY*deltaY - 0.5*deltaY + bbox(2);

end