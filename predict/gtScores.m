function [scoresKps] = gtScores(heatMap,bbox,dims,kps)
%GTSCORES Summary of this function goes here
%   Detailed explanation goes here

globals;
numKps = size(kps,1);

nanConst = params.nanConst;
heatMap = heatMap';
map = nanConst*ones(3*dims(2)+2,3*dims(1)+2,numKps); %the centre dims(2) X dims(1) X numKps corresponds to actual vals
map((dims(2)+2):(2*dims(2)+1),(dims(1)+2):(2*dims(1)+1),:) = reshape(heatMap,[dims(2),dims(1),numKps]);
nDims = (3*dims(1)+2)*(3*dims(2)+2);

kpsNorm = normKps(kps,bbox,dims);
kpsX = kpsNorm(:,1);kpsY = kpsNorm(:,2);

Xs = (-dims(1)*ones(size(kpsX)));
Ys = (-dims(2)*ones(size(kpsY))); %coordinate for nanConst nan is [-dim2,-dim1]

for k=1:numKps
    if(~isnan(kpsX(k)))
        Ys(k) = floor(kpsY(k)+1);
        Xs(k) = floor(kpsX(k)+1);
    end
end

scoresKps = zeros(1,numKps);
for k=1:numKps
    tmpY = Ys(k) + dims(2) + 1;
    tmpX = Xs(k) + dims(1) + 1;
    scoreInds = sub2ind([size(map,1) size(map,2)],tmpY,tmpX) + (k-1)*nDims;
    scoresKps(1,k) = map(scoreInds);
end

end

function kps = normKps(kps,bbox,dims)
%kps is (N*Nkps) X 2

deltaX = (bbox(:,3)-bbox(:,1)+1)/dims(1);
deltaY = (bbox(:,4)-bbox(:,2)+1)/dims(2);

kps(:,1) = ((kps(:,1)-bbox(:,1))./deltaX);
kps(:,2) = ((kps(:,2)-bbox(:,2))./deltaY);

badInds = isnan(kps(:,1)) |  isnan(kps(:,2)) | (kps(:,1))<0 | kps(:,2) < 0 | kps(:,1) >= dims(1) | kps(:,2) >= dims(2) ;
kps(badInds,:) = nan;

end