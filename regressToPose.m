function [testErrors,testMedErrors,testErrs,testData,testPreds,testLabels] = regressToPose(class)
%[testErrors,testMedErrors] = regressToPose(class)
%   uses the training/val/test sets specified in parameters and
% regresses to pose and returns error

%% Initializations
%disp(class);
globals;
%params = getParams();
encoding = params.angleEncoding;
createEvalSets(class);

%% Loading Data

data = load(fullfile(cachedir,'evalSets',class));
[trainLabels,testLabels,trainFeats,testFeats] = generateEvalSetData(data);

%% TESTING
switch params.optMethod        
    case 'bin'
        alphaOpt = 0;
        nHypotheses = params.nHypotheses;
        [testPreds] = poseHypotheses(testFeats,nHypotheses,alphaOpt);
        [trainPreds] = poseHypotheses(trainFeats,nHypotheses,alphaOpt);        
end

%keyboard;
testErrs = evaluatePredictionError(testPreds,testLabels,encoding);
trainErrs = evaluatePredictionError(trainPreds,trainLabels,encoding);
%[median(trainErrs) median(testErrs)]

%diff = testPreds - testLabels;
%mean(sum(diff.*diff,2));
testErrors = [];testMedErrors=[];

testErrors(1) = mean(testErrors);
testMedErrors(1) = median(testErrors);

testErrors(1) = sum(testErrs<=30)/numel(testErrs);
testMedErrors(1) = median(testErrs);
testData = data.test;
[errSort,IDX] = sort(testErrs,'ascend');

end
