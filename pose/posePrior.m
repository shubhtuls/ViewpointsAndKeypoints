function [priorFeat] = posePrior(dataStruct,class,trainIds)
%POSEPRIOR Summary of this function goes here
%   Detailed explanation goes here

globals;
rData = load(fullfile(rotationPascalDataDir,class));
rData = rData.rotationData;
trainData = rData(ismember({rData(:).voc_image_id},trainIds));
trainData = augmentKps(trainData,dataStruct);

preds = load(fullfile(cachedir,'rcnnPredsVpsKeypoint',params.features,class));
preds = preds.feat;
preds = predsToRotation(preds);

H = params.heatMapDims(2);
W = params.heatMapDims(1);
Kp = size(trainData(1).kps,1);
N = length(dataStruct.voc_image_id);
priorFeat = zeros(N,H*W*Kp);
bboxes = dataStruct.bbox;

for i = 1:N
    pFeat = neighborMapsKpsScore(preds{i},bboxes(i,:),trainData);    
    priorFeat(i,:) = pFeat;
end

end