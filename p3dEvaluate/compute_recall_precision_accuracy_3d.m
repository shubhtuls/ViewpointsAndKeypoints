% compute recall and viewpoint accuracy
function [recall, precision, accuracy, ap, aa] = compute_recall_precision_accuracy_3d(cls, viewThresh,methodId)

%azimuth_interval = [0 (360/(vnum_test*2)):(360/vnum_test):360-(360/(vnum_test*2))];

% viewpoint annotation path
path_ann_view = '../Annotations';

% read ids of validation images
pascal_init;
ids = textread(sprintf(VOCopts.imgsetpath, 'val'), '%s');
M = numel(ids);

% open prediction file
%filename = sprintf('data/%s_%d_test_flip.mat', cls, vnum_train);
filename = sprintf('data/%s_3d_%s.mat', methodId, cls);
object = load(filename);
dets_all = object.dets;

energy = [];
correct = [];
correct_view = [];
overlap = [];
count = zeros(M,1);
num = zeros(M,1);
num_pr = 0;

for i = 1:M
    fprintf('%s %d/%d\n', cls, i, M);
    % read ground truth bounding box
    rec = PASreadrecord(sprintf(VOCopts.annopath, ids{i}));
    clsinds = strmatch(cls, {rec.objects(:).class}, 'exact');
    diff = [rec.objects(clsinds).difficult];
    clsinds(diff == 1) = [];
    n = numel(clsinds);
    bbox = zeros(n, 4);
    for j = 1:n
        bbox(j,:) = rec.objects(clsinds(j)).bbox;
    end
    count(i) = size(bbox, 1);
    det = zeros(count(i), 1);
    
    % read ground truth viewpoint
    if isempty(clsinds) == 0
        filename = fullfile(path_ann_view, sprintf('%s_pascal/%s.mat', cls, ids{i}));
        object = load(filename);
        record = object.record;
        view_gt = zeros(n, 3);
        for j = 1:n
            vp = record.objects(clsinds(j)).viewpoint;
            if vp.distance == 0
                azimuth = vp.azimuth_coarse;
            else
                azimuth = vp.azimuth;
            end
            %view_gt(j) = find_interval(azimuth, azimuth_interval);
            view_gt(j,:) = [vp.theta vp.elevation azimuth];
        end
    else
        view_gt = [];
    end
    
    % get predicted bounding box
    dets = dets_all{i};
    num(i) = size(dets, 1);
    % for each predicted bounding box
    for j = 1:num(i)
        num_pr = num_pr + 1;
        energy(num_pr) = dets(j, end);        
        bbox_pr = dets(j, 1:4);
        %view_pr = find_interval((dets(j, 5) - 1) * (360 / vnum_train), azimuth_interval);
        view_pr = dets(j, 5:7);
        
        % compute box overlap
        if isempty(bbox) == 0
            o = box_overlap(bbox, bbox_pr);
            [maxo, index] = max(o);
            if maxo >= 0.5 && det(index) == 0
                overlap{num_pr} = index;
                correct(num_pr) = 1;
                det(index) = 1;
                % check viewpoint
                diff = rotDiff(view_pr,view_gt(index,:));
                 if diff < viewThresh
                    correct_view(num_pr) = 1;
                else
                    correct_view(num_pr) = 0;
                end
            else
                overlap{num_pr} = [];
                correct(num_pr) = 0;
                correct_view(num_pr) = 0;
            end
        else
            overlap{num_pr} = [];
            correct(num_pr) = 0;
            correct_view(num_pr) = 0;
        end
    end
end
overlap = overlap';

[threshold, index] = sort(energy, 'descend');
correct = correct(index);
correct_view = correct_view(index);
n = numel(threshold);
recall = zeros(n,1);
precision = zeros(n,1);
accuracy = zeros(n,1);
num_correct = 0;
num_correct_view = 0;
for i = 1:n
    % compute precision
    num_positive = i;
    num_correct = num_correct + correct(i);
    if num_positive ~= 0
        precision(i) = num_correct / num_positive;
    else
        precision(i) = 0;
    end
    
    % compute accuracy
    num_correct_view = num_correct_view + correct_view(i);
    if num_correct ~= 0
        accuracy(i) = num_correct_view / num_positive;
    else
        accuracy(i) = 0;
    end
    
    % compute recall
    recall(i) = num_correct / sum(count);
end


ap = VOCap(recall, precision);
fprintf('AP = %.4f\n', ap);

aa = VOCap(recall, accuracy);
fprintf('AA = %.4f\n', aa);

% draw recall-precision and accuracy curve
figure;
hold on;
plot(recall, precision, 'r', 'LineWidth',3);
plot(recall, accuracy, 'g', 'LineWidth',3);
xlabel('Recall');
ylabel('Precision/Accuracy');
tit = sprintf('Average Precision = %.1f / Average Accuracy = %.1f', 100*ap, 100*aa);
title(tit);
hold off;

end

function delta = rotDiff(a1,a2)
    a1 = a1*pi/180;a2 = a2*pi/180;
    R1 = angle2dcm(a1(1),a1(2)-pi/2,-a1(3),'ZXZ');
    R2 = angle2dcm(a2(1),a2(2)-pi/2,-a2(3),'ZXZ');
    delta = norm(logm(R1'*R2),'fro')/sqrt(2)*180/pi;
end

function ind = find_interval(azimuth, a)

for i = 1:numel(a)
    if azimuth < a(i)
        break;
    end
end
ind = i - 1;
if azimuth > a(end)
    ind = 1;
end

end
