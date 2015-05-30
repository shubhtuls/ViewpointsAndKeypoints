function [] = createEvalSets(class)
%CREATEEVALSETS Summary of this function goes here
%   Detailed explanation goes here

%disp('Creating Eval Sets');

globals;

mkdirOptional(fullfile(cachedir,'evalSets'));
saveFile = fullfile(cachedir,'evalSets',class);

%% Data for train & test sets

var = load(fullfile(cachedir,'rcnnPredsVps',params.features,class));
feat = var.feat;
var = load(fullfile(rotationPascalDataDir,class));
rotData = var.rotationData;

rec_ids = vertcat(rotData.voc_rec_id);
bboxes = vertcat(rotData.bbox);
occluded = vertcat(rotData.occluded);
truncated = vertcat(rotData.truncated);
IoUs = vertcat(rotData.IoU);
%voc_ids = vertcat(rotData.voc_image_id);
objectInds = vertcat(rotData.objectInd);

%eulers = horzcat(rotData.euler);eulers = eulers';
eulers = [];rots = [];goodInds = [];voc_ids = {};masks = {};
for i=1:length(rotData)
    if(~isempty(rotData(i).euler) && sum(rotData(i).euler == 0)~=3)
        goodInds(end+1)=i;
        rot = rotData(i).rot(:);
        rots(end+1,:)=rot';
        eulers(end+1,:) = rotData(i).euler';
        voc_ids{end+1} = rotData(i).voc_image_id;
        masks{end+1} = rotData(i).mask;
    end
end
feat = feat(goodInds,:);
rec_ids = rec_ids(goodInds);
%voc_ids = voc_ids(goodInds);
bboxes = bboxes(goodInds,:);
occluded = occluded(goodInds);
truncated = truncated(goodInds);
IoUs = IoUs(goodInds);
objectInds = objectInds(goodInds);

%% Creating train, val, test partitions

sets = load(fullfile(cachedir,'pascalTrainValIds'));

%% Train
inds = ismember(voc_ids,sets.trainIds);
data.feat = feat(inds,:);
data.eulers = eulers(inds,:);
data.rots = rots(inds,:);
data.voc_ids = voc_ids(inds);
data.rec_ids = rec_ids(inds);
data.bboxes = bboxes(inds,:);
data.occluded = occluded(inds,:);
data.truncated = truncated(inds,:);
data.IoUs = IoUs(inds,:);
data.masks = masks(inds);
data.objectInds = objectInds(inds);
train = data;

%% Val
inds = ismember(voc_ids,sets.valIds);
data.feat = feat(inds,:);
data.eulers = eulers(inds,:);
data.rots = rots(inds,:);
data.voc_ids = voc_ids(inds);
data.rec_ids = rec_ids(inds);
data.bboxes = bboxes(inds,:);
data.occluded = occluded(inds,:);
data.truncated = truncated(inds,:);
data.IoUs = IoUs(inds,:);
data.masks = masks(inds);
data.objectInds = objectInds(inds);
test = data;

%% Save
save(saveFile,'train','test','-v7.3');

end

