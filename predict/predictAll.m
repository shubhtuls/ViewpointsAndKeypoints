function [preds] = predictAll(feat,dataStruct,predMethod)
%PREDICTDATA Summary of this function goes here
%   Detailed explanation goes here

globals;
hDims = params.heatMapDims;
if(nargin < 3)
    predMethod = params.predMethod;
end

parfor i=1:size(feat,1)
    %if(~mod(i,50))
    %    disp(i)    
    %end
    bbox = dataStruct.bbox(i,:);
    [preds(i).coords,preds(i).scores] = predict(feat(i,:),bbox,predMethod,hDims);
end

end
