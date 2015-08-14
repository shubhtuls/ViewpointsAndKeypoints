function pos=readVpsDataPascal(cls,excludeOccluded)
% Read pascal to generate filtered instances of classes
% Also reads PASCAL3D dataset to figure out the object index in pascal3D

%%
globals;

%% File names
annoDir = fullfile(PASCAL3Ddir,'Annotations',[cls '_pascal']);
posNames = getFileNamesFromDirectory(annoDir,'types',{'.mat'});
for i=1:length(posNames)
    posNames{i} = posNames{i}(1:end-4);
end
pos = [];

%% Create one entry per bounding box in the pos array
numpos = 0;
for j = 1:length(posNames)
    load(fullfile(annoDir,posNames{j}));
    for k=1:length(record.objects)
        if(strcmp(cls,record.objects(k).class) && ~isempty(record.objects(k).viewpoint) && ~record.objects(k).difficult)
            if(~excludeOccluded || (~record.objects(k).truncated && ~record.objects(k).occluded))
                numpos = numpos + 1;
                bbox   = round(record.objects(k).bbox);
                pos(numpos).imsize = record.imgsize(1:2);
                pos(numpos).voc_image_id = posNames{j};
                pos(numpos).voc_rec_id = k;
                %pos(numpos).im      = [VOCopts.datadir rec.imgname];
                pos(numpos).bbox   = bbox;
                pos(numpos).view    = '';
                pos(numpos).kps     = [];
                pos(numpos).part_names  = {};
                %pos(numpos).maskBbox        = keypoints.bbox(ki,:);
                pos(numpos).poly_x      = [];
                pos(numpos).poly_y      = [];
                pos(numpos).mask = [];
                pos(numpos).class       = cls;
                pos(numpos).rot = [];
                pos(numpos).euler = [];
                pos(numpos).detScore = Inf;
                pos(numpos).IoU = 1;
                pos(numpos).occluded = record.objects(k).occluded;
                pos(numpos).truncated = record.objects(k).truncated;

                %% Getting camera
                objectInd = k;
                viewpoint = record.objects(objectInd).viewpoint;
                [rot,euler]=viewpointToRots(viewpoint);
                pos(numpos).rot=rot;
                pos(numpos).euler=euler;

                pos(numpos).objectInd = objectInd;
                pos(numpos).dataset = 'pascal';
                pos(numpos).subtype = record.objects(k).cad_index;
            end
        end
    end
end

end


function [R,euler] = viewpointToRots(vp)
    if(~isfield(vp,'azimuth'))
        vp.azimuth = vp.azimuth_coarse;
    end
    
    if(~isfield(vp,'elevation'))
        vp.elevation = vp.elevation_coarse;
    end
    
    if(~isfield(vp,'theta'))
        vp.theta = 0;
    end
    euler = [vp.azimuth vp.elevation vp.theta]' .* pi/180;
    R = angle2dcm(euler(3), euler(2)-pi/2, -euler(1),'ZXZ'); %took a lot of work to figure this formula out !!
    euler = euler([3 2 1]);
end
