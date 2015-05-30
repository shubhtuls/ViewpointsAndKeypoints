function [] = computeDetectionPosesContinuous(class)
%COMPUTEDETECTIONPOSES Summary of this function goes here
%   Detailed explanation goes here

numBins = 21;
azimuthInds = 43:63;

numBins = 24;
azimuthInds = 1:24;

saveDir = '~/Work/Datasets/PASCAL3D/VDPM/data/shubham_continuous_';
candsDir = '/work5/shubhtuls/cachedir/poseRegression/detectionPoseNmsfcJoint/';
candsDir = '/work5/shubhtuls/cachedir/poseRegression/detectionPoseNms/';
load([candsDir 'allDets.mat']);
cInd = pascalClassIndex(class);
cands = dataStructs(cInd);
angles = cell(size(cands.feat));
dets = cell(size(cands.feat));

for i = 1:length(cands.boxes)
    predFeat = cands.feat{i}(:,azimuthInds);
    [~,pred] = max(predFeat,[],2);
    %pred = (pred-0.5)*360/numBins;
    pred = (pred-1)*360/numBins;
    dets{i} = [cands.boxes{i}(:,1:4) pred cands.boxes{i}(:,5)];
end

save([saveDir class],'dets');

end