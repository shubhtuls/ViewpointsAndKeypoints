function [kpCoords,scores] = maxLocationCandidates(heatMap,bbox,dims)
%MAXLOCATIONCANDIDATES Summary of this function goes here
%   Detailed explanation goes here

globals;
numCands = params.numKpCands;
assert(size(heatMap,1)==1,'Heatmap should be 1 X (Nkps*Dims)');
deltaX = (bbox(3)-bbox(1)+1)/dims(1);
deltaY = (bbox(4)-bbox(2)+1)/dims(2);
mapSize = dims(1)*dims(2);
nKps = numel(heatMap)/mapSize;

heatMap = reshape(heatMap,[dims(2),dims(1),nKps]);

for n=1:nKps
    [kpsY,kpsX,scores{n}] = maxCands(heatMap(:,:,n),numCands);
    kpCoords{n}(1,:) = kpsX*deltaX - 0.5*deltaX + bbox(1);
    kpCoords{n}(2,:) = kpsY*deltaY - 0.5*deltaY + bbox(2);
end

end

function [Ys,Xs,scores] =  maxCands(map,numCands)
dims = size(map);
tmpMap = -Inf*(ones(dims+2));
tmpMap(2:end-1,2:end-1) = map;
scores = [];Ys = [];Xs = [];

for i=1:dims(1)
    for j=1:dims(2)
        if(map(i,j)==max(max(tmpMap(i:i+2,j:j+2)))) %if this is a local maxima
            Ys = horzcat(Ys,i);
            Xs = horzcat(Xs,j);
            scores = horzcat(scores,map(i,j));
        end
    end
end

[~,I] = sort(scores,'descend');
N = min(numCands,length(I));
I = I(1:N);
Xs = Xs(I);Ys = Ys(I);scores = scores(I);

end