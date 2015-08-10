function [] = mainVpsPreprocess()
%MAINVPSPREPROCESS Summary of this function goes here
%   Detailed explanation goes here

globals;

%% Read data from pascal3d dataset
for c = params.classInds
    class = pascalIndexClass(c);
    disp(['Reading data for : ' class]);
    readVpsData(class);
end

%% Create imagewise datastructures for cnn window file generation
vpsPascalDataCollect();
vpsImagenetDataCollect();

%% Create cnn training file(s)
rcnnBinnedJointTrainValTestCreate(''); %generates window file for network that estimates all three euler angles
rcnnMultibinnedJointTrainValTestCreate([24 16 8 4]); % generates window file for network that estimates azimuth in various bins as desired by pascal3D+ evaluation

%% Train the CNNs !
% (not from matlab, unfortunately)
% update the window file paths in the data layers of 
% PATH_TO_PROTOTXT_DIR/vggJointVps/trainTest.prototxt and PATH_TO_PROTOTXT_DIR/vggAzimuthVps/trainTest.prototxt
% to refer to the Train/Val files created by above functions.

% we train two networks here - one for predicting all the euler angles, other for various bin sizes of azimuth as required by AVP evaluation

% the shell scripts look as follows
% ./build/tools/caffe.bin train -solver PATH_TO_PROTOTXT_DIR/vggJointVps/solver.prototxt -weights PATH_TO_PRETRAINED_VGG_CAFFEMODEL
% ./build/tools/caffe.bin train -solver PATH_TO_PROTOTXT_DIR/vggAzimuthVps/solver.prototxt -weights PATH_TO_PRETRAINED_VGG_CAFFEMODEL
% after training the models, save the final snapshot in SNAPSHOT_DIR/finalSnapshots/[vggJointVps,vggAzimuthVps].caffemodel/

%% Compute features
generatePoseFeatures('vggJointVps','vggJointVps',224,params.classInds,1); % needed for evaluation

%% Compute features for detections - takes a while, uncomment if not needed
generateDetectionPoseFeatures(params.classInds,'vggJointVps','vggJointVps',224,1); % needed for ARP evaluation
generateDetectionPoseFeatures(params.classInds,'vggJointAzimuth','vggJointAzimuth',224,1); % needed for AVP evaluation
    
end

