function [] = visualizePoseKeypoints(dataStruct,class,goodInds,preds)
%VISUALIZEPOSEKEYPOINTS Summary of this function goes here
%   Detailed explanation goes here

%% Preprocess
predExternal = true;
if(nargin<4)
    predExternal = false;
else
    if(~iscell(preds))
        preds = {preds};
    end
end

globals;
imagesDir = PASCAL_DIR;
if(iscell(goodInds)) %passed the fnames
    goodInds = ismember({dataStruct(:).voc_image_id},goodInds);
end
dataStruct = dataStruct(goodInds);

if(predExternal)
    for i=1:length(preds)
        preds{i} = preds{i}(goodInds,:);
    end
    encoding = params.angleEncoding;

    for i=1:length(preds)
        eulersPred{i} = decodePose(preds{i},encoding);
        rotsPred{i} = encodePose(eulersPred{i},'rot');
    end
else
    tmp = [dataStruct(:).euler];eulersPred{1} = tmp';
    rotsPred{1} = encodePose(eulersPred{1},'rot');
end

%% Visualization

load(fullfile(cachedir,'sfmModels',class));
featData = loadHeatMapFeat(dataStruct,class,'conv12');

for n=1:length(dataStruct)
    for c = 1:length(rotsPred)
        R = reshape(rotsPred{c}(n,:),3,3);
        [~,kps] = poseKeypointScore(R,featData(n),model);
        
        bbox = dataStruct(n).bbox;
        xGt = dataStruct(n).kps(:,1) - bbox(1);
        yGt = dataStruct(n).kps(:,2) - bbox(2);
        x  = kps(1,:) - bbox(1);
        y  = kps(2,:) - bbox(2);
        
        maps = featData(n).kpFeat;
        [H,W,Kp] = size(maps);
        plotH = 2;plotW = ceil((Kp+1)/plotH);
        
        %% Reading Image
        im = imread(fullfile(imagesDir,[dataStruct(n).voc_image_id '.jpg']));
        bbox = round(dataStruct(n).bbox);
        deltaX = ceil(max([0,-bbox(1)+1,-size(im,2)+bbox(3)]));
        deltaY = ceil(max([0,-bbox(2)+1,-size(im,1)+bbox(4)]));
        im2 = uint8(zeros(size(im,1)+2*deltaY,size(im,2)+2*deltaX,3));
        im2(deltaY+[1:size(im,1)],deltaX+[1:size(im,2)],:)=im;
        im = im2(deltaY+[bbox(2):bbox(4)],deltaX+[bbox(1):bbox(3)],:);
        img=im2double(im);
        img=rgb2gray(img);
        
        subplot(plotH,plotW,1);
        imshow(im);axis equal;
        hold on;
        
        %% Showing map images
        for kp = 1:Kp
            heatIm = maps(:,:,kp);
            
            heatIm = normalizeHeatIm(heatIm);
            maps(:,:,kp) = heatIm;
            
            heatIm = imresize(heatIm,[size(im,1),size(im,2)]);

            im1=zeros(size(img));
            im1(:,:,1)=0.2*img+0.8*heatIm;
            im1(:,:,2)=0.2*img+0.8*heatIm;
            im1(:,:,3)=0.2*img;
            im1 = max(im1,0);im1 = min(im1,1);
            subplot(plotH,plotW,kp+1);
            %imagesc(im1);axis equal;
            imshow(im1);axis equal;
            hold on;
            plot(x(kp),y(kp),'r.');hold on;
            plot(xGt(kp),yGt(kp),'c.');
            title(dataStruct(n).part_names{kp});
        end
        pause();close all;
        
    end
end

end