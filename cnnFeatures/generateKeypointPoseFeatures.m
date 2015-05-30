function generateKeypointPoseFeatures(proto,suffix,inputSize,classInd,mirror)

globals;
protoFile = fullfile(prototxtDir,proto,'deploy.prototxt');
binFile = fullfile(snapshotsDir,'finalSnapshots',[suffix '.caffemodel']);

cnn_model=rcnn_create_model(protoFile,binFile);
cnn_model=rcnn_load_model(cnn_model);
cnn_model.cnn.input_size = inputSize;
suff = '';

if(mirror)
    suff = 'Mirror';
end
meanNums = [102.9801,115.9465,122.7717]; %magical numbers given by Ross
for i=1:3
    meanIm(:,:,i) = ones(inputSize)*meanNums(i);
end
cnn_model.cnn.image_mean = single(meanIm);
cnn_model.cnn.batch_size=20;

%keyboard;
mkdirOptional(fullfile(cachedir,'rcnnPredsVpsKeypoint',[proto suff]));
for ind = classInd
    class = pascalIndexClass(ind);
    load(fullfile(kpsPascalDataDir,class));
    tmp = dataStruct;
    tmp.labels = ones(size(tmp.bbox,1),1)*ind;
    %keyboard;
    feat = rcnnFeaturesSingleBox(tmp,cnn_model,0,true);
    if(mirror)
        featMirror = rcnnFeaturesSingleBox(tmp,cnn_model,1,true);
        feat = addFeatMirrorFeat(feat,featMirror);
    end
    %keyboard;
    save(fullfile(cachedir,'rcnnPredsVpsKeypoint',[proto suff],class),'feat');
end

end

function feat = addFeatMirrorFeat(feat,featMirror)

permInds = [21:-1:1,22:42,63:-1:43,70:-1:64,71:77,84:-1:78];
feat(:,1:84) = (feat(:,1:84)+featMirror(:,permInds))/2;

end