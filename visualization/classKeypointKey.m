function [key] = classKeypointKey(class)
%CLASSKEYPOINTKEY Summary of this function goes here
%   Detailed explanation goes here

switch class
    case 'aeroplane'
        key.groups = {'rudder','stabilizer','nose','wings','engine'};
        key.groupInds = [1 1 2 2 4 4 3 3 3 4 4 5 5 5 5 1];
    case 'bicycle'
        key.groups = {'handle','seat','wheels','crankSet'};
        key.groupInds = [1 1 1 2 3 3 3 3 3 3 4];
    case 'boat'
        key.groups = {'hullFront','hullBack','hullMid','mast','sail'};
        key.groupInds = [1 1 2 2 3 3 3 3 4 5 5];
    case 'bottle'
        key.groups = {'top','neck','shoulder','base'};
        key.groupInds = [1 1 2 2 3 3 4 4];
    case 'bus'
        key.groups = {'frontRoof','backRoof','frontBase','backBase'};
        key.groupInds = [1 1 2 2 3 3 4 4];
    case 'car'
        key.groups = {'wheels','headLights','backLights','mirrors','rooftop'};
        key.groupInds = [1 1 1 1 2 2 3 3 4 4 5 5 5 5];
    case 'chair'
        key.groups = {'seatLeft','seatRight','legLeft','legRight','backRest'};
        key.groupInds = [1 1 2 2 3 3 4 4 5 5];
    case 'diningtable'
        key.groups = {'topLeft','topRight','botLeft','botRight'};
        key.groupInds = [1 1 2 2 3 3 4 4];
    case 'motorbike'
        key.groups = {'handle','seat','wheels','exhaust','tailLight'};
        key.groupInds = [1 1 1 2 3 3 3 3 4 5];
    case 'sofa'
        key.groups = {'backLeft','backRight','frontLeft','frontRight','handleLeft','handleRight'};
        key.groupInds = [1 2 1 2 3 4 3 4 5 6 5 6];
    case 'train'
        key.groups = {'baseLeft','baseRight','roof'};
        key.groupInds = [1 2 3 1 3 2 3];
    case 'tvmonitor'
        key.groups = {'topLeft','topRight','botLeft','botRight'};
        key.groupInds = [1 2 3 4 1 2 3 4];
    otherwise
        disp('Not yet supported this class')
        key = struct;
end

end

