%% Init
startup;
globals;
load(fullfile(cachedir,'pascalTrainValIds'));
params.heatMapDims = [12 12];

%% Pose Priors
for c = params.classInds
    class = pascalIndexClass(c);
    posePriorMaps(class,trainIds);
end

priorAlphas = [0 0.2];% whether or not we use pose prior
aps = zeros(numel(priorAlphas,20));

%% Iterate over classes
for c = params.classInds
    class = pascalIndexClass(c);
    annot = getKeypointannotationStruct(class,valIds);
    preds = computePredictionStruct(class,(unique(annot.img_name)),priorAlphas,'All');
    for d = 1:numel(priorAlphas)
        aps(d,c) = compute_kp_APK(annot,preds{d},0.2);
    end
    disp(aps(:,c))
end

%% Saving
save(fullfile(cachedir,'rigidApkResults'),'aps','priorAlphas');