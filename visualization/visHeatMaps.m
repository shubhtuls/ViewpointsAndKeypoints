function [] = visHeatMaps(dataStruct,feat,kpIndices,goodInds)
%VISHEATMAPS Summary of this function goes here
%   Detailed explanation goes here

if(iscell(goodInds)) %passed the fnames
    goodInds = ismember(dataStruct.voc_image_id,goodInds);
end
validInds = 1:length(dataStruct.voc_image_id);
globals;
visMethod = params.visMethod;
hDims = params.heatMapDims;

validInds = validInds(goodInds);
nKps = numel(kpIndices);
figH = 2;
figW = ceil(nKps/2 + 0.5);

for i = validInds
    gtKps = dataStruct.kps{i};
    if(size(gtKps,2)==2)
        gtKps = gtKps';
    end
    im = imread(fullfile(imagesDir,[dataStruct.voc_image_id{i} '.jpg']));
    bbox = round(dataStruct.bbox(i,:));
    if(bbox(3)>=(bbox(1)+50) && bbox(4)>=(bbox(2)+50) && (sum(~isnan(gtKps(:)))>=8) && ~isempty(gtKps))
        deltaX = ceil(max([0,-bbox(1)+1,-size(im,2)+bbox(3)]));
        deltaY = ceil(max([0,-bbox(2)+1,-size(im,1)+bbox(4)]));
        im2 = uint8(zeros(size(im,1)+2*deltaY,size(im,2)+2*deltaX,3));
        im2(deltaY+[1:size(im,1)],deltaX+[1:size(im,2)],:)=im;
        im = im2(deltaY+[bbox(2):bbox(4)],deltaX+[bbox(1):bbox(3)],:);

        subplot(figH,figW,1);
        imagesc(im);axis image;
        kpCoords = predict(feat(i,:),bbox,visMethod,hDims);
        
        for k=1:nKps
            kpInd = kpIndices(k);
            kpInds = (kpInd-1)*hDims(1)*hDims(2) + [1:hDims(1)*hDims(2)];
            heatIm = feat(i,kpInds);
            
            heatIm = imresize(reshape(heatIm,[hDims(2) hDims(1)]),[size(im,1),size(im,2)]);
            img=im2double(im);
            im1=zeros(size(img));
            img=rgb2gray(img);
            im1(:,:,1)=0.2*img;
            im1(:,:,2)=0.2*img+0.8*heatIm;
            im1(:,:,3)=0.8*heatIm+0.2*img;
            im1 = max(im1,0);im1 = min(im1,1);

            subplot(figH,figW,1+k);
            imagesc(im1);axis image;
            hold on;
            plot(kpCoords(1,kpInd)-bbox(1),kpCoords(2,kpInd)-bbox(2),'r.','MarkerSize',5);hold on;
            hold on;

            plot(gtKps(1,kpInd)-bbox(1),gtKps(2,kpInd)-bbox(2),'w.','MarkerSize',5);hold on;
            
        end
         pause();
        close all;
    end
end

end
