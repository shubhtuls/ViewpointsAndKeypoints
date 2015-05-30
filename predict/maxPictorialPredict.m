function [kpCoords,scores] = maxPictorialPredict(heatMap,bbox,dims,midParts,rootInd)
%MAXPICTORIALPREDICT Summary of this function goes here
%   Detailed explanation goes here

globals;
params = getParams;
midpartWeight = params.midpartWeight;

fraction = 1/5;
windowX = ceil(dims(1)*fraction);
windowY = ceil(dims(2)*fraction);
[gridX,gridY] = meshgrid(1:dims(1),1:dims(2));

deltaX = (bbox(3)-bbox(1)+1)/dims(1);
deltaY = (bbox(4)-bbox(2)+1)/dims(2);
mapSize = dims(1)*dims(2);
nKps = numel(heatMap)/mapSize;

kpsX = nan(1,nKps);
kpsY = nan(1,nKps);
kpCoords = nan(2,nKps);

nMidParts = size(midParts,1);
trueKps = ~ismember(1:nKps,midParts(:,1));
trueKpInds = find(trueKps);

heatMap = reshape(heatMap,[dims(1),dims(2),nKps]);

messageVals = zeros(dims(1),dims(2),nMidParts);
messageXs = zeros(dims(1),dims(2),nMidParts);
messageYs = zeros(dims(1),dims(2),nMidParts);

vals = heatMap;
dagOrder = getDag(midParts(:,2:3),rootInd,trueKpInds);

%% forward messages
edges = midParts;
for i = dagOrder'
    edgeInd = find(edges(:,2)==i | edges(:,3)==i);
    if(numel(edgeInd)>0)
        edge = edges(edgeInd,:);
        edges(edgeInd,:) = [];
        midp = edge(1);
        midpartMap = imresize(heatMap(:,:,midp),2*[dims(1),dims(2)]);

        parent = edge([false (edge(2:3)~=i)]);

        partMap = vals(:,:,i);
        maxVals = zeros(size(partMap));
        maxInds = zeros(size(partMap));

        for y = 1:dims(2)
            for x = 1:dims(1)
                resMap = partMap + midpartWeight*midpartMap(y+(1:dims(2)),x+(1:dims(1)));
                resMap((abs(gridX - x) > windowX) | (abs(gridY - y) > windowY)) = -Inf;
                [maxVals(y,x),maxInds(y,x)] = max(resMap(:));
            end
        end
        [yInds,xInds] = ind2sub(size(partMap),maxInds(:));
        
        messageVals(:,:,i) = maxVals;
        messageXs(:,:,i) = reshape(xInds,dims(2),dims(1));
        messageYs(:,:,i) = reshape(yInds,dims(2),dims(1));
        %if(parent~=9 && parent~=10)
        %    vals(:,:,parent) = vals(:,:,parent) + maxVals;
        %end
    end
end

%% backward inference
edges = midParts;
for i = fliplr(dagOrder')
    if(isnan(kpsX(i)))
        valMap = vals(:,:,i);
        [~,maxInd] = max(valMap(:));
        [kpsY(i),kpsX(i)] = ind2sub(size(valMap),maxInd);
    end
    
    edgeInds = find(edges(:,2)==i | edges(:,3)==i);
    for edgeInd = edgeInds'
        edge = edges(edgeInd,:);
        child = edge([false (edge(2:3)~=i)]);
        kpsY(child) = messageYs(kpsY(i),kpsX(i),child);
        kpsX(child) = messageXs(kpsY(i),kpsX(i),child);
    end
    edges(edgeInds,:) = [];
end


%% Final Kps
kpCoords(1,trueKpInds) = kpsX(trueKps)*deltaX - 0.5*deltaX + bbox(1);
kpCoords(2,trueKpInds) = kpsY(trueKps)*deltaY - 0.5*deltaY + bbox(2);
scores = zeros(size(kpCoords(1,:)));
kpCoords(:,midParts(:,1)) = 0.5*(kpCoords(:,midParts(:,2)) + kpCoords(:,midParts(:,3)));

end

function dagOrder = getDag(edges,root,varInds)

dagOrder = [root];
while(sum(~ismember(varInds,dagOrder)))
    outEdgeInds = ismember(edges(:,1),dagOrder) | ismember(edges(:,2),dagOrder);
    vertInds = edges(outEdgeInds,:);vertInds = unique(vertInds(:));
    newInds = vertInds(~ismember(vertInds,dagOrder));
    dagOrder = [dagOrder;newInds];
end
dagOrder = dagOrder(end:-1:1);

end