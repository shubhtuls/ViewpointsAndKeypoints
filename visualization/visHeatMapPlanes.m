function [] = visHeatMapPlanes(dataStruct,featStruct,kpIndices,goodInds,save)
%VISHEATMAPS Summary of this function goes here
%   Detailed explanation goes here

if(iscell(goodInds)) %passed the fnames
    goodInds = ismember(dataStruct.voc_image_id,goodInds);
end
validInds = 1:length(dataStruct.voc_image_id);
globals;
hDims = params.heatMapDims;

validInds = validInds(goodInds);
nKps = numel(kpIndices);

plotH = 2;plotW = ceil((1+length(featStruct))/2);

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
        
        im = imresize(im,50*[hDims(2) hDims(1)]);
        if(~save)
            subplot(plotH,plotW,1);
        end
        imagesc(im);axis equal;
        %warp(im,0);axis equal;
        axis off;
        if(save)
            keyboard;
        end
                
        step = 2/nKps;       
        imXs = [-1 0 1;-1 0 1];
        imYs = [1 1 1; -1 -1 -1];
        imZs = -step*[-1 -1 -1; -1 -1 -1];
        for f = 1:length(featStruct)
            if(~save)
                subplot(plotH,plotW,1+f);
            end
            feat = featStruct{f};
            for k=1:nKps
                kpInd = kpIndices(k);
                kpInds = (kpInd-1)*hDims(1)*hDims(2) + [1:hDims(1)*hDims(2)];
                heatIm = feat(i,kpInds);
                if(max(max(heatIm))<0.5)
                    heatIm = 0.5*heatIm/(max(max(heatIm)));
                end
                %heatIm = imresize(reshape(heatIm,[hDims(2) hDims(1)]),[size(im,1),size(im,2)]);
                heatIm = imresize(reshape(heatIm,[hDims(2) hDims(1)]),[size(im,1),size(im,2)]);
                img=im2double(im);
                im1=zeros(size(img));
                img=rgb2gray(img);
                delta = 0.2;
                im1(:,:,1)=delta*img;
                im1(:,:,2)=delta*img+(1-delta)*heatIm;
                im1(:,:,3)=(1-delta)*heatIm+delta*img;
                im1 = max(im1,0);im1 = min(im1,1);
                im1 = rgb2gray(im1);
                warp(imXs+k*step,imYs+k*step,imZs*k,im1);hold on;
            end
            colormap jet;
            view(0,-90);
            axis off;axis equal;
            %export_fig(['bikeMap' num2str(f) '.png'],'-transparent')
            %export_fig(['bikeMap' num2str(f) '.pdf'])
            %pause(1);
            if(save)
                set(gcf,'color','w');
                keyboard;
            end
        end
        title(dataStruct.voc_image_id{i});
        pause();
        close all;
    end
end

end
