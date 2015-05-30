function [rotationData] = readVpsData(cls)
%READDATA Summary of this function goes here
%   Detailed explanation goes here

globals;

pascalData = readVpsDataPascal(cls,params.excludeOccluded);
fname = fullfile(rotationPascalDataDir,cls);
rotationData = pascalData;
save(fname,'rotationData');

imagenetData = readVpsDataImagenet(cls);
fname = fullfile(rotationImagenetDataDir,cls);
rotationData = imagenetData;
save(fname,'rotationData');

rotationData = horzcat(pascalData,imagenetData);
fname = fullfile(rotationJointDataDir,cls);
save(fname,'rotationData');

end

