function euler_angles = decodePose(encoded_angles, encoding_type)
  % maps back to euler angles

    switch encoding_type
    case 'euler'
        euler_angles = encoded_angles;
    case 'cos_sin'
    euler_angles = zeros(size(encoded_angles,1),3);
        for i=1:3
            id = (i-1)*2 + 1;
            ids = id:id+1;
            angle_i_enc = encoded_angles(:,ids);
            euler_angles(:,i) = atan2(angle_i_enc(:,2), angle_i_enc(:,1));
        end
    case 'leCunn'
    euler_angles = zeros(size(encoded_angles,1),3);
    sins = sin([-pi/3 0 pi/3]');coses = cos([-pi/3 0 pi/3]');
        for i=1:3
            id = (i-1)*3 + 1;
            ids = id:id+2;
            angle_i_enc = encoded_angles(:,ids);
            euler_angles(:,i) = atan2(angle_i_enc*sins, angle_i_enc*coses);
        end
    case 'rot'
        if(size(encoded_angles,2)>3)
            for i=1:size(encoded_angles,1)
                enc_angles(:,:,i) = reshape(encoded_angles(i,:),3,3);
            end
        else
            enc_angles = encoded_angles;
        end

        [a,b,c] = dcm2angle(enc_angles,'ZXZ'); %,'ZYX','ZeroR3');
        euler_angles = [a (b+pi/2) -c];
    case 'axisAngle'
        %axes = encoded_angles(:,1:3);
        %axes = normr(axes);
        for i=1:size(encoded_angles,1)
            theta = atan2(encoded_angles(i,2),encoded_angles(i,1));
            %theta = encoded_angles(i,1);
            phi = atan2(encoded_angles(i,4),encoded_angles(i,3));
            %phi = encoded_angles(i,2);
            %R = abs(encoded_angles(i,3));
            R = atan2(encoded_angles(i,6),encoded_angles(i,5));
            %if(R<0)
            %    R = R+2*pi;
            %end
            [X,Y,Z] = sph2cart(theta,phi,R);
            enc_angles(:,:,i) = vrrotvec2mat([[X,Y,Z]/norm([X,Y,Z]) norm([X,Y,Z])]);
        end
        [a,b,c] = dcm2angle(enc_angles,'ZXZ'); %,'ZYX','ZeroR3');
        euler_angles = [a (b+pi/2) -c];

    otherwise
        error('no such encoding');
    end
    euler_angles = real(euler_angles);
end
