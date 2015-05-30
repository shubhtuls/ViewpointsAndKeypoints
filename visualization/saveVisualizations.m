function [] = saveVisualizations(cls,prediction,data,encoding,testErrors,ordering,subtype)
%SAVEVISUALIZATIONS Summary of this function goes here
%   Detailed explanation goes here

%   For each instance in data, use PASCAL3D helpers to visualize prediction
% allowed orderings are (default is random is no argument is given) -
% 'image' : shows imagewise (useful when you have multiple candidates)
% 'ascend/descend' : ordered according to scores
globals;

if(~exist('subtype','var'))
    subtype = zeros(length(data.voc_ids),1);
end

if(sum(subtype)==0)
    visDir = fullfile(websiteDir,'predictionVisualizationsOpt',cls);
else
    visDir = fullfile(websiteDir,'predictionVisualizationsSubtype',cls);
    load(fullfile(cachedir,'subtypeClusters'));
end

mkdir(visDir);
delete(fullfile(visDir,'*'));

if(~strcmp(cls,'all'))
    CADPath = fullfile(PASCAL3Ddir,'CAD',cls);
    cad = load(CADPath);
    cad = cad.(cls);
end

eulersPred = decodePose(prediction,encoding);
% if (nargin < 6)
%     ids = [1:length(data.voc_ids)];
%     %ids = randperm(length(data.voc_ids));
% else
if (strcmp(ordering,'image'))
    voc_ids = data.voc_ids;
    for i=1:length(voc_ids)
        voc_ids{i}=[voc_ids{i} int2str(data.rec_ids(i))];
    end
    [~,ids] = sort(voc_ids);
else
    [~,ids] = sort(testErrors,ordering);
end

fractions = [0 0.15 0.30 0.45 0.60 0.75 0.9];
nFractions = length(data.voc_ids)*fractions;

for j=1:length(data.voc_ids)
    %for j=1:5

    %if(min(abs(j-nFractions)) > 3)
    %   continue;
    %end
    i = ids(j);
    if(isfield(data,'classes'))
        cls = data.classes{i};
        CADPath = fullfile(PASCAL3Ddir,'CAD',cls);
        cad = load(CADPath);
        cad = cad.(cls);
    end
    pascal3Dfile = fullfile(PASCAL3Ddir,'Annotations',[cls '_pascal'],[data.voc_ids{i} '.mat']); 
    record = load(pascal3Dfile);record = record.record;
    bbox = data.bboxes(i,:);
    objectInd = data.objectInds(i);
    viewpoint = record.objects(objectInd).viewpoint;
    
    viewpoint.azimuth = eulersPred(i,3);
    viewpoint.elevation = eulersPred(i,2);
    viewpoint.theta = eulersPred(i,1);
    record.objects(objectInd).viewpoint = viewpoint;
    
    % cluster cadIndex
    %clusterInd = cadClusterIndex(record.objects(objectInd).cad_index,cls,subtypeClusters);
    %record.objects(objectInd).cad_index = clusterCadIndex(clusterInd,cls,subtypeClusters);
    
    if(subtype(i) ~= 0)
        recordSub = record;
        recordSub.objects(objectInd).cad_index = clusterCadIndex(subtype(i),cls,subtypeClusters);
        nPlots = 3;
    else
        nPlots = 2;
    end

    subplot(1,nPlots,1,'Position',[0.05,0.05,0.4,0.9]);
    %subplot('Position',[0.5,0.5,0.45,0.45]);
    im = imread(fullfile(PASCAL_DIR,[data.voc_ids{i} '.jpg']));
    imBox = im(bbox(2):bbox(4),bbox(1):bbox(3),:);
    
    %imagesc(color_seg(double(data.masks{i}),im));hold on;
    imagesc(imBox);hold on;
    imBoxFlip = imBox;
    for c=1:size(imBox,3)
        imBoxFlip(:,:,c) = fliplr(imBox(:,:,c));
    end
    %imagesc(imBoxFlip);hold on;
    axis image;axis off;

    subplot(1,nPlots,nPlots,'Position',[0.55,0.05,0.4,0.9]);
    %hold on;
    %subplot('Position',[0.5,0.5,0.45,0.45]);
    vertex = cad(record.objects(objectInd).cad_index).vertices;
    face = cad(record.objects(objectInd).cad_index).faces;
    [x2d,Z] = project3d(vertex, record.objects(objectInd),face);
    trisurf(face,x2d(:,1),-x2d(:,2),-Z,'EdgeAlpha',0.02,'SpecularStrength',0.5);axis equal;axis off;hold on; %empirically found this view and plot to work best
    view(0,90);
    
    if(subtype(i) ~= 0)
        subplot(1,nPlots,2);
        vertex = cad(recordSub.objects(objectInd).cad_index).vertices;
        face = cad(recordSub.objects(objectInd).cad_index).faces;
        [x2d,Z] = project3d(vertex, recordSub.objects(objectInd),face);
        trisurf(face,x2d(:,1),-x2d(:,2),-Z,'EdgeAlpha',0.1);axis equal;hold on; %empirically found this view and plot to work best
        view(0,90);
    end
    
    %title(num2str(testErrors(i)),'FontSize',10,'FontWeight','bold');
    set(gcf,'Color','w');
    
    %saveas(gcf, fullfile(visDir,num2str(j)), 'jpg');
    export_fig(fullfile(visDir,[num2str(j) '.png']),'-transparent');    
    %pause();
    %pause();
    close all;
%disp('blah')
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
    fprintf(fid,'<img src=%s>\n   ',fnames{j});
end

fprintf(fid,'</body>\n');
fprintf(fid,'</html>\n');

end
