function [fnamesTrain] = generateImagenetTrainNames()
    globals;
    fnamesTrain = {};
    for i = params.classInds
        fId = fopen(fullfile(PASCAL3Ddir,'Image_sets',[pascalIndexClass(i) '_imagenet_train.txt']));
        names1 = textscan(fId,'%s');
        fId = fopen(fullfile(PASCAL3Ddir,'Image_sets',[pascalIndexClass(i) '_imagenet_val.txt']));
        names2 = textscan(fId,'%s');
        fnamesTrain = [fnamesTrain; names1{1}(:); names2{1}(:)];
    end
end