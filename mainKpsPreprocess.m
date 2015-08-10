function [] = mainKpsPreprocess()
%MAINKPSPREPROCESS Summary of this function goes here
%   Detailed explanation goes here

globals;
%% imgwise annotations
generatePascalImageAnnotations();

%% rcnn data files
rcnnKpsDataCollect();

%% generate partName labels
mkdirOptional(fullfile(cachedir,'partNames'));
for c = params.classInds
    class = pascalIndexClass(c);
    var = load(fullfile(segkpAnnotationDir,class));
    partNames = var.keypoints.labels;
    save(fullfile(cachedir,'partNames',class),'partNames');
end

%% generate window file
params.heatMapDims = [6 6];
pascalKpsMulticlassTrainValCreate()
% 
params.heatMapDims = [12 12];
pascalKpsMulticlassTrainValCreate()

%% train the cnns

end