function [accuracy,total] = pckMetric(preds,gtData,goodInds)
%PCK Summary of this function goes here
%   Detailed explanation goes here

if(iscell(goodInds)) %passed the fnames
    goodInds = ismember(gtData.voc_image_id,goodInds);
end
globals;
alpha = params.alpha;
%torsoKps = params.torsoKps;
numKps = length(preds(1).scores);
%numKps = 14;

correct = zeros(numKps,1);
total = zeros(numKps,1);
%goodInds = ismember(gtData.voc_image_id,fnames);
% have torso kps and gt kps for kpInd

%poseCands = load(fullfile(cachedir,'poseCandidates','person'));
%W = load(fullfile(cachedir,'regressionWeights','personFiner'));W = W.W;

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
        kpCoords = kpCoords';        
        if(isfield(gtData,'headbox'))
            radius = alpha*(max(gtData.headbox(i,[2 4])) - min(gtData.headbox(i,[2 4]))); %for mpi
        elseif(isfield(gtData,'pascalbox'))
            radius = alpha*(max(gtData.pascalbox(i,[3 4]) - gtData.pascalbox(i,[1 2]))); %for pascalRigid
            %disp(radius);disp(gtData.pascalbox(i,:));
        else
            radius = normDist(gtKps,torsoKps,alpha);
            
        end
        %disp(radius);
        
        if(radius>0) %else points are not annotated
            for kp = 1:min(numKps,size(kpCoords,1))
                if(~isnan(gtKps(kp,2)))
                    total(kp) = total(kp) + 1;
                    %below statement returns false if the prediction is nan
                    correct(kp) = correct(kp) + double(norm(kpCoords(kp,:)-gtKps(kp,:))<=radius);
                    %correct(kp) = correct(kp) + double((norm(kpCoords(kp,:)-gtKps(kp,:))<=radius) || (norm(kpCoords(kp,:)-gtKps(flipKp,:))<=radius));
                end
            end
        end
    end
end
accuracy = correct./total;
end