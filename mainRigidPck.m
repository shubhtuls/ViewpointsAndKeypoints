clear;
startup;
globals;
load(fullfile(cachedir,'pascalTrainValIds'));

perf = zeros(20,5);

%for c = 1     
for c = params.classInds
    class = pascalIndexClass(c);
    disp(class)
    params.heatMapDims = [24 24];
    params.kpsNet = 'vgg';
    loadFeatRigid;
    [priorFeat] = posePrior(dataStruct,class,trainIds);
    
    %% feat
    featStruct{1} = feat6;
    featStruct{2} = feat12;
    featStruct{3} = feat12+feat6;
    featStruct{4} = (feat12+feat6) + log(priorFeat+eps);
    
    %% pred
    
    dataStruct.pascalbox = dataStruct.bbox; %hack to make pck Evaluation happy
    params.predMethod = 'maxLocation';
    params.alpha = 0.1;
    acc = [];
    for i=1:(length(featStruct))
        feat = featStruct{i};
        pred = predictAll(feat,dataStruct);
        %acc(i) = mean(pckMetric(pred,dataStruct,valIds));
        acc(i) = mean(pckMetric(pred,dataStruct,ismember(dataStruct.voc_image_id,valIds) & ~dataStruct.occluded));
    end
    ningPreds = getNingPreds(class,dataStruct);
    acc(i+1) = mean(pckMetric(ningPreds,dataStruct,ismember(dataStruct.voc_image_id,valIds) & ~dataStruct.occluded));
    disp(acc)
    perf(c,:) = acc;
end
