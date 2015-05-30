function [mapsNeighbors] = neighborMapsKpsScore(R,bbox,trainData)
%NEIGHBORMAPSKPSSCORE Summary of this function goes here
%   Detailed explanation goes here

warning off;
%% Getting kpMaps
globals;
params = params;

H = params.heatMapDims(2);
W = params.heatMapDims(1);
Kp = size(trainData(1).kps,1);

wBox = bbox(3)-bbox(1);hBox = bbox(4)-bbox(2);
bboxRatio = (wBox)/(hBox);

countNeighbors = zeros(Kp,1);
mapsNeighbors = zeros(H,W,Kp);
dtVal = 1/3;dtRange = max(H,W)/2;
if(bboxRatio <1)
    dtValx=dtVal*(bboxRatio)^2;
    dtValy = dtVal;
else
    dtValx = dtVal;
    dtValy=dtVal/(bboxRatio^2);
end


%% finding neighbors
thresh = 20;
numNeighbors = 0;

for i = 1:length(trainData)
    if(norm(logm(R'*trainData(i).rot), 'fro') * 180/pi <= thresh)
        numNeighbors = numNeighbors+1;
        bbox = trainData(i).bbox;

        kps = trainData(i).kps';
        goodInds = find(~isnan(kps(1,:)));
        kps(1,:) = ceil(W*(kps(1,:)-bbox(1))/(bbox(3)-bbox(1)));
        kps(1,:) = max(kps(1,:),1);kps(1,:) = min(kps(1,:),W);
        kps(2,:) = ceil(H*(kps(2,:)-bbox(2))/(bbox(4)-bbox(2)));
        kps(2,:) = max(kps(2,:),1);kps(2,:) = min(kps(2,:),H);
        
        for kp = goodInds
            countNeighbors(kp) = countNeighbors(kp)+1;
            mapTmp = zeros(H,W);
            mapTmp(kps(2,kp),kps(1,kp)) = 1;
            [mapTmp,~,~] = fast_bounded_dt(mapTmp,dtValx,0,dtValy,0,dtRange);            
            mapsNeighbors(:,:,kp) = mapsNeighbors(:,:,kp) + mapTmp;            
        end
    end
end

%% Normalizing neighbor maps


for kp = 1:Kp
    if(countNeighbors(kp)==0)
        mapsNeighbors(:,:,kp) = zeros(H,W);
    else
        mapsNeighbors(:,:,kp) = mapsNeighbors(:,:,kp)/countNeighbors(kp);
        mapsNeighbors(:,:,kp) = mapsNeighbors(:,:,kp).^min(10,countNeighbors(kp)/10);
    end
end

%disp(numNeighbors/length(trainData));
%if(numNeighbors < 0.1*length(trainData))
%if(numNeighbors == 0)
    %mapsNeighbors = ones(size(mapsNeighbors));
%end

mapsNeighbors = (mapsNeighbors(:))';
end

