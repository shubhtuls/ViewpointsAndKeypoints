function [] = visualizeKpMaps(dataStruct,kps,partNames,sc)
%VISUALIZEKPMAPS Summary of this function goes here
%   Detailed explanation goes here

close all;
globals;
imagesDir = PASCAL_DIR;
if(nargin<4)
    sc = 0;
end

bbox = dataStruct.bbox;
class = dataStruct.class;

x  = kps(1,:) - bbox(1);
y  = kps(2,:) - bbox(2);

maps = dataStruct.kpFeat;
[H,W,Kp] = size(maps);
plotH = 2;plotW = ceil((Kp+2)/plotH);
neighborMaps = zeros(H,W,Kp);
if(~isfield('neighborFeat',dataStruct))
    neighborMaps = dataStruct.neighborFeat;
end

%% Reading Image
im = imread(fullfile(imagesDir,[dataStruct.voc_image_id '.jpg']));
bbox = round(dataStruct.bbox);
deltaX = ceil(max([0,-bbox(1)+1,-size(im,2)+bbox(3)]));
deltaY = ceil(max([0,-bbox(2)+1,-size(im,1)+bbox(4)]));
im2 = uint8(zeros(size(im,1)+2*deltaY,size(im,2)+2*deltaX,3));
im2(deltaY+[1:size(im,1)],deltaX+[1:size(im,2)],:)=im;
im = im2(deltaY+[bbox(2):bbox(4)],deltaX+[bbox(1):bbox(3)],:);
img=im2double(im);
img=rgb2gray(img);

subplot(plotH,plotW,1);
imshow(im);axis equal;
title(num2str(sc));
hold on;

%% PASCAL3d

pascal3Dfile = fullfile(PASCAL3Ddir,'Annotations',[class '_pascal'],[dataStruct.voc_image_id '.mat']); 
record = load(pascal3Dfile);record = record.record;
bbox = dataStruct.bbox;
eulersPred = dataStruct.eulers;

objectInd = dataStruct.objectInd;

viewpoint = record.objects(objectInd).viewpoint;
viewpoint.azimuth = eulersPred(3);
viewpoint.elevation = eulersPred(2);
viewpoint.theta = eulersPred(1);
record.objects(objectInd).viewpoint = viewpoint;

CADPath = fullfile(PASCAL3Ddir,'CAD',class);
cad = load(CADPath);
cad = cad.(class);

subplot(plotH,plotW,2);

vertex = cad(record.objects(objectInd).cad_index).vertices;
face = cad(record.objects(objectInd).cad_index).faces;
[x2d,Z] = project3d(vertex, record.objects(objectInd),face);
%     %patch('vertices', [x2d Z], 'faces', face, ...
%     %    'FaceColor', 'blue', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
axis equal;

trisurf(face,x2d(:,1),-x2d(:,2),-Z);axis equal; %empirically found this view and plot to work best
view(0,90);

%% Showing map images
for kp = 1:Kp
    heatIm = maps(:,:,kp);
    neighborIm = imresize(neighborMaps(:,:,kp),[size(im,1),size(im,2)]);
    
    %heatIm = normalizeHeatIm(heatIm,size(im,2)/size(im,1));
    maps(:,:,kp) = heatIm;
    heatIm = imresize(heatIm,[size(im,1),size(im,2)]);

    im1=zeros(size(img));
    im1(:,:,1)=0.2*img+0.8*heatIm.*neighborIm;
    im1(:,:,2)=0.2*img+0.8*heatIm.*neighborIm;
    im1(:,:,3)=0.2*img;
    im1 = max(im1,0);im1 = min(im1,1);
    subplot(plotH,plotW,kp+2);
    %imagesc(im1);axis equal;
    imshow(im1);axis equal;
    hold on;
    plot(x(kp),y(kp),'r.');hold on;
    xKp = round(x(kp));
    yKp = round(y(kp));
    scKp = 0;

    if(xKp>0 && yKp>0 && xKp<=size(im,2) && yKp<=size(im,1))
        scKp = heatIm(yKp,xKp);
    end

    title([partNames{kp} ' : ' num2str(scKp)]);
end

pause();
close all;

end

