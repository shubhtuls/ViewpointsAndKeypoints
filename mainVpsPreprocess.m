function [] = mainVpsPreprocess()
%MAINVPSPREPROCESS Summary of this function goes here
%   Detailed explanation goes here

globals;

%% Read data from pascal3d dataset
% for c = params.classInds
%     class = pascalIndexClass(c);
%     disp(['Reading data for : ' class]);
%     readVpsData(class);
% end

%% Create imagewise datastructures for cnn window file generation
vpsPascalDataCollect()
vpsImagenetDataCollect()

%% Create cnn training file(s)
rcnnBinnedJointTrainValTestCreate('');
rcnnMultibinnedJointTrainValTestCreate([24 16 8 4]);

%% Train the CNN !
% (not from matlab, unfortunately)
% update the window file paths in trainTest.prototxt to refer to the
% Train/Val files created by above function

% ./build/tools/caffe.bin train -solver
% /work5/shubhtuls/prototxts/codeRelease/vpsKps/vggJointVps/solver.prototxt
% -weights PATH_TO_VGG_CAFFEMODEL

%% Compute features
% generatePoseFeatures('vggJointVps',vggJointVps',224,params.classInds,1)

end

