function [] = mainKpsPredict()

%% create dataStructs for test
for c = params.classInds
    class = pascalIndexClass(c);
    readKpsData(class);
end
    
%% compute predictions for objects with known ground-truth box
extractRigidKeypointFeatures(params.classInds,192,'vggConv6Kps','vggConv6Kps',15);
extractRigidKeypointFeatures(params.classInds,384,'vggConv12Kps','vggConv12Kps',15);
generateKeypointPoseFeatures('vggJointVps','vggJointVps',224,params.classInds,1); % needed for posePrior

%% compute predictions for R-CNN detections - we assume pose for detections is precomputed by running the commented line below
% generateDetectionPoseFeatures(params.classInds,'vggJointVps','vggJointVps',224,1); % (uncomment this if not already computed for viewpoint prediction  
generateDetectionKpsFeatures(params.classInds,'vggConv6Kps','vggConv6Kps',192,15);
generateDetectionKpsFeatures(params.classInds,'vggConv12Kps','vggConv12Kps',384,15);
    
end