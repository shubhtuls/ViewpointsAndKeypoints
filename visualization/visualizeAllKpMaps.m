function [] = visualizeAllKpMaps(dataStruct,feat,class,goodInds,suffix)
%VISUALIZEALLKPMAPS Summary of this function goes here
%   Detailed explanation goes here

if(iscell(goodInds)) %passed the fnames
    goodInds = ismember(dataStruct.voc_image_id,goodInds);
end
validInds = 1:length(dataStruct.voc_image_id);
globals;

hDims = params.heatMapDims;

validInds = validInds(goodInds);
key = classKeypointKey(class);
H = 2;
W = ceil((length(key.groups)+1)/H);
visDir = fullfile(cachedir,'rigidKpVis',class,suffix);
mkdir(visDir);
delete(fullfile(visDir,'*'));

for j = 1:length(validInds)
    i = validInds(j);
    im = imread(fullfile(imagesDir,[dataStruct.voc_image_id{i} '.jpg']));
    bbox = round(dataStruct.bbox(i,:));
    subplot(1,3,3);imagesc(im);axis equal;
    deltaX = ceil(max([0,-bbox(1)+1,-size(im,2)+bbox(3)]));
    deltaY = ceil(max([0,-bbox(2)+1,-size(im,1)+bbox(4)]));
    im2 = uint8(zeros(size(im,1)+2*deltaY,size(im,2)+2*deltaX,3));
    im2(deltaY+[1:size(im,1)],deltaX+[1:size(im,2)],:)=im;
    im = im2(deltaY+[bbox(2):bbox(4)],deltaX+[bbox(1):bbox(3)],:);
    img=im2double(im);
    img=rgb2gray(img);
    
    subplot(H,W,1);
    %imagesc(im);axis equal;
    imshow(im);axis equal;
    hold on;
    
    for g = 1:length(key.groups)
        heatIm = -Inf([hDims(2) hDims(1)]);
        for kpInd = find(key.groupInds == g)
            kpInds = (kpInd-1)*hDims(1)*hDims(2) + [1:hDims(1)*hDims(2)];
            hIm = feat(i,kpInds);
            hIm = reshape(hIm,[hDims(2) hDims(1)]);
            heatIm = max(heatIm,hIm);
        end
        heatIm = imresize(heatIm,[size(im,1),size(im,2)]);
        
        im1=zeros(size(img));
        im1(:,:,1)=0.2*img;
        im1(:,:,2)=0.2*img+0.8*heatIm;
        im1(:,:,3)=0.8*heatIm+0.2*img;
        im1 = max(im1,0);im1 = min(im1,1);
        subplot(H,W,g+1);
        %imagesc(im1);axis equal;
        imshow(im1);axis equal;
        title(key.groups{g});
        hold on;
    end
    saveas(gcf, fullfile(visDir,num2str(j)), 'jpg');
    pause(0.01);
    close all;

end
htmlGen(visDir);

end

function [] = htmlGen(visDir)

globals;
txtFile = fullfile(visDir,'index.html');
fid = fopen(txtFile,'w+');
fprintf(fid,'<!DOCTYPE html>\n');
fprintf(fid,'<html>\n');
fprintf(fid,'<body>\n');
fnames = getFileNamesFromDirectory(visDir);
J = length(fnames);
for j=1:J
    fprintf(fid,'<img src=%d%s>\n   ',j,fnames{1}(end-3:end));
end

fprintf(fid,'</body>\n');
fprintf(fid,'</html>\n');

end

