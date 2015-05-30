function [] = readKpsData(class)
%READKPSDATA Summary of this function goes here
%   Detailed explanation goes here

globals;
classInd = pascalClassIndex(class);
fnames = getFileNamesFromDirectory(annotationDir,'types',{'.mat'});
load(fullfile(cachedir,'pascalTrainValIds.mat'));

dataStruct.voc_image_id = {};
dataStruct.bbox = [];
dataStruct.kps = {};
dataStruct.voc_rec_id = [];
dataStruct.occluded = [];

for i=1:length(fnames)
    if(~ismember(fnames{i}(1:end-4),vertcat(valIds,trainIds)))
        continue;
    end
    gt = load(fullfile(annotationDir,fnames{i}));
    goodInds = ismember(gt.class,classInd) & cellfun(@(x)~isempty(x),gt.kps');
    if(params.excludeOccluded)
        goodInds = goodInds & ~gt.occluded & ~gt.truncated & ~gt.difficult ;
    else
        goodInds = goodInds & ~gt.difficult ;
    end
    %goodInds = ismember(gt.class,classInds);
    if(sum(goodInds))
        dataStruct.voc_image_id = vertcat(dataStruct.voc_image_id,repmat({fnames{i}(1:end-4)},sum(goodInds),1));
        dataStruct.voc_rec_id = vertcat(dataStruct.voc_rec_id,gt.voc_rec_id(goodInds));
        dataStruct.kps = horzcat(dataStruct.kps,gt.kps(goodInds));
        dataStruct.bbox = vertcat(dataStruct.bbox,gt.bbox(goodInds,:));
        dataStruct.occluded = vertcat(dataStruct.occluded,gt.occluded(goodInds) | gt.truncated(goodInds));
    end
end

fname = fullfile(kpsPascalDataDir,class);
save(fname,'dataStruct');

end