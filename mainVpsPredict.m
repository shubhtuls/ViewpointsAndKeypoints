function [] = mainVpsPredict()
%MAINVPSPREPROCESS Summary of this function goes here
%   Detailed explanation goes here

globals;


%% Compute features
generatePoseFeatures('vggJointVps','vggJointVps',224,params.classInds,1); % needed for evaluation

%% Compute features for detections - takes a while, uncomment if not needed
generateDetectionPoseFeatures(params.classInds,'vggJointVps','vggJointVps',224,1); % needed for ARP evaluation
generateDetectionPoseFeatures(params.classInds,'vggJointAzimuth','vggJointAzimuth',224,1); % needed for AVP evaluation

end