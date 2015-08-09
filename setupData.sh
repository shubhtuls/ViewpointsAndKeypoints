# Directory for data
mkdir data

# Download PASCAL VOC
wget http://host.robots.ox.ac.uk:8080/pascal/VOC/voc2012/VOCtrainval_11-May-2012.tar
tar -xf VOCtrainval_11-May-2012.tar
mv VOCdevkit data/
mv VOCtrainval_11-May-2012.tar data/

# Download PASCAL 3D
wget ftp://cs.stanford.edu/cs/cvgl/PASCAL3D+_release1.1.zip
unzip PASCAL3D+_release1.1.zip
mv PASCAL3D+_release1.1 PASCAL3D
mv PASCAL3D+* data/

# move all imagenet images in PASCAL3D+ in one folder, to resemble the pascal VOC setup
mkdir -p data/imagenet/images
for x in $(ls data/PASCAL3D/Images | grep imagenet); do mv data/PASCAL3D/Images/$x/*.JPEG data/imagenet/images/; done

# Download keypoint annotations
# TODO

# Download modified version of caffe
mkdir external
## TODO - git pull caffe

# Download pascal keypoint annotations
# TODO

# Download r-cnn detections
# TODO