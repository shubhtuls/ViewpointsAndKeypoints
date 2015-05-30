function [] = visHeatMapVolume(dataStruct,feat,kpIndices,goodInds)
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
        subplot(1,2,1);
        %imagesc(im);axis equal;
        warp(im,0);axis equal;
        axis off;
        
        V = zeros(10*hDims(2),10*hDims(1),nKps);
        Vdims = size(V);
        subplot(1,2,2);
        view(60,60);
               
        for k=1:nKps
            kpInd = kpIndices(k);
            kpInds = (kpInd-1)*hDims(1)*hDims(2) + [1:hDims(1)*hDims(2)];
            heatIm = feat(i,kpInds);
            %heatIm = imresize(reshape(heatIm,[hDims(2) hDims(1)]),[size(im,1),size(im,2)]);
            heatIm = imresize(reshape(heatIm,[hDims(2) hDims(1)]),[size(im,1),size(im,2)]);
            img=im2double(im);
            im1=zeros(size(img));
            img=rgb2gray(img);
            delta = 0.1;
            im1(:,:,1)=delta*img;
            im1(:,:,2)=delta*img+(1-delta)*heatIm;
            im1(:,:,3)=(1-delta)*heatIm+delta*img;
            im1 = max(im1,0);im1 = min(im1,1);
            V(:,:,nKps-k+1) = (imresize(rgb2gray(im1),[Vdims(2) Vdims(1)]))';
            %warp(im1,100*k);hold on;axis equal;
        end
        [x,y,z] = meshgrid(1:Vdims(1),1:Vdims(2),[1:Vdims(3)]);
        step = 5;
        
        z = step*z;
        slice(x,y,z,V,[],[],[step:step:step*nKps]);
        colormap jet;
        camproj('perspective');axis equal;
        campos([5*Vdims(1),10*Vdims(2),10]);
        view(60,60);
        axis off;
        pause();
        close all;
    end
end

end
