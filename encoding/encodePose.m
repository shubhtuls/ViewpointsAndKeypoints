function targets = encodePose(eulers, angle_encoding)

switch angle_encoding
case 'euler'
    targets = eulers;
case 'cos_sin'
    targets = [];
    for i=1:size(eulers,2)
        targets = [targets, cos(eulers(:,i)), sin(eulers(:,i))];
    end
case 'leCunn'
    targets = [];
    for i=1:size(eulers,2)
        targets = [targets, cos(eulers(:,i)-pi/3), cos(eulers(:,i)), cos(eulers(:,i)+pi/3)];
    end
case 'axisAngle'
    targets = [];
    all_targets = angle2dcm(eulers(:,1),eulers(:,2)-pi/2,-eulers(:,3),'ZXZ');
    for i=1:size(all_targets,3)
        rotVec = vrrotmat2vec(all_targets(:,:,i));
        rotVec = rotVec(1:3)*rotVec(4);
        [theta,phi,R] = cart2sph(rotVec(1),rotVec(2),rotVec(3));
        %targets(i,:) = [cos(theta) sin(theta) cos(phi) sin(phi) R];
        targets(i,:) = [cos(theta) sin(theta) cos(phi) sin(phi) cos(R) sin(R)];
        %targets(i,:) = [theta phi R];
    end
case 'rot'
    %% TODO
    % Read project_3d to see how to get rotation matrices from euler angles
    % specified.
    % First roation along Z by azimuth. Then along X by -(pi/2-elevation).
    % Then along Z by theta
    targets = [];
    %all_targets = angle2dcm(eulers(:,1),eulers(:,2),eulers(:,3));
    
    all_targets = angle2dcm(eulers(:,1),eulers(:,2)-pi/2,-eulers(:,3),'ZXZ');
    for i=1:size(all_targets,3)
        new_targets = all_targets(:,:,i);
        t = new_targets(:);
        targets(i,:) = t';
    end
otherwise
    error('no such encoding available');
end

end
