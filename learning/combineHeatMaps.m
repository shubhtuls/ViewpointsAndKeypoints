function [feat,lambda] = combineHeatMaps(maps,dataStruct,goodInds)
%COMBINEHEATMAPS Summary of this function goes here
%   Detailed explanation goes here

if(iscell(goodInds)) %passed the fnames
    goodInds = ismember(dataStruct.voc_image_id,goodInds);
end

for i=1:length(maps)
    mapsTmp{i} = maps{i}(goodInds,:);
end
%dataStruct = dataStruct(goodInds);
tmp.kps = dataStruct.kps(goodInds);
tmp.bbox = dataStruct.bbox(goodInds,:);
if(isfield(dataStruct,'headbox'))
    tmp.headbox = dataStruct.headbox(goodInds,:);
end
dataStruct = tmp;

goodInds = 1:numel(dataStruct.kps);

lambdas = 0:0.1:1;
nKps = max(size(dataStruct.kps{1}));
acc = zeros(nKps,length(lambdas),length(lambdas));

ct{1} = 0;

for l1 = lambdas
    ct{1} = ct{1}+1; ct{2} = 0;
    for l2 = lambdas
        ct{2} = ct{2}+1;
        l3 = 1-l1-l2;
        if(l3 >= 0)
            pred = predictAll(l1*mapsTmp{1}+l2*mapsTmp{2}+l3*mapsTmp{3},dataStruct,'maxLocation');
            acc(:,ct{1},ct{2}) = pckMetric(pred,dataStruct,goodInds);
        end
    end
end

dimsTot = size(maps{1},2)/nKps;
lambda1 = zeros(1,nKps);
lambda2 = zeros(1,nKps);
for n =1:nKps
    [~,lambda1(n)] = max(max(acc(n,:,:),[],3),[],2);
    [~,lambda2(n)] = max(max(acc(n,:,:),[],2),[],3);
end

lambda1 = lambdas(lambda1);
lambda2 = lambdas(lambda2);

l1 = repmat(lambda1,dimsTot,1);l1 = l1(:);l1 = l1';
l1 = repmat(l1,size(maps{1},1),1);

l2 = repmat(lambda2,dimsTot,1);l2 = l2(:);l2 = l2';
l2 = repmat(l2,size(maps{1},1),1);

l3 = 1-l1-l2;

feat = maps{1}.*l1 + maps{2}.*l2 + maps{3}.*l3;

lambda = [lambda1;lambda2;(1-lambda1-lambda2)];

end