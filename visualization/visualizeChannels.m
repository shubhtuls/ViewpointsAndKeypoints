function [] = visualizeChannels(fnames,suffix)
if(nargin<2)
    suffix = '';
end
featDim = [3,6,9,12];
imgSizes = (featDim+1)*32;
parfor channel = 1:18
    disp(channel);
    mapNum = 0;
    for f = featDim
        mapNum=mapNum+1;
        dim = featDim(mapNum);
        layer = ['conv' num2str(dim) suffix];
        neuronIms = visualizeNeuron(layer,channel,[dim dim],fnames,imgSizes(mapNum));
        [~,ImAll] = makeMontage(neuronIms,629,629,1);
        Ims{channel}{mapNum} = ImAll{1};
    end
end
save('cache/personChannels.mat','Ims');
end
