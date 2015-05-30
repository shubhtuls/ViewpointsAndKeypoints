function output=compute_ap_boxesin(a, imglist, cluster_imids, cluster_pred_boxes, cluster_scores, istorso,thresh, image_ids_present)
%keyboard


%first get ground truth
if(~exist('istorso','var'))
	istorso=0;
end
if(~exist('thresh', 'var'))
	thresh=0.5;
end
if(istorso)
	torso_ks = [1 4 7 10];
	tt = a.coords(torso_ks,1:2,:);
	gt_bounds = [min(tt,[],1) max(tt,[],1)-min(tt,[],1)]; clear tt;
	gt_bounds = permute(gt_bounds,[3 2 1]);
else
	tt=a.bounds;
	gt_bounds = tt;clear tt;
end

[gt_valid, gt_imids]=ismember(a.img_name, {imglist.id});

%the valid ground truth
gt_valid=gt_valid & ~a.img_flipped & ~isnan(gt_bounds(:,1));

%the valid detections
det_valid=true(numel(cluster_imids),1);


if(exist('image_ids_present', 'var'))
	%only evaluate on subset
	gt_valid=gt_valid & ismember(gt_imids, image_ids_present);
	det_valid=det_valid & ismember(cluster_imids(:), image_ids_present);
end
gt_valid=find(gt_valid);
det_valid=find(det_valid);

gt_bounds = gt_bounds(gt_valid,:);
gt_imids = gt_imids(gt_valid); 

cluster_imids=cluster_imids(det_valid);
cluster_pred_boxes=cluster_pred_boxes(det_valid,:);
cluster_scores=cluster_scores(det_valid);

covered = false(size(gt_bounds,1),1);


output.gt_bounds=gt_bounds;
output.gt_imids=gt_imids;
output.gt_valid=gt_valid;
output.det_valid=det_valid;
output.labels = false(length(cluster_imids),1);
output.scores = nan(length(cluster_imids),1);
output.duplicate = false(length(cluster_imids),1);
output.mislocalize = false(length(cluster_imids),1);
output.mislocdup = false(length(cluster_imids),1);

output.index=zeros(length(cluster_imids),1);

all_imids=unique([cluster_imids(:); gt_imids(:)]);
cl_keep_all=cell(max(all_imids),1);
for k=1:numel(cl_keep_all)
	cl_keep_all{k}=zeros(1,1000);
	cnt(k)=0;
end
for i=1:numel(cluster_imids)
	cl_keep_all{cluster_imids(i)}(cnt(cluster_imids(i))+1)=i;
	cnt(cluster_imids(i))=cnt(cluster_imids(i))+1;
	if(rem(i-1,10000)==0) fprintf('.'); end
end
fprintf('\n');
sum(cnt)
for k=1:numel(cl_keep_all)
	cl_keep_all{k}=cl_keep_all{k}(1:cnt(k));
end



for imid=all_imids(:)'
    
    if(rem(imid, 100)==0) fprintf('In %d / %d\n',imid,length(all_imids)); end
    
    cl_keep = cl_keep_all{imid};%find([clusters.imid]==imid);
    pred_torsos = cluster_pred_boxes(cl_keep,:);
	scores = cluster_scores(cl_keep,:);
        
    [s si] = sort(scores,'descend');
    pred_torsos = pred_torsos(si,:);
    scores = s;
    
    gt_keep = find(gt_imids==imid); 
	if(isempty(gt_keep))
		output.labels(cl_keep)=false;
		output.scores(cl_keep)=scores;
		output.duplicate(cl_keep)=false;
		continue;
	end

    
    iou = inters_union(pred_torsos,gt_bounds(gt_keep,:));
    
    for i=1:length(scores)
        iou_i = iou(i,:);
        [iou_i mi] = sort(iou_i,'descend');
		output.max_iou(cl_keep(si(i)))=iou_i(1);
        if any(iou_i>=thresh)
            if any(~covered(gt_keep(mi(iou_i>=thresh))))
                I = find(~covered(gt_keep(mi)));I=I(1);
                assert(iou_i(I)>=thresh);
				assert(~covered(gt_keep(mi(I))))
                output.labels(cl_keep(si(i)))=true;
                output.scores(cl_keep(si(i)))=scores(i);
                output.duplicate(cl_keep(si(i)))=false;
				output.index(cl_keep(si(i)))=gt_keep(mi(I));
                covered(gt_keep(mi(I)))=true;
            else
                output.labels(cl_keep(si(i)))=false;
                output.scores(cl_keep(si(i)))=scores(i);
                output.duplicate(cl_keep(si(i)))=true;
            end
        else
			if any(~covered(gt_keep(mi(iou_i>=thresh/2))))
				output.mislocalize(cl_keep(si(i)))=true;
			elseif any(iou_i>=thresh/2)
				output.mislocdup(cl_keep(si(i)))=true;
			end

            output.labels(cl_keep(si(i)))=false;
            output.scores(cl_keep(si(i)))=scores(i);
            output.duplicate(cl_keep(si(i)))=false;
        end
            
   end
    
    
end

% AP if we ignore duplicates
sc = output.scores(~output.duplicate);
lbls = output.labels(~output.duplicate);
[ap,rec,prec,scores] = get_precision_recall(sc,lbls,[],length(gt_valid));
fprintf('Ignore duplicates: Ap = %f\n',ap*100);
% AP if duplicates are considered false
sc = output.scores;
lbls = output.labels;
[ap,rec,prec,scores] = get_precision_recall(sc,lbls,[],length(gt_valid));
output.rec=rec;
output.prec=prec;
fprintf(' Ap = %f\n',ap*100);

end

function iou = inters_union(bounds1,bounds2)

inters = rectint(bounds1,bounds2);
ar1 = bounds1(:,3).*bounds1(:,4);
ar2 = bounds2(:,3).*bounds2(:,4);
union = bsxfun(@plus,ar1,ar2')-inters;

iou = inters./(union+0.001);

end
