function [kpNumGauss,kpCoordsGauss,kpVal] = gaussianKps(kpNum,kpCoords,dims,probThresh)

kpNumGauss = [];
kpCoordsGauss = [];
kpVal = [];
sigma = 0.5; %0.5 means only centre cell, 1 means nearing 8 cells as well
% 0.5 seems to work better so let it be

Xs = meshgrid(1:dims(1),1:dims(2));Xs = Xs(:);
Ys = meshgrid(1:dims(2),1:dims(1))';Ys = Ys(:); %Xs and Ys are Ydim X Xdim
oneArr = ones(size(Xs));

for i=1:size(kpCoords,1)
    pXs = normpdf([1:dims(1)] - kpCoords(i,1),0,sigma)/normpdf(0,0,sigma);
    pYs = normpdf([1:dims(2)] - kpCoords(i,2),0,sigma)/normpdf(0,0,sigma);
    pXYs = pYs'*pXs;pXYs = pXYs(:);goodInds = pXYs >=probThresh;
    kpNumGauss = vertcat(kpNumGauss,kpNum(i)*oneArr(goodInds));
    kpVal = vertcat(kpVal,pXYs(goodInds));
    kpCoordsGauss = vertcat(kpCoordsGauss,[Xs(goodInds) Ys(goodInds)]);    
end

end