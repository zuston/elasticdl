#!/usr/bin/env bash
# Copyright 2020 The ElasticDL Authors. All rights reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.



JOB_TYPE=$1
PS_NUM=$2
WORKER_NUM=$3
DATA_PATH=$4

MNIST_CKPT_DIR=/model_zoo/test_data/mnist_ckpt/

if [[ "$JOB_TYPE" == "train" ]]; then
    elasticdl train \
      --image_name=elasticdl:ci \
      --model_zoo=model_zoo \
      --model_def=deepfm_functional_api.deepfm_functional_api.custom_model \
      --training_data=/data/frappe/train \
      --validation_data=/data/frappe/test \
      --num_epochs=1 \
      --master_resource_request="cpu=0.2,memory=1024Mi" \
      --master_resource_limit="cpu=1,memory=2048Mi" \
      --worker_resource_request="cpu=0.4,memory=2048Mi" \
      --worker_resource_limit="cpu=1,memory=3072Mi" \
      --ps_resource_request="cpu=0.2,memory=1024Mi" \
      --ps_resource_limit="cpu=1,memory=2048Mi" \
      --minibatch_size=64 \
      --num_minibatches_per_task=2 \
      --num_workers="$WORKER_NUM" \
      --num_ps_pods="$PS_NUM" \
      --checkpoint_steps=500 \
      --evaluation_steps=500 \
      --grads_to_wait=1 \
      --use_async=True \
      --job_name=test-train \
      --log_level=INFO \
      --image_pull_policy=Never \
      --output=/data/saved_model/model_output \
      --need_elasticdl_job_service=true \
      --volume="host_path=${DATA_PATH},mount_path=/data"
elif [[ "$JOB_TYPE" == "evaluate" ]]; then
    elasticdl evaluate \
      --image_name=elasticdl:ci \
      --model_zoo=model_zoo \
      --model_def=mnist.mnist_functional_api.custom_model \
      --checkpoint_dir_for_init=${MNIST_CKPT_DIR}/version-100  \
      --validation_data=/data/mnist/test \
      --num_epochs=1 \
      --master_resource_request="cpu=0.3,memory=1024Mi" \
      --master_resource_limit="cpu=1,memory=2048Mi" \
      --worker_resource_request="cpu=0.4,memory=2048Mi" \
      --worker_resource_limit="cpu=1,memory=3072Mi" \
      --ps_resource_request="cpu=0.2,memory=1024Mi" \
      --ps_resource_limit="cpu=1,memory=2048Mi" \
      --minibatch_size=64 \
      --num_minibatches_per_task=2 \
      --num_workers="$WORKER_NUM" \
      --num_ps_pods="$PS_NUM" \
      --evaluation_steps=15 \
      --job_name=test-evaluate \
      --log_level=INFO \
      --image_pull_policy=Never \
      --need_elasticdl_job_service=true \
      --volume="host_path=${DATA_PATH},mount_path=/data"
elif [[ "$JOB_TYPE" == "predict" ]]; then
    elasticdl predict \
      --image_name=elasticdl:ci \
      --model_zoo=model_zoo \
      --model_def=mnist.mnist_functional_api.custom_model \
      --checkpoint_dir_for_init=${MNIST_CKPT_DIR}/version-100 \
      --prediction_data=/data/mnist/test \
      --master_resource_request="cpu=0.2,memory=1024Mi" \
      --master_resource_limit="cpu=1,memory=2048Mi" \
      --worker_resource_request="cpu=0.4,memory=2048Mi" \
      --worker_resource_limit="cpu=1,memory=3072Mi" \
      --ps_resource_request="cpu=0.2,memory=1024Mi" \
      --ps_resource_limit="cpu=1,memory=2048Mi" \
      --minibatch_size=64 \
      --num_minibatches_per_task=2 \
      --num_workers="$WORKER_NUM" \
      --num_ps_pods="$PS_NUM" \
      --job_name=test-predict \
      --log_level=INFO \
      --image_pull_policy=Never \
      --need_elasticdl_job_service=true \
      --volume="host_path=${DATA_PATH},mount_path=/data"
elif [[ "$JOB_TYPE" == "odps" ]]; then
    elasticdl train \
      --image_name=elasticdl:ci \
      --model_zoo=model_zoo \
      --model_def=odps_iris_dnn_model.odps_iris_dnn_model.custom_model \
      --training_data="$MAXCOMPUTE_TABLE" \
      --data_reader_params='columns=["sepal_length", "sepal_width", "petal_length", "petal_width", "class"]; label_col="class"' \
      --envs="MAXCOMPUTE_PROJECT=$MAXCOMPUTE_PROJECT,MAXCOMPUTE_AK=$MAXCOMPUTE_AK,MAXCOMPUTE_SK=$MAXCOMPUTE_SK,MAXCOMPUTE_ENDPOINT=" \
      --num_epochs=2 \
      --master_resource_request="cpu=0.2,memory=1024Mi" \
      --master_resource_limit="cpu=1,memory=2048Mi" \
      --worker_resource_request="cpu=0.4,memory=2048Mi" \
      --worker_resource_limit="cpu=1,memory=3072Mi" \
      --ps_resource_request="cpu=0.2,memory=1024Mi" \
      --ps_resource_limit="cpu=1,memory=2048Mi" \
      --minibatch_size=64 \
      --num_minibatches_per_task=2 \
      --num_workers="$WORKER_NUM" \
      --num_ps_pods="$PS_NUM" \
      --checkpoint_steps=10 \
      --grads_to_wait=2 \
      --job_name=test-odps \
      --log_level=INFO \
      --image_pull_policy=Never \
      --need_elasticdl_job_service=true \
      --need_tf_config=true \
      --output=model_output
elif [[ "$JOB_TYPE" == "allreduce" ]]; then
    elasticdl train \
      --image_name=elasticdl:ci \
      --model_zoo=model_zoo \
      --model_def=mnist.mnist_functional_api.custom_model \
      --training_data=/data/mnist/train \
      --num_epochs=1 \
      --master_resource_request="cpu=0.2,memory=1024Mi" \
      --master_resource_limit="cpu=1,memory=2048Mi" \
      --worker_resource_request="cpu=0.3,memory=2048Mi" \
      --worker_resource_limit="cpu=1,memory=3072Mi" \
      --minibatch_size=64 \
      --num_minibatches_per_task=2 \
      --num_workers="$WORKER_NUM" \
      --distribution_strategy=AllreduceStrategy \
      --job_name=test-allreduce \
      --log_level=INFO \
      --image_pull_policy=Never \
      --need_elasticdl_job_service=true \
      --volume="host_path=${DATA_PATH},mount_path=/data"
else
    echo "Unsupported job type specified: $JOB_TYPE"
    exit 1
fi
