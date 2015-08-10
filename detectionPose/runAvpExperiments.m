classes = {'aeroplane','bicycle','bird','boat','bottle','bus','car','cat','chair','cow','diningtable','dog','horse','motorbike','person','plant','sheep','sofa','train','tvmonitor'};
classInds = [1 2 4 6 7 9 11 14 18 19 20];
globals;
%% AVP
nBins = [4 8 16 24];
perf = zeros(20,4);
for c = classInds
    class = classes{c};
    for n=1:4
        computeDetectionPoses(class,nBins(n));
        cd(fullfile(PASCAL3Ddir,'VDPM'));
        [r,p,a,ap,aa] = compute_recall_precision_accuracy_bins(class,nBins(n),nBins(n),'vpsKps');
        perf(c,n) = aa;
        cd(basedir);
        startup;

    end
end

%% AVPtheta
perfTheta = zeros(20,1);
for c = classInds
    class = classes{c};
    computeDetectionPosesContinuous(class);
    cd(fullfile(PASCAL3Ddir,'VDPM'));
    [r,p,a,ap,aa] = compute_recall_precision_accuracy_continuous(class,30,'vpsKps');
    perfTheta(c) = aa;
    cd(basedir);
    startup;
end

%% ARP
perfArp = zeros(20,1);
for c = classInds
    class = classes{c};
    computeDetectionPoses3d(class);
    cd(fullfile(PASCAL3Ddir,'VDPM'));
    [r,p,a,ap,aa] = compute_recall_precision_accuracy_3d(class,30,'vpsKps');
    perfArp(c) = aa;
    cd(basedir);
    startup;
end
