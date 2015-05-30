function [eulersRel] = computeRelativeRotations(eulers1,eulers2)
%COMPUTERELATIVEROTATIONS Summary of this function goes here
%   Detailed explanation goes here

rots1 = angle2dcm(eulers1(:,1),eulers1(:,2),eulers1(:,3));
rots2 = angle2dcm(eulers2(:,1),eulers2(:,2),eulers2(:,3));
eulersRel = zeros(size(eulers1));

for i=1:size(rots1,3)
    [eulersRel(i,1), eulersRel(i,2), eulersRel(i,3)] = dcm2angle((rots1(:,:,i))'*rots2(:,:,i));
end

end

