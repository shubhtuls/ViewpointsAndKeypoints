function [perf] = errorModes()
%ERRORMODES Summary of this function goes here
%   Detailed explanation goes here

globals;
classes = {'aeroplane','bicycle','bird','boat','bottle','bus','car','cat','chair','cow','diningtable','dog','horse','motorbike','person','plant','sheep','sofa','train','tvmonitor'};
classInds = [1 2 4 6 7 9 14 18 19 20];
%classInds = [2 4 6 7 9 14 18 19 20];
params.angleEncoding = 'euler';

accTheta = 30;

perf = [];
for c=classInds
    params.nHypotheses = 1;
    params.trainValSets = {''}; %Empty String implies Gt
    params.testSets = {''}; %CandidatesPool
    params.features = 'vggJointVpsMirror';
    class = classes{c};
    
    [~,~,~,testData,testPreds] = regressToPose(class);        
    nonOccInds = ~(testData.occluded | testData.truncated);
    
    testPredsAz = testPreds{1}(nonOccInds,:);
    testPredsAz(:,1:2) = 0;
    testPredsAz = {testPredsAz};
    
    testLabelsAz = testData.eulers(nonOccInds,:);
    testLabelsAz(:,1:2) = 0;
    Azs = testLabelsAz(:,3);
    
    frontFacing = (Azs <= pi/6) | (abs(Azs-pi)<pi/6) | (Azs > 11*pi/6);
    sideFacing = (abs(Azs-pi/2) <= pi/6) | (abs(Azs-3*pi/2)<=pi/6);
    
    testErrs = evaluatePredictionError(testPredsAz,testLabelsAz,'euler');
    accs{1} = testErrs <= accTheta;
    
    accs{2} = (testErrs <= 2*accTheta) & (testErrs > accTheta);
    
    testErrs = evaluatePredictionError(testPredsAz,azimuthFlip(testLabelsAz),'euler');
    accs{3} = testErrs <= accTheta;
 
    testErrs = evaluatePredictionError(testPredsAz,azimuthReflect(testLabelsAz),'euler');
    accs{4} = testErrs <= accTheta;
    
    fracFront = sum(accs{1}(frontFacing))/sum(frontFacing);
    fracSide = sum(accs{1}(sideFacing))/sum(sideFacing);
        
    N = numel(accs{1});
    unPred = true(size(accs{1}));
    for j=1:length(accs)
        unPred = unPred & ~accs{j};
    end
    perf = vertcat(perf,[sum(accs{1}),sum(accs{2} & ~accs{1}),sum(accs{3} & ~accs{1}),sum(accs{4} & ~accs{1}),sum(unPred),fracFront*N,fracSide*N]/N);
    disp(class);
end

perf = [perf;mean(perf,1)];
disp(perf);

end

function angles = azimuthFlip(angles)
    angles(:,3) = angles(:,3)+pi;
    inds = angles(:,3)>2*pi;
    angles(inds,3) = angles(inds,3)-2*pi;
    
end

function angles = azimuthReflect(angles)
        angles(:,3) = pi - angles(:,3);
end