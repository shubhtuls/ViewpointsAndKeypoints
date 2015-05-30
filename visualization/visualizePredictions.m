function [] = visualizePredictions(cls,prediction,data,encoding,testErrors,ordering)
%visualizePredictions(cls,prediction,data,encoding,testErrors,ordering)
%   For each instance in data, use PASCAL3D helpers to visualize prediction
% allowed orderings are (default is random is no argument is given) -
% 'image' : shows imagewise (useful when you have multiple candidates)
% 'ascend/descend' : ordered according to scores

globals;
if(~strcmp(cls,'all'))
    CADPath = fullfile(PASCAL3Ddir,'CAD',cls);
    cad = load(CADPath);
    cad = cad.(cls);
end
eulersPred = decodePose(prediction,encoding);
if (nargin < 6)
    %ids = [1:length(data.voc_ids)];
    ids = randperm(length(data.voc_ids));
elseif (strcmp(ordering,'image'))
    voc_ids = data.voc_ids;
    for i=1:length(voc_ids)
        voc_ids{i}=[voc_ids{i} int2str(data.rec_ids(i))];
    end
    [~,ids] = sort(voc_ids);
else
    [~,ids] = sort(testErrors,ordering);
end

for j=1:length(data.voc_ids)
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

    subplot(2,1,1);
    im = imread(fullfile(PASCAL_DIR,[data.voc_ids{i} '.jpg']));

    imagesc(color_seg(double(data.masks{i}),im));hold on;

    vertex = cad(record.objects(objectInd).cad_index).vertices;
    face = cad(record.objects(objectInd).cad_index).faces;
    [x2d,Z] = project3d(vertex, record.objects(objectInd),face);
%     %patch('vertices', [x2d Z], 'faces', face, ...
%     %    'FaceColor', 'blue', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    axis equal;


    subplot(2,1,2);
    trisurf(face,x2d(:,1),-x2d(:,2),-Z);axis equal; %empirically found this view and plot to work best
    view(0,90);
    title(num2str(testErrors(i)));

    pause();close all;
%disp('blah')
end

end
