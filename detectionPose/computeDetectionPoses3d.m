function [] = computeDetectionPoses3d(class)
%COMPUTEDETECTIONPOSES Summary of this function goes here
%   Detailed explanation goes here
globals;
numBins = 21;
thetaInds = 1:21;
elevationInds = 22:42;
azimuthInds = 43:63;

proto = 'vggJointVps';
suff = '';

saveDir = fullfile(PASCAL3Ddir,'VDPM','data','vpsKps_3d_');
candsDir = fullfile(cachedir,['rcnnDetectionPredsVps'],[proto suff]);

load(fullfile(candsDir,'allDets.mat'));
cInd = pascalClassIndex(class);
cands = dataStructs(cInd);
dets = cell(size(cands.feat));

for i = 1:length(cands.boxes)
    predFeatAz = cands.feat{i}(:,azimuthInds);
    [~,predAz] = max(predFeatAz,[],2);
    
    predFeatEl = cands.feat{i}(:,elevationInds);
    [~,predEl] = max(predFeatEl,[],2);
    
    predFeatTh = cands.feat{i}(:,thetaInds);
    [~,predTh] = max(predFeatTh,[],2);
    
    pred = [(predTh-11) (predEl-11) (predAz-0.5)]*360/numBins;    
    dets{i} = [cands.boxes{i}(:,1:4) pred cands.boxes{i}(:,5)];
    
end

save([saveDir class],'dets');

end