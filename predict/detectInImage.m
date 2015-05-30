function [dets] = detectInImage(imname,class,priorAlpha,suffix,lambdas)
% alphas = Nkps X nMaps
%suffix = 'Det'
globals;
maps = {};
cInd = pascalClassIndex(class);
mapDims = params.heatMapDims;
responseDims = [6 12];
priorFeatPrecomputed = load(fullfile(cachedir,'posePriorMaps',class));
priorFeatPrecomputed = priorFeatPrecomputed.priorFeat;

for d=1:length(responseDims)
    var = load(fullfile(cachedir,'rcnnImgDetectionPredsKps',['vggConv' num2str(responseDims(d)) suffix],imname));
    feat = var.dataStructsImg(cInd).feat;
    feat = flipMapXY(feat,[responseDims(d) responseDims(d)]);
    maps{d} = resizeHeatMap(feat,[responseDims(d) responseDims(d)]);
    bbox = var.dataStructsImg(cInd).bbox;
end

varPose = load(fullfile(cachedir,'rcnnImgDetectionPredsVps','vggJointVpsMirror',imname));
goodInds = varPose.labels==cInd;
poseFeat = varPose.feat(goodInds,:);

[~,e1s] = max(poseFeat(:,1:21),[],2);
[~,e2s] = max(poseFeat(:,22:42),[],2);
[~,e3s] = max(poseFeat(:,43:63),[],2);

feat = zeros(size(maps{1}));
featPrior = zeros(size(maps{1}));

for d = 1:length(responseDims)
    feat = feat+maps{d}*lambdas(d);
end

for n = 1:size(featPrior,1)
    featPrior(n,:) = priorFeatPrecomputed{e1s(n),e2s(n),e3s(n)};
end

det.kps = [];det.mapScores = [];
det.bbox = bbox;
det.regionScores = var.dataStructsImg(cInd).scores;
det.featPrior = featPrior;
detOrig = det;

dets = {};

for d = 1:numel(priorAlpha)
    det = detOrig;
    for i=1:size(feat,1)
        fPrior = priorAlpha(d)*log(featPrior(i,:)+eps);

        [det.kps(:,:,i),det.mapScores(:,i)] = maxLocationPredict(fPrior+feat(i,:),bbox(i,:),mapDims);
    end
    if(size(det.kps,1)==2)
        det.kps = permute(det.kps,[2 1 3]);
    end
    dets{d} = det;
end

end