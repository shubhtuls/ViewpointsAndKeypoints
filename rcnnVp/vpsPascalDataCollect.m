function [] = vpsPascalDataCollect()

%RCNNIMAGENETDATACOLLECT Summary of this function goes here
%   Detailed explanation goes here


%% Initialize
globals;
delete([rcnnVpsPascalDataDir '/*.mat']);

%% Format of file saved
% for each image, same file containing -
% classIndex overlap bbox regionIndex eulers


%% Iterate over classes
classes = {'aeroplane','bicycle','bird','boat','bottle','bus','car','cat','chair','cow','diningtable','dog','horse','motorbike','person','plant','sheep','sofa','train','tvmonitor'};
classInds = [1 2 4 5 6 7 9 11 14 18 19 20];

for classInd = classInds
    class = classes{classInd};
    disp(class);
    rotationData = load(fullfile(cachedir,'rotationDataPascal',class));
    rotationData = rotationData.rotationData;
    rotationData = rotationData(ismember({rotationData(:).dataset},'pascal'));
    
    for n=1:length(rotationData)
        %disp([int2str(n) '/' int2str(length(rotationData))]);
        rcnnDataFile = fullfile(rcnnVpsPascalDataDir,[rotationData(n).voc_image_id '.mat']);
        bbox = overlappingBoxes(rotationData(n).bbox,rotationData(n).imsize);        
        nCands = size(bbox,1);
        
        classIndex = classInd*ones(nCands,1);
        overlap = ones(nCands,1); %actually, it's different but we don't really use it
        regionIndex = zeros(nCands,1);
        euler = repmat(rotationData(n).euler',nCands,1);
        imSize = rotationData(n).imsize;
        
        %% Saving
        if(~isempty(classIndex))
            if(exist(rcnnDataFile,'file'))
                rcnnData = load(rcnnDataFile);
                overlap = vertcat(rcnnData.overlap,overlap);
                euler = vertcat(rcnnData.euler,euler);
                bbox = vertcat(rcnnData.bbox,bbox);
                classIndex = vertcat(rcnnData.classIndex,classIndex);
                regionIndex = vertcat(rcnnData.regionIndex,regionIndex);
            end
            save(rcnnDataFile,'overlap','euler','bbox','classIndex','regionIndex','imSize');
        end
    end
end

end