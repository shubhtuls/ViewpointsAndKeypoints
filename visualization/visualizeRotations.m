function [] = visualizeRotations(gt,prediction,data,encoding,scale)
%VISUALIZEROTATIONS Summary of this function goes here
%   Detailed explanation goes here
globals;
eulersPred = decodePose(prediction,encoding);
eulersGt = decodePose(gt,encoding);
rotsPred = encodePose(eulersPred,'rot');
rotsGt = encodePose(eulersGt,'rot');

for i=1:size(gt,1)
    rotPred = reshape(rotsPred(i,:),3,3);
    rotGt = reshape(rotsGt(i,:),3,3);
    predVec = vrrotmat2vec(rotPred);predVec = predVec(1:3)*predVec(4)*scale;
    gtVec = vrrotmat2vec(rotGt);gtVec = gtVec(1:3)*gtVec(4)*scale;
    im = imread(fullfile(PASCAL_DIR,[data.voc_ids{i} '.jpg']));
    bbox = data.bboxes(i,:);
    xMean = (bbox(1)+bbox(3))/2;yMean = (bbox(2)+bbox(4))/2;
    figure();
    warp(im);hold on;
    quiver3(xMean,yMean,0,predVec(1),predVec(2),predVec(3),'g','LineWidth',3);hold on;
    quiver3(xMean,yMean,0,gtVec(1),gtVec(2),gtVec(3),'r','LineWidth',3);hold on;
    e1 = norm(logm(rotGt*rotPred'))*sqrt(2)*180/pi;
    e2 =  1/scale*norm(gtVec-predVec)*180/pi;
    
    title([num2str(e1) , ' ',num2str(e2), ' ' num2str(e1/e2)]);axis equal;
    pause();close all;
end

end

