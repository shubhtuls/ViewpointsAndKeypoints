#include <vector>

#include "caffe/data_layers.hpp"

namespace caffe {

template <typename Dtype>
void WindowMulticlassKeypointDataLayer<Dtype>::Forward_gpu(
    const vector<Blob<Dtype>*>& bottom, const vector<Blob<Dtype>*>& top) {
  // First, join the thread
  this->JoinPrefetchThread();
  // Copy the data
  caffe_copy(this->prefetch_data_.count(), this->prefetch_data_.cpu_data(),
      top[0]->mutable_gpu_data());
  caffe_copy(this->prefetch_label_.count(), this->prefetch_label_.cpu_data(),
      top[1]->mutable_gpu_data());
  caffe_copy(this->prefetch_filter_.count(), this->prefetch_filter_.cpu_data(),
      top[2]->mutable_gpu_data());
  // Start a new prefetch thread
  this->CreatePrefetchThread();
}

INSTANTIATE_LAYER_GPU_FORWARD(WindowMulticlassKeypointDataLayer);

}  // namespace caffe
