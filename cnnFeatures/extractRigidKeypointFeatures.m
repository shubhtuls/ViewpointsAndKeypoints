function [] = extractRigidKeypointFeatures(classInds,inputSize,proto,suffix,batchSize)

globals;
protoFile = fullfile(prototxtDir,proto,'deploy.prototxt');
binFile = fullfile(snapshotsDir,'finalSnapshots',[suffix '.caffemodel']);

cnn_model = rcnn_create_model(protoFile,binFile,1);
cnn_model.cnn.batch_size = batchSize;
cnn_model = rcnn_load_model(cnn_model,1);
cnn_model.cnn.input_size = inputSize;

meanNums = [102.9801,115.9465,122.7717]; %magical numbers given by Ross
for i=1:3
    meanIm(:,:,i) = ones(inputSize)*meanNums(i);
end

cnn_model.cnn.image_mean = single(meanIm);
key = keypointKey();
imgBatchSize = 4*cnn_model.cnn.batch_size;
N = key.totKps;

for c = classInds
    class = pascalIndexClass(c);
    %keyboard;
    load(fullfile(kpsPascalDataDir,class));
    numIters = ceil(length(dataStruct.voc_image_id)/imgBatchSize);
    feat = [];
    st = getfield(key.start,class);
    n = getfield(key.numKps,class);

    for iter = 1:numIters
        start = (iter-1)*imgBatchSize+1;
        last = min(iter*imgBatchSize,length(dataStruct.voc_image_id));
        tmp.bbox = dataStruct.bbox(start:last,:);
        tmp.voc_image_id = dataStruct.voc_image_id(start:last);
        featTmp = rcnnFeaturesSingleBox(tmp,cnn_model);
        mapSize = size(featTmp,2)/N;
        goodFeat = (st-1)*mapSize+[1:(n*mapSize)];
        feat = vertcat(feat,featTmp(:,goodFeat));
    end

    saveDir = fullfile(cachedir,'rcnnPredsKps',suffix);
    mkdirOptional(saveDir);
    save(fullfile(saveDir,class),'dataStruct','feat');
    fprintf('done\n');
end

end


function key = keypointKey()

key = keypointKeyPascal();

end

function key = keypointKeyPascal()

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
