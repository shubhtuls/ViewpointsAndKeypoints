function [] = visSfmInliers(dataStruct,pred,sfmModel,goodInds,wireframe,partNames)
%VISSFMINLIERS Summary of this function goes here
%   Detailed explanation goes here
globals;
if(iscell(goodInds)) %passed the fnames
    goodInds = ismember(dataStruct.voc_image_id,goodInds);
end

if(exist('wireframe','var'))
    showFrame = true;
    plotH = 1;
    plotW = 2;
else
    showFrame = false;
    plotH = 1;
    plotW = 1;
end

for i = find(goodInds')
    
    %% plotting image
    subplot(plotH,plotW,1);
    im = imread(fullfile(imagesDir,[dataStruct.voc_image_id{i} '.jpg']));
    bbox = round(dataStruct.bbox(i,:));
    maxDim = max(dataStruct.bbox(i,[3 4]) - dataStruct.bbox(i,[1 2]));
    if(maxDim<100)
        continue;
    end
    deltaX = ceil(max([0,-bbox(1)+1,-size(im,2)+bbox(3)]));
    deltaY = ceil(max([0,-bbox(2)+1,-size(im,1)+bbox(4)]));
    im2 = uint8(zeros(size(im,1)+2*deltaY,size(im,2)+2*deltaX,3));
    im2(deltaY+[1:size(im,1)],deltaX+[1:size(im,2)],:)=im;
    im = im2(deltaY+[bbox(2):bbox(4)],deltaX+[bbox(1):bbox(3)],:);
    imagesc(im);axis image;hold on;

    %% inliers        
    kpsPred = bsxfun(@minus,pred(i).coords,[deltaX+bbox(1);deltaY+bbox(2)]);
    
    [inliers,sfmPreds] = sfmRansac(kpsPred,sfmModel,0.2*maxDim);
    outliers = ~ismember(1:size(pred(i).coords,2),inliers);
    
    plot(kpsPred(1,inliers),kpsPred(2,inliers),'g.');
    plot(kpsPred(1,outliers),kpsPred(2,outliers),'r.');
    
    if(showFrame)
        subplot(plotH,plotW,2);
        imagesc(im);axis image;hold on;
        sfmPreds = [sfmPreds;zeros(1,size(sfmPreds,2))];
        visualizeWireframe(sfmPreds,partNames,wireframe);
    end
        
    pause();
    close all;
    
end

end