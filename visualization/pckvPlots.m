function [] = pckvPlots(correctThresh,correct,gtVis,kpInds)
%PCKVPLOTS Summary of this function goes here
%   Detailed explanation goes here
if(nargin<4)
    kpInds = 1:length(correct);
end
cMap = uniqueColors(1,numel(kpInds));
totGood = numel(correct{1});

for kp=kpInds
    plotX = [];
    plotY = [];
    visThreshes = correctThresh{kp}(gtVis{kp}==1 & correct{kp}==1);
    invisThreshes = correctThresh{kp}(gtVis{kp}==0);
    scores = [ones(size(visThreshes)) -1*ones(size(invisThreshes))];
    currScore = numel(invisThreshes);
    acc = currScore/totGood;
    threshes = [visThreshes invisThreshes];
    [threshes,I] = sort(threshes,'descend');
    scores = scores(I);
    for i=1:length(threshes)
        currScore = currScore + scores(i);
        plotX(i) = threshes(i);
        plotY(i) = currScore/totGood;
    end
    plot(plotX,plotY,'Color',cMap(kp,:));
    ylim([0 1]);
    hold on;
end


end