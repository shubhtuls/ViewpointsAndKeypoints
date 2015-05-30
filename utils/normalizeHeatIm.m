function [heatIm] = normalizeHeatIm(heatIm,bboxRatio)
%NORMALIZEHEATIM Summary of this function goes here
%   Detailed explanation goes here

heatIm = max(heatIm,exp(-11));
heatIm = min(heatIm,1-exp(-11));
heatIm = log(heatIm) - log(1-heatIm);
%sum(sum(isnan(heatIm)))
heatIm = heatIm - min(max(max(heatIm))-1,0);
dtVal = max(max(max(heatIm,0)))/4;dtRange = size(heatIm,1)/2;

if(bboxRatio <1)
    dtValx=dtVal*(bboxRatio)^2;
    dtValy = dtVal;
else
    dtValx = dtVal;
    dtValy=dtVal/(bboxRatio^2);
end

[heatIm,~,~] = fast_bounded_dt(heatIm,dtValx,0,dtValy,0,dtRange);
heatIm = 1./(1+exp(-heatIm));

end