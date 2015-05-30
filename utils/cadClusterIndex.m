function [clusterInd] = cadClusterIndex(cadInd,class,subtypeClusters)
%CADCLUSTERINDEX Summary of this function goes here
%   Detailed explanation goes here

if(ischar(class))
    class = pascalClassIndex(class);
end
if(nargin < 3)
    load(fullfile(cachedir,'subtypeClusters'));
end

clusterInd = subtypeClusters{class}(cadInd);


end

