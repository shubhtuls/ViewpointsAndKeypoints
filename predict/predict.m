function [kpCoords,scores] = predict(heatMap,bbox,method,dims)
%PREDICT Summary of this function goes here
%   Detailed explanation goes here

switch method
    case 'maxLocation'
        [kpCoords,scores] = maxLocationPredict(heatMap,bbox,dims);
    case 'maxLocationCandidates'
        [kpCoords,scores] = maxLocationCandidates(heatMap,bbox,dims);
    case 'maxCandidate'
        disp('This method is currently not supported')
        return;
    case 'maxPictorial'
        key = lspKey();
        [kpCoords,scores] = maxPictorialPredict(heatMap,bbox,dims,key.midparts,14);
    case 'regression'
        disp('This method is not supported')
        return;
        %[kpCoords,scores] = regressionPredict(heatMap,bbox,dims,W);
end

end

