function [] = pascalKpsMulticlassTrainValCreate()
%RCNNTRAINVALTESTCREATE Summary of this function goes here
%   Detailed explanation goes here

%% Initialization
globals;

%% Train/Val filenames generate
classInds = params.classInds;
kpIndexStart = zeros(20,1);
kpNums = zeros(20,1);
totalKps = 0;
for c = classInds
    var = load(fullfile(cachedir,'partNames', pascalIndexClass(c)));
    kpNums(c) = length(var.partNames);
    kpIndexStart(c) = totalKps;totalKps = totalKps + length(var.partNames);
end

flipKps = zeros(1,totalKps);totalCt = 0;
for c = classInds
    var = load(fullfile(cachedir,'partNames', pascalIndexClass(c)));
    flipKps(totalCt+[1:length(var.partNames)]) = totalCt + findKpsPerm(var.partNames);
    totalCt = totalCt + length(var.partNames);
end

load(fullfile(cachedir,'pascalTrainValIds.mat'));
fnamesSets = {};
fnamesSets{1} = trainIds;
fnamesSets{2} = valIds;

dims = params.heatMapDims;
probThresh = params.heatMapThresh;

%% Generating test files
sets = {'Train','Val'}; %dont generate test data

for s=1:length(sets)
    set = sets{s};
    if(~params.excludeOccluded)
        set = [set 'Occluded'];
    end
    disp(['Generating data for ' set]);
    txtFile = fullfile(finetuneKpsDir,[set num2str(dims(1)) '.txt']);
    fid = fopen(txtFile,'w+');
    fnames = fnamesSets{s};
    count = 0;
    for j=1:length(fnames)
    %for j=1:1
        id = fnames{j};
        if(~exist(fullfile(rcnnKpsPascalDataDir,[id '.mat']),'file'))
            continue;
        end
        cands = load(fullfile(rcnnKpsPascalDataDir,id));
        goodInds = ismember(cands.boxClass,classInds);
        if(params.excludeOccluded)
            goodInds = goodInds & ~cands.occluded & ~cands.truncated & ~cands.difficult ;
        else
             goodInds = goodInds & ~cands.difficult;
        end
        
        cands.boxClass = cands.boxClass(goodInds);
        cands.kps = cands.kps(goodInds);
        cands.bbox = cands.bbox(goodInds,:);
        cands.overlap = cands.overlap(goodInds,:);
        
        numposcands = size(cands.bbox,1);
        numcands = numposcands;
        if(numcands ==0)
            continue;
        end
        count=count+1;
        imgFile = fullfile(pascalImagesDir, [id '.jpg']);

        imsize = cands.imsize;
        fprintf(fid,'# %d\n%s\n%d\n%d\n%d\n%d\n%d\n',count-1,imgFile,3,imsize(1),imsize(2),totalKps*dims(1)*dims(2),numcands);
        for n=1:numposcands
            [kpNum,kpCoords] = normalizeKps(cands.kps{n},cands.bbox(n,:),dims);
            [kpNum,kpCoords,kpVal] = gaussianKps(kpNum,kpCoords,dims,probThresh);
            kpNum = kpNum + kpIndexStart(cands.boxClass(n));
            fprintf(fid,'%d %.3f %d %d %d %d %d %d %d',cands.boxClass(n),cands.overlap(n),cands.bbox(n,1),cands.bbox(n,2),cands.bbox(n,3),cands.bbox(n,4),numel(kpNum),kpIndexStart(cands.boxClass(n))*dims(1)*dims(2),kpIndexStart(cands.boxClass(n))*dims(1)*dims(2)+kpNums(cands.boxClass(n))*dims(1)*dims(2)-1);
            for k=1:numel(kpNum)
                %print array index as 1d location
                kpInd = (kpNum(k)-1)*dims(1)*dims(2) + (kpCoords(k,2)-1)*dims(1) + (kpCoords(k,1)-1);
                flipKpInd = (flipKps(kpNum(k))-1)*dims(1)*dims(2)+ (kpCoords(k,2)-1)*dims(1)+ (dims(1) - kpCoords(k,1));
                fprintf(fid,' %d %d %.2f',kpInd, flipKpInd, kpVal(k));
                %print array index as [kpNum,x,y]
                %fprintf(fid,' %d %d %d',kpNum(k),kpCoords(k,1),kpCoords(k,2));
            end
            %if(numel(kpNum)==0)
            %    disp('oops');
            %end
            fprintf(fid,'\n');           
         end
    end
    disp(count);
end

end