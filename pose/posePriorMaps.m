function [] = posePriorMaps(class,fnamesTrain)
%POSEPRIORMAPS Summary of this function goes here
%   Detailed explanation goes here

globals;
nAngleBins = 21;
mapDims = params.heatMapDims;
saveDir = fullfile(cachedir,'posePriorMaps');
mkdirOptional(saveDir);
rData = load(fullfile(rotationPascalDataDir,class));
rData = rData.rotationData;
trainData = rData(ismember({rData(:).voc_image_id},fnamesTrain));

kpsStruct = load(fullfile(kpsPascalDataDir,class));
trainData = augmentKps(trainData,kpsStruct.dataStruct);

load(fullfile(cachedir,'partNames',class));

for e1=1:nAngleBins
    for e2=1:nAngleBins
        for e3=1:nAngleBins
            priorFeat{e1,e2,e3} = zeros(1,mapDims(1)*mapDims(2)*numel(partNames));
        end
    end
end

for e1=10:12
    disp(e1)
    for e2=1:nAngleBins
        for e3=1:nAngleBins
            feat = ones(1,84);
            feat(e1)=2;feat(nAngleBins+e2)=2;feat(2*nAngleBins+e3)=2; %feat s.t. argmax is correct
            pred = predsToRotation(feat);
            priorFeat{e1,e2,e3} = neighborMapsKpsScore(pred{1},[0 0 1 1],trainData);
        end
    end
end

disp('done');
save(fullfile(saveDir,class),'priorFeat');
end