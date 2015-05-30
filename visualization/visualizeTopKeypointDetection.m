function [] = visualizeTopKeypointDetection(pred,kpInd,lambda,class)
%VISLIALIZETOPKEYPOINTDETECTION Summary of this function goes here
%   Detailed explanation goes here

globals;
featSize = params.heatMapDims(1)*params.heatMapDims(2);
featInds = (kpInd-1)*featSize + [1:featSize];

scores = lambda*pred.scores(kpInd,:) + (1-lambda)*pred.regScores(kpInd,:);
[~,ids] = sort(scores,'descend');
count = 0;

for i=ids
    count = count+1;
    coord = pred.coords(kpInd,:,i);
    bbox = pred.bbox(i,:);
    
    imName = pred.img_name{i};
    im = imread(fullfile(imagesDir,[imName '.jpg']));
    [hMax,wMax,~] = size(im);
    
    W = bbox(3)-bbox(1);
    H = bbox(4)-bbox(2);
    delta = 0.2;
    
    topPt = max(round([bbox(2) bbox(1)] - delta*[H W]),1);
    botPt  = round([bbox(4) bbox(3)] + delta*[H W]);
    botPt(1) = min(botPt(1),hMax);
    botPt(2) = min(botPt(2),wMax);

    showboxes(im,bbox);
    coord = coord - [topPt(2) topPt(1)];
    bbox = bbox - [topPt(2) topPt(1) topPt(2) topPt(1)];
    im = im(topPt(1):botPt(1),topPt(2):botPt(2),:);
    
    a1 = 0.3;
    a2 = 0.6;
    im = im2double(im);
    im = im*a1 + 1-a1;
    bbox  = round(bbox);
    bbox = max(bbox,1);
    im(bbox(2):bbox(4),bbox(1):bbox(3),:) =1-a2+a2*(im(bbox(2):bbox(4),bbox(1):bbox(3),:)-1+a1)/a1;
        
    showboxes(im,bbox);

    hold on;
    plot(coord(1),coord(2),'b.','Markersize',100);axis image;
    export_fig(['cache/images/keypointDets/' class '/' num2str(count) '.png'])
    pause();close all;
    
    
end

end