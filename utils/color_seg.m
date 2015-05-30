function im1=color_seg(seg, img, ucm)
img=im2double(img);
im1=zeros(size(img));
img=rgb2gray(img);

im1(:,:,1)=0.5*img;
im1(:,:,2)=0.5*seg+0.5*img;
im1(:,:,3)=0.5*seg+0.5*img;
if(nargin>2)
stren=ucm.strength(3:2:end, 3:2:end);
stren=(stren<0.1);
im1=bsxfun(@times, im1, double(stren));
end
