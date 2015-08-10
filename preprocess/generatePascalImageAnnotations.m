function [] = generatePascalImageAnnotations()
%GENERATEIMAGEANNOTATIONS Summary of this function goes here
%   Detailed explanation goes here
globals;
addpath(fullfile(pascalDir,'VOCcode'));
classIds = 1:20;
delete(fullfile(annotationDir,'*.mat'))

%% Create files using pascal annotations
fnames = getFileNamesFromDirectory(fullfile(pascalDir,'VOC2012','Annotations'),'types',{'.xml'},'mode','path');
%keyboard;
for i=1:length(fnames)
    if(~mod(i,100))
        disp([num2str(i) '/' num2str(length(fnames))]);
    end
    id = fnames{i}(end-14:end-4);
    rec = VOCreadxml(fnames{i});
    N = length(rec.annotation.object);
    poly_x = {};poly_y = {};
    voc_rec_id = zeros(N,1);kps = {};
    class = zeros(N,1);bbox = zeros(N,4);
    occluded = zeros(N,1);difficult = zeros(N,1);truncated = zeros(N,1);
    imsize = [str2num(rec.annotation.size.height) str2num(rec.annotation.size.width)]; 
    for j =1:length(rec.annotation.object)
        object = rec.annotation.object(j);
        poly_x{j} = [];poly_y{j} = [];kps{j} = [];
        voc_rec_id(j) = j;
        class(j) = pascalClassIndex(object.name);
        if(isfield(object,'occluded'))
            occluded(j) = str2num(object.occluded);
        end
        if(isfield(object,'difficult'))
            difficult(j) = str2num(object.difficult);
        end
        if(isfield(object,'truncated'))
            truncated(j) = str2num(object.truncated);
        end
        if(isfield(object,'bndbox'))
           bbox(j,:) = round([str2num(object.bndbox.xmin) str2num(object.bndbox.ymin) str2num(object.bndbox.xmax) str2num(object.bndbox.ymax)]);
        end
    end
    save(fullfile(annotationDir,[id '.mat']),'poly_x','poly_y','voc_rec_id','kps','class','bbox','difficult','truncated','occluded','imsize');
end

%% Adding kp annotations
for c = classIds
    objClass = pascalIndexClass(c);
    disp(objClass);
    load(fullfile(segkpAnnotationDir,objClass));
    for i=1:length(keypoints.voc_image_id)
        imName = keypoints.voc_image_id{i};
        imFile = fullfile(annotationDir,[imName '.mat']);
        var = load(imFile);
        index = find(ismember(var.voc_rec_id,keypoints.voc_rec_id(i)));
        if(isempty(index))
            disp('Error : rec_id not found !');
        else
            ind = index;
        end
        if(c ~= var.class(ind))
            disp('oops. Stop now !! ')
        end
        var.kps{ind} = squeeze(keypoints.coords(i,:,:));
        %bbox(ind,:) = keypoints.bbox(i,:); % bbox computed using pascalAnnotations
        %save(imFile,'poly_x','poly_y','voc_rec_id','kps','class','bbox','difficult','truncated','occluded','imsize');
        save(imFile,'-struct','var');
    end
end

%% Adding segm annotations
% for c = classIds
%     objClass = pascalIndexClass(c);
%     disp(objClass);
%     load(fullfile(segkpAnnotationDir,objClass));
%     for i=1:length(segmentations.voc_image_id)
%         imName = segmentations.voc_image_id{i};
%         imFile = fullfile(annotationDir,[imName '.mat']);
%         load(imFile);
%         index = find(ismember(voc_rec_id,segmentations.voc_rec_id(i)));
%         if(isempty(index))
%             %ind = size(bbox,1)+1;
%             %kps{ind} = [];
%             %bbox(ind,:) = zeros(1,4);
%             %voc_rec_id(ind) = segmentations.voc_rec_id(i);
%             %class(ind) = c;
%             disp('Error : rec_id not found !');
%         else
%             ind = index;
%         end
%         poly_x{ind} = segmentations.poly_x{i};
%         poly_y{ind} = segmentations.poly_y{i};
%         save(imFile,'poly_x','poly_y','voc_rec_id','kps','class','bbox','difficult','truncated','occluded','imsize');
%     end
% end

end

