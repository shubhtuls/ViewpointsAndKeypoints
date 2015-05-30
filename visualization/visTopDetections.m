function [] = visTopDetections(class)
%VISTOPDETECTIONS Summary of this function goes here
%   Detailed explanation goes here

globals;
proto = 'vggJointVps';suff = '';
dataStructsDir = fullfile(cachedir,['rcnnDetectionPredsVps'],[proto suff]);
load(fullfile(dataStructsDir,'allDets.mat'));
cInd = pascalClassIndex(class);
cands = dataStructs(cInd);

pascalValNamesFile = fullfile(cachedir,'voc_val_names.mat');
valNames = load(pascalValNamesFile);
valNames = valNames.val_names;
cands.voc_ids = cell(size(cands.boxes));

CADPath = fullfile(PASCAL3Ddir,'CAD',class);
cad = load(CADPath);
cad = cad.(class);
vertices = cad(1).vertices;
faces = cad(1).faces;

for i=1:length(valNames)
    cands.voc_ids{i} = valNames(i*ones(size(cands.boxes{i},1),1));
end

boxes = vertcat(cands.boxes{:});
scores = boxes(:,5);
[scores,perm] = sort(scores,'descend');

boxes = boxes(perm,1:4);
feat = vertcat(cands.feat{:});
feat = feat(perm,:);
ids = vertcat(cands.voc_ids{:});
ids = ids(perm);

preds = poseHypotheses(feat,1,0);
preds = preds{1};
eulersPred = decodePose(preds,params.angleEncoding);
rotX = diag([1 -1 -1]);

%for i=1:length(ids)
for i = 1:100
    disp( ids{i})
    im = imread([pascalImagesDir '/' ids{i} '.jpg']);
    subplot(1,2,1);
    showboxes(im,boxes(i,:));
    axis image;
    subplot(1,2,2);
    
    euler = eulersPred(i,:);
    R = angle2dcm(euler(1), euler(2)-pi/2, -euler(3),'ZXZ');
    R = rotX*R';
    verticesP = R*vertices';
    verticesP = verticesP';
    trisurf(faces,verticesP(:,1),verticesP(:,2),verticesP(:,3));axis equal;view(0,-90);
    title(num2str(scores(i)));    
    pause();close all;
end

end

