function [] = rcnnKpsDataCollect()
%RCNNDATA Summary of this function goes here
%   Detailed explanation goes here

%% Initialize
globals;
rcnnDataDir = rcnnKpsPascalDataDir;

mkdir(rcnnDataDir);
delete(fullfile(rcnnDataDir,'*.mat'));

candidateThresh = params.candidateThresh;
annotationDir = annotationDir;

%% WINDOW FILE FORMAT
% repeated :
%   img_path(abs)
%   reg2sp file path
%   num_pose_param
%   channels
%   height
%   width
%   num_windows
%   classIndex overlap x1 y1 x2 y2 regionIndex poseParam0 .. poseParam(numPoseParam)

%% Iterate over classes
fnames = getFileNamesFromDirectory(annotationDir,'types',{'.mat'});
for i=1:length(fnames)
%for i=randperm(length(fnames))
    if(~mod(i,1000))
        disp(i)
    end

    gt = load(fullfile(annotationDir,fnames{i}));
    %cands = load(fullfile(candsDir,fnames{i}));
    cands = jitteredCands(gt);
    goodInds = true(size(cands.bbox,1),1);

    %% Subset of candidates with sufficient overlap
    if(~sum(goodInds))
        continue;
    end
    bbox = cands.bbox(goodInds,:);
    boxClass = gt.class(cands.boxRecId(goodInds));
    kps = gt.kps(cands.boxRecId(goodInds));
    truncated = gt.truncated(cands.boxRecId(goodInds));
    occluded = gt.occluded(cands.boxRecId(goodInds));
    difficult = gt.difficult(cands.boxRecId(goodInds));
    overlap = ones(size(difficult));
    
    %% Subset of candidates with non-empty keypoints
    goodInds = cellfun(@(x) numel(x),kps) > 0;
    if(~sum(goodInds))
        continue;
    end
    boxClass = boxClass(goodInds);
    bbox = bbox(goodInds,:);
    kps = kps(goodInds);
    overlap = overlap(goodInds);
    truncated = truncated(goodInds);
    occluded = occluded(goodInds);
    difficult = difficult(goodInds);
    savefunc(fullfile(rcnnDataDir,fnames{i}),gt.imsize,boxClass,bbox,kps,overlap,truncated,occluded,difficult);
    
end

end

function [] = savefunc(file,imsize,boxClass,bbox,kps,overlap,truncated,occluded,difficult)
    save(file,'imsize','boxClass','bbox','kps','overlap','truncated','occluded','difficult');
end

function cands = jitteredCands(gt)

N = size(gt.bbox,1);
bbox = [];
boxRecId = [];
for n = 1:N
    newBoxes = overlappingBoxes(gt.bbox(n,:),gt.imsize);
    recIds = n*ones(size(newBoxes,1),1);
    bbox = vertcat(bbox,newBoxes);
    boxRecId = vertcat(boxRecId,recIds);
end

cands = struct;
cands.bbox = bbox;
cands.boxRecId = boxRecId;

end