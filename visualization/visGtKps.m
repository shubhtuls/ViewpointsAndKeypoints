function [] = visGtKps(class)
%VISGTKPS Summary of this function goes here
%   Detailed explanation goes here
globals;
classInd = pascalClassIndex(class);
fnames = getFileNamesFromDirectory(annotationDir,'types',{'.mat'},'mode','path');
for i=1:length(fnames)
    var = load(fnames{i});
    kps = var.kps(var.class == classInd);
    kpCoords = [];
    for j=1:length(kps)
        kpCoords = vertcat(kpCoords,kps{j});
    end
    if(~isempty(kpCoords))
        im = imread(fullfile(imagesDir,[fnames{i}(end-14:end-4) '.jpg']));
        imagesc(im);hold on;
        plot(kpCoords(:,1),kpCoords(:,2),'r.');axis equal;
        title(num2str(size(kpCoords,2)));
        pause();close;
    end
end

end

function kps = normKps(kps,bbox,dims)
%kps is (N*Nkps) X 2

deltaX = (bbox(:,3)-bbox(:,1)+1)/dims(1);
deltaY = (bbox(:,4)-bbox(:,2)+1)/dims(2);

kps(:,1) = ((kps(:,1)-bbox(:,1))./deltaX);
kps(:,2) = ((kps(:,2)-bbox(:,2))./deltaY);

badInds = isnan(kps(:,1)) |  isnan(kps(:,2)) | (kps(:,1))<0 | kps(:,2) < 0 | kps(:,1) >= dims(1) | kps(:,2) >= dims(2) ;
kps(badInds,:) = nan;

end