function [] = mainKpsPreprocess()
%MAINKPSPREPROCESS Summary of this function goes here
%   Detailed explanation goes here

globals;
%% imgwise annotations
% generatePascalImageAnnotations();

%% rcnn data files
% rcnnKpsDataCollect();

%% generate window file
% params.heatMapDims = [6 6];
% pascalKpsMulticlassTrainValCreate()
% 
% params.heatMapDims = [12 12];
% pascalKpsMulticlassTrainValCreate()

%% train the cnns


%% create dataStructs for test
for c = params.classInds
    class = pascalIndexClass(c);
    readKpsData(class);
end

%% add pose predictions features


end

