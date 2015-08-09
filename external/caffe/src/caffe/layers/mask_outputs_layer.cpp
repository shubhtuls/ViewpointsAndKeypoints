// Copyright 2014 BVLC and contributors.

#include <algorithm>
#include <vector>

#include "caffe/layer.hpp"
#include "caffe/vision_layers.hpp"

using std::max;

namespace caffe {

template <typename Dtype>
void MaskOutputsLayer<Dtype>::SetUp(
  const vector<Blob<Dtype>*>& bottom, const vector<Blob<Dtype>*>& top) {
  int kernel_size = this->layer_param_.mask_outputs_param().kernel_size();
  const int num = bottom[0]->num();
  const int height = bottom[0]->height();
  const int width = bottom[0]->width();
  top[0]->Reshape(num, kernel_size, height, width);
}

template <typename Dtype>
void MaskOutputsLayer<Dtype>::Reshape(
  const vector<Blob<Dtype>*>& bottom, const vector<Blob<Dtype>*>& top) {
  int kernel_size = this->layer_param_.mask_outputs_param().kernel_size();
  const int num = bottom[0]->num();
  const int height = bottom[0]->height();
  const int width = bottom[0]->width();
  top[0]->Reshape(num, kernel_size, height, width);
}

template <typename Dtype>
void MaskOutputsLayer<Dtype>::Forward_cpu(const vector<Blob<Dtype>*>& bottom,
    const vector<Blob<Dtype>*>& top) {
  const Dtype* bottom_data = bottom[0]->cpu_data();
  const Dtype* start = bottom[1]->cpu_data();
  Dtype* top_data = top[0]->mutable_cpu_data();

  int kernel_size = this->layer_param_.mask_outputs_param().kernel_size();
  //const int count = bottom[0]->count();
  const int num = bottom[0]->num();
  const int nchannels = bottom[0]->channels();
  const int height = bottom[0]->height();
  const int width = bottom[0]->width();
  const int bottomOffset = nchannels*height*width;
  const int topOffset = kernel_size*height*width;

  for (int n = 0; n < num; ++n) {
    //LOG(INFO) << "Offset: " << kernel_size*start[n]*height*width << "label : " << start[n];
    int offsetIn = n*bottomOffset + start[n]*kernel_size*height*width; //nData*(C*H*W) + nChannel*(H*W)
    int offsetOut = n*topOffset;
    //cout<<start[n];
    for (int c = 0; c < kernel_size; ++c) {
        for (int i=0; i < height*width; ++i) {
            top_data[offsetOut+i] = bottom_data[offsetIn+i];
        }
        offsetIn += height*width;
        offsetOut += height*width;
    }
  }
}

template <typename Dtype>
void MaskOutputsLayer<Dtype>::Backward_cpu(const vector<Blob<Dtype>*>& top,
    const vector<bool>& propagate_down,
    const vector<Blob<Dtype>*>& bottom) {
  if (propagate_down[0]) {
    const Dtype* top_diff = top[0]->cpu_diff();
    Dtype* bottom_diff = bottom[0]->mutable_cpu_diff();
    const Dtype* start = bottom[1]->cpu_data();

    int kernel_size = this->layer_param_.mask_outputs_param().kernel_size();
    const int count = bottom[0]->count();
    const int num = bottom[0]->num();
    const int nchannels = bottom[0]->channels();
    const int height = bottom[0]->height();
    const int width = bottom[0]->width();
    const int bottomOffset = nchannels*height*width;
    const int topOffset = kernel_size*height*width;

    for (int i = 0; i < count; ++i) {
      bottom_diff[i] = Dtype(0);
    }

    for (int n = 0; n < num; ++n) {
        //LOG(INFO) << "Offset: " << start[n]*kernel_size*height*width << "label : " << start[n];
        int offsetIn = n*bottomOffset + start[n]*kernel_size*height*width; //nData*(C*H*W) + nChannel*(H*W)
        int offsetOut = n*topOffset;
        for (int c = 0; c < kernel_size; ++c) {
            for (int i=0; i < height*width; ++i) {
                bottom_diff[offsetIn+i] = top_diff[offsetOut+i];
            }
            offsetIn += height*width;
            offsetOut += height*width;
        }
    }
  }
}


INSTANTIATE_CLASS(MaskOutputsLayer);
REGISTER_LAYER_CLASS(MASK_OUTPUTS, MaskOutputsLayer);

}  // namespace caffe
