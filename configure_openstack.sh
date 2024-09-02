#!/bin/bash
# Exit on any error
set -e

# Step 5: Bootstrap the cluster
echo "Bootstrapping the cluster with the provided openstack.yaml..."
sunbeam cluster bootstrap --manifest openstack.yaml --role control --role compute --role storage

echo "Cluster bootstrapping completed."
