function [rots] = predsToRotation(feat)
%PREDSTOROTATION Summary of this function goes here
%   Detailed explanation goes here

preds = poseHypotheses(feat,1,0);
%for i=1:length(preds)
parfor i=1:length(preds)
    preds{i} = encodePose(preds{i},'rot');
    tmp = {};
    for j=1:size(preds{i},1)
        tmp{j} = reshape(preds{i}(j,:),3,3);
    end
    preds{i} = tmp;
end
rots = preds{1};

end