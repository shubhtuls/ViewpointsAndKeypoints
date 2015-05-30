function [] = prettyPrintResults(errors,medErrors,numCol)

if(nargin<3)
    numCol = 1;
end

numClasses = size(errors,1);
for col = 1:numCol
    for c = 1:numClasses
        fprintf('%2.2f (%2.2f) \n',errors(c,col),medErrors(c,col));
    end
    fprintf('%2.2f (%2.2f) \n\n\n',mean(errors(:,col)),mean(medErrors(:,col)));
end

end
