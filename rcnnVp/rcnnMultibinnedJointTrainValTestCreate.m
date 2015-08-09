function [] = rcnnMultibinnedJointTrainValTestCreate(binSizes)
%RCNNTRAINVALTESTCREATE Summary of this function goes here
%   Detailed explanation goes here

%% WINDOW FILE FORMAT
% repeated :
%   img_path(abs)
%   reg2sp file path
%   sp file path
%   num_pose_param
%   channels
%   height
%   width
%   num_windows
%   classIndex overlap x1 y1 x2 y2 regionIndex poseParam0 .. poseParam(numPoseParam)

%% Initialization
globals;
params = getParams();

%% Train/Val/Test filenames generate

intervals = {};
for b=binSizes
    intervals{end+1} = [0 (360/(b*2)):(360/b):360-(360/(b*2))];
end

load(fullfile(cachedir,'imagenetTrainIds.mat'));
load(fullfile(cachedir,'pascalTrainValIds.mat'));
finetuneDir = fullfile(finetuneVpsDir,'multiBinnedJoint');
mkdirOptional(finetuneDir);
fnamesSets = {};
fnamesSets{1} = unique(vertcat(trainIds,fnamesTrain)); %train on pascal+imagenet
fnamesSets{2} = valIds; %val images are from pascal train

%% Generating test files
sets = {'Train','Val'};

for s=1:length(sets)
    set = sets{s};
    disp(['Generating data for ' set]);
    txtFile = fullfile(finetuneDir,[set '.txt']);
    fid = fopen(txtFile,'w+');
    fnames = fnamesSets{s};
    count = 0;
    for j=1:length(fnames)
    %for j=1:1
        id = fnames{j};
        if(exist(fullfile(rcnnVpsPascalDataDir,[id '.mat']),'file'))
            candFile = fullfile(rcnnVpsPascalDataDir,[id '.mat']);
            dataset = 'pascal';
        elseif (exist(fullfile(rcnnVpsImagenetDataDir,[id '.mat']),'file'))
            candFile = fullfile(rcnnVpsImagenetDataDir,[id '.mat']);
            dataset = 'imagenet';
        else
            continue;
        end
        cands = load(candFile);
        if(isempty(cands.overlap))
            continue;
        end
        numcands = round(sum(cands.overlap >= params.candidateThresh));
        if(numcands ==0)
            continue;
        end
        count=count+1;
        imsize = cands.imSize;
        [imgDir,imgExt] = getDatasetImgDir(dataset);
        imgFile = fullfile(imgDir,[id imgExt]);

        fprintf(fid,'# %d\n%s\n%d\n%d\n%d\n%d\n',count-1,imgFile,3,imsize(1),imsize(2),numcands);
        
        for n=1:size(cands.overlap,1)
             azimuth = cands.euler(n,3);
            fprintf(fid,'%d %f %d %d %d %d',cands.classIndex(n),cands.overlap(n),...
                cands.bbox(n,1),cands.bbox(n,2),cands.bbox(n,3),cands.bbox(n,4));
            for b=1:numel(binSizes)
                ind = findInterval(azimuth*180/pi,intervals{b});
                mirrorInd = findInterval(360-azimuth*180/pi,intervals{b});
                fprintf(fid, ' %d %d', ind-1,mirrorInd-1);
            end
            if(numel(binSizes < 6))
                for b=1:(6-numel(binSizes))
                    fprintf(fid, ' %d %d', 0,0);
                end
            end
            fprintf(fid,'\n');
        end
    end
end

end

function ind = findInterval(azimuth, a)
for i = 1:numel(a)
    if azimuth < a(i)
        break;
    end
end
ind = i - 1;
if azimuth > a(end)
    ind = 1;
end
end
