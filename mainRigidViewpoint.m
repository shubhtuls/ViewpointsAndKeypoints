%% Define Classes
classes = {'aeroplane','bicycle','bird','boat','bottle','bus','car','cat','chair','cow','diningtable','dog','horse','motorbike','person','plant','sheep','sofa','train','tvmonitor'};
classInds = [1 2 4 5 6 7 9 11 14 18 19 20];
numClasses = size(classInds,2);
params.nHypotheses = 1;

%% Iterate over pose predictions
errors = zeros(numClasses,1);
medErrors = zeros(numClasses,1);

for c = 1:numClasses
    class = classes{classInds(c)};
    disp(class);
    [~,~,testErrs,testData] = regressToPose(class);
    nonOccInds = ~(testData.occluded | testData.truncated);
    testErrsNonOcc = testErrs(nonOccInds);
    
    medErr = median(testErrsNonOcc);
    err = sum(testErrsNonOcc<=30)/numel(testErrsNonOcc);
    
    errors(c,:) = err;medErrors(c,:) = medErr;
end

prettyPrintResults(errors,medErrors);