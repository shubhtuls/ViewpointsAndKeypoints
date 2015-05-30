function [perf ] = smallVsLarge()
%SMALLVSLARGE Summary of this function goes here
%   Detailed explanation goes here

globals;
classes = {'aeroplane','bicycle','bird','boat','bottle','bus','car','cat','chair','cow','diningtable','dog','horse','motorbike','person','plant','sheep','sofa','train','tvmonitor'};
%classInds = [1 2];
classInds = [1 2 4 6 7 9 14 18 19 20];
perf = [];

for c=classInds
    params.trainValSets = {''}; %Empty String implies Gt
    params.testSets = {''}; %CandidatesPool
    params.nHypotheses = 1;
    params.features = 'vggJointVpsMirror';

    class = classes{c};
    [~,~,testErrs,testData] = regressToPose(class);
    nonOccInds = ~(testData.occluded | testData.truncated);
    testErrsNonOcc = testErrs(nonOccInds);
    Hs = testData.bboxes(nonOccInds,4)-testData.bboxes(nonOccInds,2);
    Ws = testData.bboxes(nonOccInds,3)-testData.bboxes(nonOccInds,1);
    Ars = Hs.*Ws;
    [~,Idx] = sort(Ars,'descend');
    disp(class);
    N = round(size(testErrsNonOcc,1)/3);
    smallErrs = testErrsNonOcc(Idx((end-N):end));
    largeErrs = testErrsNonOcc(Idx(1:N));
    
    params.nHypotheses = 2;
    [~,~,testErrs2] = regressToPose(class);
    
    perf = vertcat(perf,[median(testErrsNonOcc) median(smallErrs) median(largeErrs) median(testErrs2(nonOccInds)) median(testErrs(~nonOccInds))]);
end

perf = [perf;mean(perf,1)];

end