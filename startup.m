global basedir
global cachedir
global PASCAL3Ddir

global rcnnVpsPascalDataDir
global rcnnKpsPascalDataDir
global rcnnVpsImagenetDataDir

global rotationPascalDataDir
global rotationImagenetDataDir
global rotationJointDataDir
global kpsPascalDataDir

global finetuneVpsDir
global finetuneKpsDir

global params
global pascalImagesDir
global pascalDir
global annotationDir
global segkpAnnotationDir
global imagenetImagesDir
global websiteDir
global snapshotsDir
global prototxtDir
global rcnnDetectionsFile

%%
basedir = pwd();
cachedir  = fullfile(basedir,'cachedir'); % directory where all the intermediate computations and data will be saved

PASCAL3Ddir = fullfile(basedir,'data','PASCAL3D');
pascalDir = fullfile(basedir,'data','VOCdevkit');
pascalImagesDir = fullfile(basedir,'data','VOCdevkit','VOC2012','JPEGImages');
imagenetImagesDir = fullfile(basedir,'data','imagenet','images');
annotationDir = fullfile(basedir,'data','pascalAnnotations','imgAnnotations');
segkpAnnotationDir = fullfile(basedir,'data','pascalAnnotations','segkps');
rcnnDetectionsFile = fullfile(basedir,'data','VOC2012_val_det.mat');

params = getParams;

rcnnVpsPascalDataDir = fullfile(cachedir,'rcnnVpsPascalData');
rcnnVpsImagenetDataDir = fullfile(cachedir,'rcnnVpsImagenetData');
rcnnKpsPascalDataDir = fullfile(cachedir,'rcnnKpsPascalData');

kpsPascalDataDir = fullfile(cachedir,'kpsDataPascal');
rotationPascalDataDir = fullfile(cachedir,'rotationDataPascal');
rotationImagenetDataDir = fullfile(cachedir,'rotationDataImagenet');
rotationJointDataDir = fullfile(cachedir,'rotationDataJoint');

finetuneVpsDir = fullfile(cachedir,'rcnnFinetuneVps');
finetuneKpsDir = fullfile(cachedir,'rcnnFinetuneKps');

websiteDir = fullfile(cachedir,'visualization'); %directory where visualizations used for the main paper will be saved
prototxtDir = fullfile(basedir,'prototxts');
snapshotsDir = fullfile(cachedir,'snapshots'); %directory where caffemodels are saved - you'll have to set this up

%%
folders = {'analysisVp','analysisKp','detectionPose','pose','encoding','predict','evaluate','utils','visualization','evaluation','learning','preprocess','rcnnKp','rcnnVp','cnnFeatures'};
for i=1:length(folders)
    addpath(genpath(folders{i}));
end

clear i;
clear folders;


mkdirOptional(cachedir);
if exist(fullfile(cachedir,'pascalTrainValIds.mat'))
    load(fullfile(cachedir,'pascalTrainValIds'))
else
    fIdTrain = fopen(fullfile(pascalDir,'VOC2012','ImageSets','Main','train.txt'));
    trainIds = textscan(fIdTrain,'%s');
    trainIds = trainIds{1};
    fIdVal = fopen(fullfile(pascalDir,'VOC2012','ImageSets','Main','val.txt'));
    valIds = textscan(fIdVal,'%s');
    valIds = valIds{1};
    save(fullfile(cachedir,'pascalTrainValIds.mat'),'trainIds','valIds');
end
    
if ~exist(fullfile(cachedir,'imagenetTrainIds.mat'))
    fnamesTrain = generateImagenetTrainNames();
    save(fullfile(cachedir,'imagenetTrainIds.mat'),'fnamesTrain');
end

mkdirOptional(rotationJointDataDir);
mkdirOptional(rotationImagenetDataDir);
mkdirOptional(rotationPascalDataDir);
mkdirOptional(kpsPascalDataDir);

mkdirOptional(rcnnVpsImagenetDataDir);
mkdirOptional(rcnnVpsPascalDataDir);
mkdirOptional(rcnnKpsPascalDataDir);

mkdirOptional(finetuneVpsDir);
mkdirOptional(finetuneKpsDir);

mkdirOptional(visualizationDir);

if exist('external/caffe/matlab/caffe')
  addpath('external/caffe/matlab/caffe');
else
  warning('Please install Caffe in ./external/caffe');
end
