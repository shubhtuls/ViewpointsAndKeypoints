function generateDetectionKpsFeatures(classInds,proto,suffix,inputSize,batchSize)

globals;
suff = '';

pascalValNamesFile = fullfile(cachedir,'pascalTrainValIds.mat');
valNames = load(pascalValNamesFile);
valNames = valNames.valIds;

imgPredsDir = fullfile(cachedir,'rcnnImgDetectionPredsKps',[proto suff]);
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
cnn_model.cnn.batch_size=batchSize;

key = keypointKey();
N = key.totKps;
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

    feat = rcnnFeaturesSingleBox(tmp,cnn_model,0,false);
    mapSize = size(feat,2)/N;

    for c = classInds
        class = pascalIndexClass(c);
        st = getfield(key.start,class);
        n = getfield(key.numKps,class);
        classEx = (labels == c);
        dataStructsImg(c).bbox = bbox(classEx,:);
        dataStructsImg(c).scores = scores(classEx,:);
        goodFeat = (st-1)*mapSize+[1:(n*mapSize)];
        dataStructsImg(c).feat = feat(classEx,goodFeat);

    end

    save(fullfile(imgPredsDir,voc_id),'dataStructsImg');

end

end

function key = keypointKey()

start.aeroplane = 1;
start.bicycle = 17;
start.boat = 28;
start.bottle = 39;
start.bus = 47;
start.car = 55;
start.chair = 69;
start.diningtable = 79;
start.motorbike = 87;
start.sofa = 97;
start.train = 109;
start.tvmonitor = 116;
key.start = start;

start.aeroplane = 16;
start.bicycle = 11;
start.boat = 11;
start.bottle = 8;
start.bus = 8;
start.car = 14;
start.chair = 10;
start.diningtable = 8;
start.motorbike = 10;
start.sofa = 12;
start.train = 7;
start.tvmonitor = 8;
key.numKps = start;
key.totKps = 123;
end

