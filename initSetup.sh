# Directory for data
mkdir data

# Download PASCAL 3D
wget ftp://cs.stanford.edu/cs/cvgl/PASCAL3D+_release1.1.zip
unzip PASCAL3D+_release1.1.zip
mv PASCAL3D+_release1.1 PASCAL3D
mv PASCAL3D+* data/

# move all imagenet images in PASCAL3D+ in one folder, to resemble the pascal VOC setup
mkdir -p data/imagenet/images
for x in $(ls data/PASCAL3D/Images | grep imagenet); do mv data/PASCAL3D/Images/$x/*.JPEG data/imagenet/images/; done

# copy pascal3d metric evaluation files to pascal3d folder
cp p3dEvaluate/*.m data/PASCAL3D/VDPM/

# Download r-cnn detections
wget -P ./data/ http://www.cs.berkeley.edu/~shubhtuls/cachedir/vpsKps/VOC2012_val_det.mat 

# Download keypoint annotations
# TODO
mkdir ./data/segkps
wget -P ./data/segkps/ http://www.cs.berkeley.edu/~shubhtuls/cachedir/vpsKps/segkps.zip
unzip ./data/segkps/segkps.zip -d ./data/segkps/

# Download PASCAL VOC
wget http://host.robots.ox.ac.uk:8080/pascal/VOC/voc2012/VOCtrainval_11-May-2012.tar
tar -xf VOCtrainval_11-May-2012.tar
mv VOCdevkit data/
mv VOCtrainval_11-May-2012.tar data/

