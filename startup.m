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
cachedir  = '/work5/shubhtuls/cachedir/codeRelease/vpsKps'; % directory where all the intermediate computations and data will be saved

PASCAL3Ddir = fullfile(cachedir,'data','PASCAL3D');
pascalDir = fullfile(cachedir,'data','VOCdevkit');
pascalImagesDir = fullfile(cachedir,'data','VOCdevkit','VOC2012','JPEGImages');
imagenetImagesDir = fullfile(cachedir,'data','imagenet','images');
annotationDir = fullfile(cachedir,'data','pascalAnnotations','imgAnnotations');
segkpAnnotationDir = fullfile(cachedir,'data','pascalAnnotations','segkps');
rcnnDetectionsFile = fullfile(cachedir,'VOC2012_val_det.mat');

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

websiteDir = '/work5/shubhtuls/website/visualization';
prototxtDir = '/work5/shubhtuls/prototxts/codeRelease/vpsKps/';
snapshotsDir = '/work5/shubhtuls/snapshots/codeRelease/vpsKps/';

%%
folders = {'analysisVp','analysisKp','detectionPose','pose','encoding','predict','evaluate','utils','visualization','evaluation','learning','preprocess','rcnnKp','rcnnVp','cnnFeatures','sfm'};
for i=1:length(folders)
    addpath(genpath(folders{i}));
end

clear i;
clear folders;
load(fullfile(cachedir,'pascalTrainValIds'))

mkdirOptional(cachedir);

mkdirOptional(rotationJointDataDir);
mkdirOptional(rotationImagenetDataDir);
mkdirOptional(rotationPascalDataDir);
mkdirOptional(kpsPascalDataDir);

mkdirOptional(rcnnVpsImagenetDataDir);
mkdirOptional(rcnnVpsPascalDataDir);
mkdirOptional(rcnnKpsPascalDataDir);

mkdirOptional(finetuneVpsDir);
mkdirOptional(finetuneKpsDir);

if exist('external/caffe/matlab/caffe')
  addpath('external/caffe/matlab/caffe');
else
  warning('Please install Caffe in ./external/caffe');
end
