function generateDetectionPoseFeatures(classInds,proto,suffix,inputSize,mirror)

globals;
suff = '';
if(mirror)
    suff = 'Mirror';
end

pascalValNamesFile = fullfile(cachedir,'pascalTrainValIds.mat');
valNames = load(pascalValNamesFile);
valNames = valNames.valIds;

dataStructsDir = fullfile(cachedir,['rcnnDetectionPredsVps'],[proto suff]);
mkdirOptional(dataStructsDir);

imgPredsDir = fullfile(cachedir,'rcnnImgDetectionPredsVps',[proto suff]);
mkdirOptional(imgPredsDir);

%% Getting boxes for all classes
dets = load(rcnnDetectionsFile);
for classInd = classInds
    for i=1:length(dets.chosenboxes{classInd})
        dataStructs(classInd).boxes{i} = [dets.chosenboxes{classInd}{i} dets.topscores{classInd}{i}] ;
    end
end

for classInd = classInds
    dataStructs(classInd).feat = {};
end

%% cnn model

protoFile = fullfile(prototxtDir,proto,'deploy.prototxt');
binFile = fullfile(snapshotsDir,'finalSnapshots',[suffix '.caffemodel']);

cnn_model=rcnn_create_model(protoFile,binFile);
cnn_model=rcnn_load_model(cnn_model);
cnn_model.cnn.input_size = inputSize;

meanNums = [102.9801,115.9465,122.7717]; %magical numbers given by Ross
for i=1:3
    meanIm(:,:,i) = ones(inputSize)*meanNums(i);
end

cnn_model.cnn.image_mean = single(meanIm);
cnn_model.cnn.batch_size=20;



%% Iterating over images

for i=1:length(valNames)
    disp([num2str(i) '/' num2str(length(valNames))]);
    voc_id = valNames{i};
    im = imread(fullfile(pascalImagesDir, [voc_id '.jpg']));
    bbox = [];
    scores = [];
    labels = [];
    starts = zeros(size(dataStructs));
    st = 1;
    
    for c = classInds
        cBox = dataStructs(c).boxes{i}(:,1:4);
        bbox = vertcat(bbox,cBox);
        scores = vertcat(scores,dataStructs(c).boxes{i}(:,5));
        labels = vertcat(labels,ones(size(cBox,1),1)*c);
        starts(c) = st;
        st = st + size(cBox,1);
    end
    
    tmp.voc_image_id = {voc_id};
    tmp.bbox = bbox;
    tmp.labels = labels;
    
    feat = rcnnFeaturesSingleBox(tmp,cnn_model,0,true);
    if(mirror)
        featMirror = rcnnFeaturesSingleBox(tmp,cnn_model,1,true);
        feat = addFeatMirrorFeat(feat,featMirror);
    end
    
    save(fullfile(imgPredsDir,voc_id),'bbox','labels','scores','feat');
    
    for c = classInds
        ct = size(dataStructs(c).boxes{i},1);
        dataStructs(c).feat{i} = feat(starts(c):(starts(c)+ct-1),:);
    end
end
save(fullfile(dataStructsDir,'allDets'),'dataStructs');

end


function feat = addFeatMirrorFeat(feat,featMirror)
if(size(feat,2)==56)
    permInds = [binMirrorPermInds(24),24+binMirrorPermInds(16),40+binMirrorPermInds(8),48+binMirrorPermInds(4)];
elseif(size(feat,2)==84)
    permInds = [21:-1:1,22:42,63:-1:43,70:-1:64,71:77,84:-1:78];
end
nPerm = numel(permInds);
%permInds
feat(:,1:nPerm) = (feat(:,1:nPerm)+featMirror(:,permInds))/2;

end

function inds = binMirrorPermInds(nBins)
    inds = 0:(nBins-1);
    inds = mod(-inds,nBins)+1;
end
