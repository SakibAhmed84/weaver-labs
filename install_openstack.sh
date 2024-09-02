#!/bin/bash
# Exit on any error
set -e

# Step 1: Install OpenStack using Snap
echo "Installing OpenStack from the 2024.1/edge channel..."
sudo snap install openstack --channel 2024.1/edge

# Step 2: Wait for the installation to complete
echo "Waiting for the OpenStack installation to complete..."
while ! snap list | grep -q 'openstack'; do
    sleep 5
done
echo "OpenStack installation completed."

# Step 3: Run the preparation script and update the user group
echo "Running the Sunbeam preparation script..."
sunbeam prepare-node-script | bash -x && newgrp snap_daemon
