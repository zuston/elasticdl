// Copyright 2020 The ElasticDL Authors. All rights reserved.
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"time"

	//"elasticdl.org/elasticdl/pkg/common"
	"elasticdl.org/elasticdl/pkg/ps"
)

var (
	jobName               = flag.String("job_name", "", "ElasticDL job name")
	namespace             = flag.String("namespace", "", "The name of the Kubernetes namespace where ElasticDL pods will be created")
	masterAddr            = flag.String("master_addr", "localhost:50001", "The master pod address")
	port                  = flag.Int("port", 2222, "The server port")
	useAsync              = flag.Bool("use_async", false, "true for asynchronous SGD, false for synchronous SGD")
	gradsToWait           = flag.Int("grads_to_wait", 1, "Number of gradients to wait before updating mode")
	lrStalenessModulation = flag.Bool("lr_staleness_modulation", false, "If True, PS will modulate the learning rate with staleness")
	syncVersionTolerance  = flag.Int("sync_version_tolerance", 0, "The maximum model version difference between reported gradients and PS that synchronous SGD can accepts")
	evaluationSteps       = flag.Int("evaluation_steps", 0, "Evaluate the model every this many steps. If 0, evaluation is disabled")
	numPsPods             = flag.Int("num_ps_pods", 1, "Number of PS pod")
	psID                  = flag.Int("ps_id", 0, "PS id")
	numWorkers            = flag.Int("num_workers", 1, "Number of workers")
	checkpointDirForInit  = flag.String("checkpoint_dir_for_init", "", "The checkpoint directory to initialize the training model")
	checkpointDir         = flag.String("checkpoint_dir", "", "The directory to store the checkpoint file")
	checkpointSteps       = flag.Int("checkpoint_steps", 0, "Save checkpoint every this many steps. If 0, no checkpoints to save")
	keepCheckpointMax     = flag.Int("keep_checkpoint_max", 3, "The maximum number of recent checkpoint files to keep. If 0, keep all")
	optType               = flag.String("opt_type", "unknown", "optimizer type")
	optArgs               = flag.String("opt_args", "", "optimizer arguments")
)

func main() {
	flag.Parse()
	address := fmt.Sprintf("%s:%d", os.Getenv("MY_POD_IP"), *port)
	serverDone := make(chan bool)
	ps.NewServer(*psID, *optType, *optArgs, *masterAddr, *evaluationSteps,
		*checkpointDirForInit, *checkpointDir, *checkpointSteps,
		*keepCheckpointMax, *numPsPods, *lrStalenessModulation).Run(address, *numWorkers, serverDone)
	log.Println("PS service started at ", address)
	//masterPodName := common.GetMasterPodName(*jobName)
	//clientSet := common.CreateClientSet()
	done := false
	for {
		select {
		case done = <-serverDone:
			break
		default:
			//if common.PodFinished(clientSet, *namespace, masterPodName) {
			//	grpcServer.Stop()
			//}
			log.Println("Checking, interval is 30s")
			time.Sleep(time.Second * 30)
		}
		// if done is true, it will break.
		if done {
			break
		}
	}
	log.Println("PS service stopped.")
}
