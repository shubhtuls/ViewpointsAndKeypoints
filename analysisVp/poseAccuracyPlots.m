function [] = poseAccuracyPlots()
%POSEACCURACYPLOTS Summary of this function goes here
%   Detailed explanation goes here
globals;
classes = {'aeroplane','bicycle','bird','boat','bottle','bus','car','cat','chair','cow','diningtable','dog','horse','motorbike','person','plant','sheep','sofa','train','tvmonitor'};
classInds = [1 2 4 5 6 7 9 11 14 18 19 20];

plotDir = fullfile(cachedir,'figures','poseGtAccuracy');
mkdir(plotDir);

colors = colormap(lines(2));

for c=classInds
    params.features = 'fcSelectiveJoint';
    class = classes{c};
    [~,~,testErrs] = regressToPose(class);
    errSort = sort(testErrs,'ascend');
    plot(errSort,[1:length(errSort)]/length(errSort),'Color',colors(1,:),'Linewidth',10);ylim([0 1]);
    hold on;

    params.features = 'fcSelective5Joint';
    [~,~,testErrs] = regressToPose(class);
    errSort = sort(testErrs,'ascend');
    plot(errSort,[1:length(errSort)]/length(errSort),'Color',colors(2,:),'Linewidth',10);ylim([0 1]);
    hold on;
    
    hlegend = legend('Ours','Linear (Ghodrati et. al)');
    title(class,'FontSize',30);
    set(hlegend,'location','southeast');
    set(hlegend,'FontSize',30);
    set(gcf,'color','w');
    
    export_fig(fullfile(plotDir,[class '.pdf']));
    pause();
    close all;
end

end