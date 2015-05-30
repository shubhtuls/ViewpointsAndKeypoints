%class = 'bicycle';
%type = 'Person'/ 'Rigid';
%% Overfeat
% 
% suffix = 'Overfeat';
% %overfeat features have a heatmap double the size
% disp('Loading conv6Overfeat')
% load(['/home/shubhtuls/Work/keypointPrediction/cache/rcnnPreds/' class 'conv6' suffix '.mat'])
% feat = flipMapXY(feat,[12 12]);
% feat6Ov = resizeHeatMap(feat,[12 12]);
% featConv6Ov = 1./(1+exp(-feat6Ov));
% 
% disp('Loading conv9Overfeat')
% load(['/home/shubhtuls/Work/keypointPrediction/cache/rcnnPreds/' class 'conv9' suffix '.mat'])
% feat = flipMapXY(feat,[18 18]);
% feat9Ov = resizeHeatMap(feat,[18 18]);
% featConv9Ov = 1./(1+exp(-feat9Ov));
% 
% disp('Loading conv18Overfeat')
% load(['/home/shubhtuls/Work/keypointPrediction/cache/rcnnPreds/' class 'conv18' suffix '.mat'])
% feat18Ov = flipMapXY(feat,[36 36]);
% %feat18Ov = resizeHeatMap(feat,[36 36]);
% featConv18Ov = 1./(1+exp(-feat18Ov));

%% Basic

suffix = '';
%suffix = 'StackAspect';

% disp('Loading conv3')
% load(['/home/shubhtuls/Work/keypointPrediction/cache/rcnnPreds' type '/' class 'conv3' suffix '.mat'])
% feat = flipMapXY(feat,[3 3]);
% feat3 = resizeHeatMap(feat,[3 3]);
% featConv3 = 1./(1+exp(-feat3));

disp('Loading conv6')
load(['/home/shubhtuls/Work/keypointPrediction/cache/rcnnPreds' type '/' class 'conv6' suffix '.mat'])
feat = flipMapXY(feat,[6 6]);
feat6 = resizeHeatMap(feat,[6 6]);
featConv6 = 1./(1+exp(-feat6));

% disp('Loading conv9')
% load(['/home/shubhtuls/Work/keypointPrediction/cache/rcnnPreds' type '/' class 'conv9' suffix '.mat'])
% feat = flipMapXY(feat,[9 9]);
% feat9 = resizeHeatMap(feat,[9 9]);
% featConv9 = 1./(1+exp(-feat9));

%suffix = 'ExtendedOverfeat';
disp('Loading conv12')
load(['/home/shubhtuls/Work/keypointPrediction/cache/rcnnPreds' type '/' class 'conv12' suffix '.mat'])
feat = flipMapXY(feat,[12 12]);
feat12 = resizeHeatMap(feat,[12 12]);
featConv12 = 1./(1+exp(-feat12));

% disp('Loading conv18')
% load(['/home/shubhtuls/Work/keypointPrediction/cache/rcnnPreds' type '/' class 'conv18' suffix '.mat'])
% feat = flipMapXY(feat,[18 18]);
% feat18 = resizeHeatMap(feat,[18 18]);
% featConv18 = 1./(1+exp(-feat18));

%% FC features
% 
% suffix = 'aspect';
% %
% % suffix = 'Extended';
% disp('Loading fc6')
% load(['/home/shubhtuls/Work/keypointPrediction/cache/rcnnPreds' type '/' class 'fc6' suffix '.mat'])
% feat = flipMapXY(feat,[6 6]);
% featFc6 = resizeHeatMap(feat,[6 6]);
% 
% disp('Loading fc12')
% load(['/home/shubhtuls/Work/keypointPrediction/cache/rcnnPreds' type '/' class 'fc12' suffix '.mat'])
% feat = flipMapXY(feat,[12 12]);
% featFc12 = resizeHeatMap(feat,[12 12]);
