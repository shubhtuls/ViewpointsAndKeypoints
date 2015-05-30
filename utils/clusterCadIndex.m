function [cadInd] = clusterCadIndex(clusterInd,class,subtypeClusters)
%CLUSTERCADINDEX Summary of this function goes here
%   Detailed explanation goes here
cadInd = 0;
if(ischar(class))
    class = pascalClassIndex(class);
end
if(nargin<3)
    globals;
    load(fullfile(cachedir,'subtypeClusters'));
end
goodInds = find( subtypeClusters{class} == clusterInd);
if(numel(goodInds))
    cadInd = goodInds(1);
end

end