function [rotationData] = augmentKps(rotationData,dataStruct)
%AUGMENTKPS Summary of this function goes here
%   Detailed explanation goes here

globals;
nKp = size(dataStruct.kps{1},1);

for i=1:length(rotationData)
    %%
    js = find(ismember(dataStruct.voc_image_id,{rotationData(i).voc_image_id}));
    boxThis = rotationData(i).bbox;
    if(isempty(js))
        rotationData(i).kps = nan(nKp,2);
    else
        boxes = dataStruct.bbox(js,:);
        boxDist = sum(abs(bsxfun(@minus,boxes,boxThis)),2);
        jThis = js(boxDist <= 4);
        if(isempty(jThis))
            rotationData(i).kps = nan(nKp,2);
        else
            rotationData(i).kps = dataStruct.kps{jThis(1)};
        end
    end
    %%
end

end