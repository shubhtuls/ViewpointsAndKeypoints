function [] = computeDetectionPoses(class,numBins)
%COMPUTEDETECTIONPOSES Summary of this function goes here
%   Detailed explanation goes here
globals;
proto = 'vggAzimuthVpsMirror';
suff = '';

if numBins == 24 
    azimuthInds = 1:24;
elseif numBins == 16    
    azimuthInds = 25:40;
elseif numBins == 8    
    azimuthInds = 41:48;
elseif numBins == 4    
    azimuthInds = 49:52;
end

saveDir = fullfile(PASCAL3Ddir,'VDPM','data',['vpsKps_' num2str(numBins) '_']);

candsDir = fullfile(cachedir,['rcnnDetectionPredsVps'],[proto suff]);
load(fullfile(candsDir,'allDets.mat'));
cInd = pascalClassIndex(class);
cands = dataStructs(cInd);
dets = cell(size(cands.feat));

for i = 1:length(cands.boxes)
    predFeat = cands.feat{i}(:,azimuthInds);
    [~,pred] = max(predFeat,[],2);
    %pred = (pred-1)*360/numBins;
    dets{i} = [cands.boxes{i}(:,1:4) pred cands.boxes{i}(:,5)];
end
save([saveDir class],'dets');

end
