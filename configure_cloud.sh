#!/bin/bash
# Exit on any error
set -e

# Step 6: Configure OpenStack Cloud
echo "Configuring the cloud with the provided openstack.yaml..."
sunbeam configure --manifest openstack.yaml --openrc weaver-openrc

echo "Cloud configuration completed. Check weaver-openrc file for details"
