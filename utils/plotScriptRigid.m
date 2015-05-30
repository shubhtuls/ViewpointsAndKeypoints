%% Feat
load(fullfile(cachedir,'partNames',class));
suffix = 'All';
type = 'Rigid';
params.heatMapDims = [12 12];
loadFeatRigid;
featBase = feat6;

%[priorFeat] = posePrior(dataStruct,class,fnamesTrain);
%priorFeat = feat12;
%suffix = 'Old';
%params.heatMapDims = [12 12];
%loadFeatRigid;
%featRoss = feat12+feat6;
%featBase2 = (feat12+feat6) + log(priorFeat+eps);
%featBase2 = (1./(1+exp(-feat12-feat6))).*priorFeat;
featBase2 = feat12;

%% Eval
dataStruct.pascalbox = dataStruct.bbox; %hack to make pck Evaluation happy
perfBase = [];perfCands = [];
perfBase2 = [];perfCandsRoss = [];
alphas = [0.01:0.01:0.2];
params.predMethod = 'maxLocationCandidates';
params.heatMapDims = [12 12];
%predCands = predictAll(featBase,dataStruct);
%predCands = getNingPreds(class,dataStruct);
%params.heatMapDims = [24 24];
%predCandsRoss = predictAll(featRoss,dataStruct);

params.predMethod = 'maxLocation';
params.heatMapDims = [12 12];
predBase = predictAll(featBase,dataStruct);
%params.heatMapDims = [24 24];
predBase2 = predictAll(featBase2,dataStruct);
%predBase = getNingPreds(class,dataStruct);
%predBase2 = predBase;

for alpha = alphas
    params.alpha = alpha;
    %[acc,tot] = pckMetric(predCands,dataStruct,dontUseTheseFnamesTest);
    %perfCands = [perfCands;acc'];
    [acc,tot] = pckMetric(predBase,dataStruct,vertcat(dontUseTheseFnamesTest,fnamesVal));
    perfBase = [perfBase;acc'];
    
%     [acc,tot] = pckMetricRelaxed(predCandsRoss,dataStruct,fnamesVal);
%     perfCandsRoss = [perfCandsRoss;acc'];
     [acc,tot] = pckMetric(predBase2,dataStruct,vertcat(dontUseTheseFnamesTest,fnamesVal));
     perfBase2 = [perfBase2;acc'];
end

%% Plot
subplot(1,2,1);
cMap = uniqueColors(1,length(partNames));
for p=1:length(partNames)
    plot(alphas,perfBase(:,p),'Color',cMap(p,:));hold on;
end
ylim([0 1]);
legend(partNames,'location','NorthWest');
title([class ' : ' num2str(mean(perfBase(10,:)))]);

subplot(1,2,2)
for p=1:length(partNames)
    plot(alphas,perfBase2(:,p),'Color',cMap(p,:));hold on;
end
ylim([0 1]);
legend(partNames,'location','NorthWest');
title([class ' : ' num2str(mean(perfBase2(10,:)))]);

