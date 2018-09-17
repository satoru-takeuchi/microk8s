#!/usr/bin/env bash

set -e

source $SNAP/actions/common/utils.sh

echo "Disabling NVIDIA GPU support"
skip_opt_in_config "default-runtime" dockerd
sudo systemctl restart snap.${SNAP_NAME}.daemon-kubelet
use_manifest gpu delete


sudo sh -c "sed 's@\${SNAP}@'"${SNAP}"'@g;s@\${SNAP_DATA}@'"${SNAP_DATA}"'@g;s@\${RUNTIME}@runc@g' $SNAP_DATA/args/containerd-template.toml > $SNAP_DATA/args/containerd.toml"

containerd_up=$(wait_for_service containerd)
if [[ $containerd_up == fail ]]
then
  echo "Containerd did not start on time. Proceeding."
fi
# Allow for some seconds for containerd processes to start
sleep 10
kubelet_up=$(wait_for_service kubelet)
if [[ $kubelet_up == fail ]]
then
  echo "Kubelet did not start on time. Proceeding."
fi

"$SNAP/kubectl" "--kubeconfig=$SNAP/client.config" "delete" "-f" "${SNAP}/actions/gpu.yaml"



echo "GPU support disabled"
