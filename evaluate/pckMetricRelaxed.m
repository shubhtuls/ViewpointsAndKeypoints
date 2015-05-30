function [accuracy,total] = pckMetricRelaxed(preds,gtData,goodInds,flipKps)
%PCK Summary of this function goes here
%   Detailed explanation goes here

if(iscell(goodInds)) %passed the fnames
    goodInds = ismember(gtData.voc_image_id,goodInds);
end

globals;
alpha = params.alpha;
torsoKps = params.torsoKps;
numKps = length(preds(1).scores);

flip = true;
if(nargin < 4)
    flip = false;
end

correct = zeros(numKps,1);
total = zeros(numKps,1);

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
    %if(~mod(i,100))
    %    disp(i)
    %end
    bbox = gtData.bbox(i,:);
    gtKps = gtData.kps{i};
    if(size(gtKps,1)==2)
        gtKps = gtKps';
    end
    if(bbox(3)>=bbox(1) && bbox(4)>=bbox(2) && ~isempty(gtKps))
        totGood = totGood + 1;
        kpCoords=preds(i).coords;
        %scores = preds(i).scores;
         if(isfield(gtData,'headbox'))
            radius = alpha*(max(gtData.headbox(i,[2 4])) - min(gtData.headbox(i,[2 4]))); %for mpi
        elseif(isfield(gtData,'pascalbox'))
            radius = alpha*(max(gtData.pascalbox(i,[3 4]) - gtData.pascalbox(i,[1 2]))); %for pascalRigid
        else
            radius = normDist(gtKps,torsoKps,alpha);
        end
        
        if(radius>0) %else points are not annotated
            for kp = 1:numKps
                if(~isnan(gtKps(kp,2)))
                    gtKp = gtKps(kp,:);
                    predKp = kpCoords(:,kp);

                    if(flip)
                        flipKp = gtKps(flipKps(kp),:);
                        correct(kp) = correct(kp) + double(iscorrect(gtKp',predKp,radius) || iscorrect(flipKp',predKp,radius));
                    else
                        correct(kp) = correct(kp) + double(iscorrect(gtKp',predKp,radius));
                    end
                    total(kp) = total(kp) + 1;
                end
            end
        end
    end
end
accuracy = correct./total;
end

function corr = iscorrect(gtKp,predKp,radius)
    corr = false;
    if(iscell(predKp))
        predKp = predKp{1};
    end
    for i=1:size(predKp,2)
        corr = corr || (norm(gtKp-predKp(:,i))<=radius);
    end
    
end