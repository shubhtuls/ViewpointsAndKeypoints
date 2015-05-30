function [accuracy,accuracyLoc,accuracyVis] = pckvMetric(preds,gtData,goodInds)

%PCK Summary of this function goes here
%   Detailed explanation goes here

if(iscell(goodInds)) %passed the fnames
    goodInds = ismember(gtData.voc_image_id,goodInds);
end

globals;
alpha = params.alpha;
numKps = length(preds(1).scores);

correctLoc = zeros(numKps,1);
totalLoc = zeros(numKps,1);

correctVis = zeros(numKps,1);
correct = zeros(numKps,1);

if(numel(goodInds)<length(gtData.kps))
    validInds = goodInds;
else
    validInds = find(goodInds);
end

if(size(validInds,1)~=1)
    validInds = validInds';
end

totGood = 0;

for i = validInds
    bbox = gtData.bbox(i,:);
    gtKps = gtData.kps{i};
    if(size(gtKps,1)==2)
        gtKps = gtKps';
    end
    if(bbox(3)>=bbox(1) && bbox(4)>=bbox(2) && ~isempty(gtKps))        
        kpCoords=preds(i).coords;
        %scores = preds(i).scores;
        kpCoords = kpCoords';
        if(isfield(gtData,'pascalbox'))
            radius = alpha*(max(gtData.pascalbox(i,[3 4]) - gtData.pascalbox(i,[1 2]))); %for pascalRigid
        end
        %disp(radius);
        
        if(radius>0) %else points are not annotated
            totGood = totGood + 1;
            for kp = 1:min(numKps,size(kpCoords,1))                                
                if(~isnan(gtKps(kp,2)))
                    totalLoc(kp) = totalLoc(kp) + 1;
                    %below statement returns false if the prediction is nan
                    goodPred = double(norm(kpCoords(kp,:)-gtKps(kp,:))<=radius);
                    correct(kp) = correct(kp) + goodPred;
                    correctVis(kp) = correctVis(kp) + ~isnan(kpCoords(kp,2));
                    correctLoc(kp) = correctLoc(kp) + goodPred;
                else
                     goodPred = isnan(kpCoords(kp,2));
                     correct(kp) = correct(kp) + goodPred;
                     correctVis(kp) = correctVis(kp) + goodPred;
                end
            end
        end
    end
end

accuracyLoc = correctLoc./totalLoc;
accuracyVis = correctVis./totGood;
accuracy = correct./totGood;

end