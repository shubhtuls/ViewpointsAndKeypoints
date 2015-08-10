# Viewpoints And Keypoints

[Shubham Tulsiani](http://cs.berkeley.edu/~shubhtuls) and [Jitendra Malik](http://cs.berkeley.edu/~malik). Viewpoints and Keypoints. In CVPR, 2015.

### 0) Setup
- We first need to download the required datasets (PASCAL VOC and PASCAL3D+). In addition, we also need to reorgaanize some data and fetch precomputed R-CNN detections. To do this automatically, run

```bash initSetup.sh```

(if PASCAL VOC server is not working, uncomment the corresponding lines from the script and move a local copy to the desired location)

- Edit the required paths in 'startup.m', specially if you've used a local copy of some data instead of downloading via initSetup.sh

- Compile caffe (this is a slightly modified and outdated version of the [original](http://caffe.berkeleyvision.org/)). Sample compilation instructions are provided below. In case of any issues, refer to the installation instructions on the [caffe website](http://caffe.berkeleyvision.org/).

```
cd external/caffe
cp Makefile.config.example Makefile.config
make -j 8
#edit MATLAB_DIR in Makefile.config
make matcaffe
cd ../..
```


### 1) Viewpoint Prediction

#### Preprocessing :
We first need to create some data-structures which store the annotations for each object category. To do this run in matlab -

``` mainVpsPreprocess ```

#### Network Training : 

- We train two networks here - one for predicting all the euler angles (vggJointVps), other for various bin sizes of azimuth as required by AVP evaluation (vggAzimuthVps).
- Update the solver files in prototxts/[vggJointVps/vggAzimuthVps]/solver.prototxt to refer to the locations of the net configuration file as well as update the directory for saving snapshots.
- Update the window file paths in the data layers of  prototxts/[vggJointVps/vggAzimuthVps]/trainTest.prototxt and to refer to the Train/Val files created by above functions.
- Train the networks. Run the commands below from the caffe directory :

```./build/tools/caffe.bin train -solver ../../prototxts/vggJointVps/solver.prototxt -weights PATH_TO_PRETRAINED_VGG_CAFFEMODEL
./build/tools/caffe.bin train -solver ../../prototxts/vggAzimuthVps/solver.prototxt -weights PATH_TO_PRETRAINED_VGG_CAFFEMODEL```

- After training the models, save the final snapshot in SNAPSHOT_DIR/finalSnapshots/[vggJointVps,vggAzimuthVps].caffemodel/, where SNAPSHOT_DIR is set in startup.m

#### Predciting Pose for PASCAL VOC
- We will predict viewpoints for objects in PASCAL VOC validation set as well as for the R-CNN detections. To compute this, run

```
mainVpsPredict
```

(computing pose for all R-CNN detections might take a while, you can comment the corresponding lines if you just want to reproduce the evaluation given ground-truth boxes)

#### Evaluation and Analysis
- To evaluate the pose predicted for objects with known ground-truth box, run 

```
mainRigidViewpoint
```
- To evaluate the poses predicted via the three metrics used in the original paper, run

```
runAvpExperiments
```

- To analyze the effect of object characteristics and error modes of our system, run 

```
perfCharachteristics = smallVsLarge() ;
perfModes = errorModes();
```

### 2) Keypoint Prediction :

#### Preprocessing :
We first need to create some data-structures which store the annotations for each object category. To do this run in matlab -

``` mainKpsPreprocess ```

#### Network Training : 

- We train two networks here - one for predicting keypoints at a coarse scale (6 X 6) and another for afiner scale (12 X 12). 
- Update the solver files in prototxts/[vggConv6Kps/vggConv12Kps]/solver.prototxt to refer to the locations of the net configuration file as well as update the directory for saving snapshots.
- Update the window file paths in the data layers of  prototxts/[vggJointVps/vggAzimuthVps]/trainTest.prototxt and to refer to the Train/Val files created by above functions.
- Train the networks. Run the commands below from the caffe directory :

```./build/tools/caffe.bin train -solver ../../prototxts/vggConv6Kps/solver.prototxt -weights PATH_TO_PRETRAINED_VGG_CAFFEMODEL
./build/tools/caffe.bin train -solver ../../prototxts/vggConv12Kps/solver.prototxt -weights PATH_TO_TRAINED_VGG_6_X_6_KPS_CAFFEMODEL```

Note that for training the finer scale model, we initialize from a coarse scale model. An alternate is to finetune from a classification VGG model but this requires the use of cumulative gradients and a much longer training time.

- After training the models, save the final snapshot in SNAPSHOT_DIR/finalSnapshots/[vggConv6Kps,vggConv12Kps].caffemodel/, where SNAPSHOT_DIR is set in startup.m

#### Predciting Pose for PASCAL VOC
- We will predict keypoints for objects in PASCAL VOC validation set as well as for the R-CNN detections. To compute this, run

```
mainKpsPredict
```

(computing pose for all R-CNN detections might take a while, you can comment the corresponding lines if you just want to reproduce the evaluation given ground-truth boxes)

#### Evaluation and Analysis
- To evaluate the keypoints predicted for objects with known ground-truth box, run 

```
mainRigidPck
```
- To evaluate the poses predicted via the three metrics used in the original paper, run

```
mainRigidApk
```

- To analyze the effect of object characteristics and error modes of our system, run 

```
objectCharacteristics
```