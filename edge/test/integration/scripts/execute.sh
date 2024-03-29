#!/bin/bash

# Copyright 2019 The KubeEdge Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

TEST_DIR=$(dirname $(dirname "${BASH_SOURCE[0]}"))

function cleanup() {
  while true; do
    sudo pkill edgecore || true
    sleep 1
    pidof edgecore >/dev/null || break
  done

  sudo rm -rf $TEST_DIR/appdeployment/appdeployment.test $TEST_DIR/device/device.test
}

function do_preparation() {
  sudo mkdir -p /var/lib/kubeedge

  which ginkgo &>/dev/null || {
    go install github.com/onsi/ginkgo/v2/ginkgo@latest
    sudo cp $GOPATH/bin/ginkgo /usr/bin/
  }

  # create cert files
  $TEST_DIR/scripts/generate_cert.sh

  local module=$1
  # Specify the module name to compile in below command
  bash -x $TEST_DIR/scripts/compile.sh $module
}

function run_test() {
  :> /tmp/testcase.log

  local module=$1
  MQTT_SERVER=127.0.0.1 bash -x ${TEST_DIR}/scripts/fast_test.sh $module
}

set -eE
trap cleanup ERR
trap cleanup EXIT

cleanup

do_preparation $1

run_test $1
