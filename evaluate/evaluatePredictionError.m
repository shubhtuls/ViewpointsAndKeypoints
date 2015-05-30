function [errors,predBest] = evaluatePredictionError(prediction,gt,encoding)

%gt = gt(randperm(size(gt,1)),:);
errors = Inf(size(gt,1),1);
if(iscell(prediction))
    predBest = prediction{1};
    for i=1:length(prediction)
        eulersPred{i} = decodePose(prediction{i},encoding);
        rotsPred{i} = encodePose(eulersPred{i},'rot');
    end
else
    predBest = prediction;
    eulersPred = {decodePose(prediction,encoding)};
    rotsPred = {encodePose(eulersPred{1},'rot')};
end

eulersGt = decodePose(gt,encoding);
rotsGt = encodePose(eulersGt,'rot');

for h=1:length(rotsPred)
    for i=1:size(gt,1)
        rotPred = reshape(rotsPred{h}(i,:),3,3);
        rotGt = reshape(rotsGt(i,:),3,3);
        err = norm(logm(rotGt*rotPred'), 'fro');
        if(err < errors(i))
            errors(i)=err;
            if(h > 1)
                predBest(i,:) = prediction{h}(i,:);
            end
        end
    end
end
errors = errors/sqrt(2)*180/pi;

%error = mean(errors);
%bar(errSort);
%medianErr = median(errors);
end
