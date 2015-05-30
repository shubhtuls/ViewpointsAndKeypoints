function [ap,rec,prec,scores] = get_precision_recall(scores,labels,opt,rec_denom)

[srt1,srtd]=sort(scores,'descend');
scores = srt1;
fp=cumsum(~labels(srtd));
tp=cumsum( labels(srtd));
if ~isempty(rec_denom)
    rec = tp/rec_denom;
else
    rec=tp/sum(labels);
end
prec=tp./(fp+tp);


mrec=[0 ; rec ; 1];
mpre=[0 ; prec ; 0];
for i=numel(mpre)-1:-1:1
    mpre(i)=max(mpre(i),mpre(i+1));
end
i=find(mrec(2:end)~=mrec(1:end-1))+1;
ap=sum((mrec(i)-mrec(i-1)).*mpre(i));

if strcmp(opt,'max')
    prec = mpre;
    prec(1)=[];
    prec(end)=[];
end

end