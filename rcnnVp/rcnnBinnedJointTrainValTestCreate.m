function [] = rcnnBinnedJointTrainValTestCreate(suffix)
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

load(fullfile(cachedir,'imagenetTrainIds.mat'));
load(fullfile(cachedir,'pascalTrainValIds.mat'));
finetuneDir = fullfile(finetuneVpsDir,'binnedJoint');
mkdirOptional(finetuneDir);
fnamesSets = {};
fnamesSets{1} = unique(vertcat(trainIds,fnamesTrain)); %train on pascal+imagenet
fnamesSets{2} = valIds; %val images are from pascal train

%% Generating test files
sets = {'Train','Val'};

for s=1:length(sets)
    set = sets{s};
    disp(['Generating data for ' set]);
    txtFile = fullfile(finetuneDir,[set suffix '.txt']);
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
        %%%%%%%%%%%% Insert anakin paths here

        %fprintf(fid,'# %d\n%s\n%s\n%s\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n',count-1,imgFile,reg2spFile,spFile,3,10,10,20,3,imsize(1),imsize(2),numcands);
        fprintf(fid,'# %d\n%s\n%d\n%d\n%d\n%d\n',count-1,imgFile,3,imsize(1),imsize(2),numcands);
        %if(max(cands.euler(:,1))>=pi/2 || max(cands.euler(:,2)>=pi/2 ))
        %    disp('Oops');
        %end
        for n=1:size(cands.overlap,1)
            
            fprintf(fid,'%d %f %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\n',...
                cands.classIndex(n),cands.overlap(n),...
                cands.bbox(n,1),cands.bbox(n,2),cands.bbox(n,3),cands.bbox(n,4),...
                ceil(cands.euler(n,1)*10.5/pi+9.5),ceil(-cands.euler(n,1)*10.5/pi+9.5),...
                ceil(cands.euler(n,2)*10.5/pi+9.5),ceil(cands.euler(n,2)*10.5/pi+9.5),...
                floor(cands.euler(n,3)*10.5/pi),20-floor(cands.euler(n,3)*10.5/pi),...
                ceil(cands.euler(n,1)*3.5/pi+2.5),ceil(-cands.euler(n,1)*3.5/pi+2.5),...
                ceil(cands.euler(n,2)*3.5/pi+2.5),ceil(cands.euler(n,2)*3.5/pi+2.5),...
                floor(cands.euler(n,3)*3.5/pi),6-floor(cands.euler(n,3)*3.5/pi));
        end
    end
end

end