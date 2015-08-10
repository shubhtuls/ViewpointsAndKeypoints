clear;
startup;
globals;
load(fullfile(cachedir,'pascalTrainValIds'));
perf = zeros(14,20);

for c = params.classInds
    class = pascalIndexClass(c);
    disp(class)
    load(fullfile(cachedir,'partNames',class));
    %suffix = 'All';
    
    %type = 'Rigid';
    %type = 'RigidAllPascal';
    params.heatMapDims = [24 24];
    params.kpsNet = 'vgg';
    loadFeatRigid;
    [priorFeat] = posePrior(dataStruct,class,trainIds);
    
    %% box areas
    Hs = dataStruct.bbox(:,4)-dataStruct.bbox(:,2);
    Ws = dataStruct.bbox(:,3)-dataStruct.bbox(:,1);
    Ars = Hs.*Ws;
    
    %% feat
    featStruct{1} = feat12+feat6;
    %featStruct{2} = feat12+feat6;
    featStruct{2} = (feat12+feat6) + log(priorFeat+eps);
    testInds = ismember(dataStruct.voc_image_id,valIds);

    %% normal
    goodInds{1} = testInds & ~dataStruct.occluded;
    
    %% occluded
    goodInds{2} = testInds & dataStruct.occluded;
    
    %% small and large
    N = round(sum(goodInds{1}/3));
    sortArs = sort(Ars(goodInds{1}));
    smallAr = sortArs(N);bigAr = sortArs(end-N);
    goodInds{3} = testInds & ~dataStruct.occluded & (Ars <=smallAr);
    goodInds{4} = testInds & ~dataStruct.occluded & (Ars >= bigAr);    
    
    %% flipKps perm
    kpsPerm = findKpsPerm(partNames);
    
    %% pred
    acc = [];
    dataStruct.pascalbox = dataStruct.bbox; %hack to make pck Evaluation happy
    
    for i=1:(length(featStruct))
        params.predMethod = 'maxLocation';
        params.alpha = 0.1;
        feat = featStruct{i};
        pred = predictAll(feat,dataStruct);
        for j=1:length(goodInds)
            acc(i,j) = mean(pckMetric(pred,dataStruct,goodInds{j}));
        end
        acc(i,length(goodInds)+1) = mean(pckMetricRelaxed(pred,dataStruct,goodInds{1},kpsPerm));
        params.alpha = 0.2;
        acc(i,length(goodInds)+2) = mean(pckMetric(pred,dataStruct,goodInds{1}));
        params.alpha = 0.1;
        params.predMethod = 'maxLocationCandidates';
        pred = predictAll(feat,dataStruct);
        acc(i,length(goodInds)+3) = mean(pckMetricRelaxed(pred,dataStruct,goodInds{1}));        
    end
    acc = acc';
    
    disp(acc)
    perf(:,c) = acc(:);
    
end

perf = perf(:,params.classInds);
perf = [perf mean(perf,2)];