function radius = normDist(gtKps,torsoKps,alpha)
% One can input  pairs of points [lsho,rhip;rsho,lhip] and this function
% returns distance between first valid pair
radius = 0;
if(size(torsoKps,2)==2) %FLIC or LSP
    for i=1:size(torsoKps,1)
        if(~sum(isnan(gtKps(torsoKps(i,:),2))))
            radius = norm(gtKps(torsoKps(i,1),:) - gtKps(torsoKps(i,2),:));
            radius = radius*alpha;
            return;
        end
    end
elseif(size(torsoKps,2)==4) % PASCAL
    if(~sum(isnan(gtKps(torsoKps,2))))
        radius = max(gtKps(torsoKps,2)) - min(gtKps(torsoKps,2));
        radius = radius*alpha;
    end
end
end