function [map] = resizeHeatMap(hmap,dims,dimsOut)

globals;
method = params.interpolationMethod;

if(nargin<3)
    dimsOut = params.heatMapDims;
end
nKps = size(hmap,2)/(dims(1)*dims(2));
N = size(hmap,1);
map = nan(N,nKps*dimsOut(1)*dimsOut(2));
xRatio = dims(1)/dimsOut(1);
yRatio = dims(2)/dimsOut(2);
[Xq,Yq] = meshgrid(1:dimsOut(1),1:dimsOut(2));
Xq = (Xq - 0.5)*xRatio + 0.5;
Yq = (Yq - 0.5)*yRatio + 0.5;

for n = 1:N
    %if(~mod(n,500))
        %disp(n)
    %end
    for k = 1:nKps
        if(~strcmp(method,'nearest'))
            mapKp = hmap(n,(k-1)*dims(1)*dims(2)+1:(k)*dims(1)*dims(2));
            mapKp = reshape(mapKp,dims(2),dims(1));
            mapOut = interp2(mapKp,Xq,Yq,method);
            mapOut = mapOut(:);
            map(n,(k-1)*dimsOut(1)*dimsOut(2)+1:(k)*dimsOut(1)*dimsOut(2)) = mapOut;
        end
        
        for x=1:dimsOut(1)
            for y = 1:dimsOut(2)
                xIn = ceil(x*xRatio);
                yIn = ceil(y*yRatio);
                index = (k-1)*dimsOut(1)*dimsOut(2) + (x-1)*dimsOut(2) + y;
                indexIn = (k-1)*dims(1)*dims(2) + (xIn-1)*dims(2) + yIn;
                 if(isnan(map(n,index)))
                    map(n,index) = hmap(n,indexIn);
                 end
             end
        end
    end
end


end
