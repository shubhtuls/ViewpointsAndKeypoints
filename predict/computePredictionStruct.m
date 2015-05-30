function [preds] = computePredictionStruct(class,fnames,priorAlpha,suffix)
%COMPUTEPREDICTIONSTRUCT Summary of this function goes here
%   Detailed explanation goes here

globals;
mapDims = [6 12];
load(fullfile(cachedir,'pascalTrainValIds.mat'));

pred.img_name = {};
pred.coords = [];
pred.scores = [];
pred.regScores = [];
pred.bbox = [];
pred.featPrior = [];
preds = {};

for d = 1:numel(priorAlpha)
    preds{d} = pred;
end

for i=1:length(fnames)
    if(~mod(i,20))
        disp(i)
    end
        
    dets = detectInImage(fnames{i},class,priorAlpha,suffix,ones(size(mapDims)));
    
    for d = 1:numel(priorAlpha)
        det = dets{d};
        pred = preds{d};
        N = size(det.kps,3);
        if(N == 0 || isempty(det.kps))
            continue;
        end
        regScores = det.regionScores;
        nKps = size(det.mapScores,1);
        pred.img_name = vertcat(pred.img_name,repmat(fnames(i),N,1));
        if(~isempty(pred.coords))
            pred.coords(:,:,end+(1:N)) = det.kps;
        else
            pred.coords = det.kps;
        end
        pred.scores = horzcat(pred.scores,det.mapScores);
        pred.regScores = horzcat(pred.regScores,repmat(regScores',nKps,1));
        pred.bbox = vertcat(pred.bbox,det.bbox);
        pred.featPrior = vertcat(pred.featPrior,det.featPrior);
        preds{d} = pred;
    end
end

end
