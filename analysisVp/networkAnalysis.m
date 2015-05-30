function [perf] = networkAnalysis()
%NETWORKANALYSIS Summary of this function goes here
%   Detailed explanation goes here

globals;
classes = {'aeroplane','bicycle','bird','boat','bottle','bus','car','cat','chair','cow','diningtable','dog','horse','motorbike','person','plant','sheep','sofa','train','tvmonitor'};
classInds = [1 2 4 6 7 9 14 18 19 20];

perf = [];

for c=classInds
    params.trainValSets = {''}; %Empty String implies Gt
    params.testSets = {''}; %CandidatesPool
    params.nHypotheses = 1;
    medianErr = [];
    
    class = classes{c};
    disp(class);
    
    params.features = 'fcSelectiveJoint';
    [~,medianErr(1)] = regressToPose(class);
    
    params.features = 'fcSelectiveAllJoint';
    [~,medianErr(2)] = regressToPose(class);
    
    params.features = 'fcSelectiveAll';
    [~,medianErr(3)] = regressToPose(class);
    
    params.trainValSets = {'Occluded'}; %Empty String implies Gt
    params.testSets = {'Occluded'}; %CandidatesPool

    params.features = 'fcSelectiveJoint';
    [~,medianErr(4)] = regressToPose(class);
    
    params.features = 'fcSelectiveAllJoint';
    [~,medianErr(5)] = regressToPose(class);
    
    params.features = 'fcSelectiveAll';
    [~,medianErr(6)] = regressToPose(class);
    
    perf = vertcat(perf,medianErr);
    
end

perf = [perf;mean(perf,1)];

end

