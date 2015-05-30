function [trainLabels,testLabels,trainFeats,testFeats] = generateEvalSetData(data)
%GENERATEEVALSETLABELS Summary of this function goes here
%   Detailed explanation goes here

globals;
%params = getParams();
encoding = params.angleEncoding;

subset = 1:size(data.train.feat,2);

trainLabels = encodePose(data.train.eulers,encoding);
testLabels = encodePose(data.test.eulers,encoding);

trainFeats = (double(data.train.feat(:,subset)));
testFeats = (double(data.test.feat(:,subset)));

trainFeats = sparse(trainFeats);
testFeats = sparse(testFeats);

end