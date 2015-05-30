function [pred] = getNingPreds(class,dataStruct)
%GETNINGPREDS Summary of this function goes here
%   Detailed explanation goes here

globals;
load(fullfile(cachedir,'ningKeypoints','voc_data'));
load(fullfile(cachedir,'partNames',class));
load(fullfile(cachedir,'ningKeypoints',[class '_keypoints_conv5_3']));
cInd = pascalClassIndex(class);
ningData = config{cInd};
pred = [];

nKp = size(dataStruct.kps{1},1);
kpsPerm = zeros(nKp,1);
for i=1:length(partNames)
    kpsPerm(i) = find(ismember(ningData.classes,partNames{i}));
end
%%
for i=1:length(dataStruct.voc_image_id)
    kps = zeros(2,nKp);
    bbox = dataStruct.bbox(i,:);
    isGood = false;
    for j = (find(ismember(ningData.test_image_ids,dataStruct.voc_image_id{i})))'
        if sum(abs(ningData.test_bbox(j,:) - bbox))<=4
            kps = squeeze(predict_keypoints(j,kpsPerm,[1,2]))';
            kps = kps/500;
            kps(1,:) = bbox(1) + kps(1,:)*(bbox(3)-bbox(1));
            kps(2,:) = bbox(2) + kps(2,:)*(bbox(4)-bbox(2));
            isGood = true;
        end
    end
    pred(i).coords = kps;
    pred(i).scores = zeros(1,nKp);
    pred(i).found = isGood; 
end

end

