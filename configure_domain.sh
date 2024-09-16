#!/bin/bash

# Exit on any error
set -e

sudo snap install yq -y

# Path to the YAML file
YAML_FILE="openstack.yaml"

# Read the external cidr value from the YAML file using yq
EXTERNAL_IP_SUBNET=$(yq e '.external_network.cidr' "$YAML_FILE")

# Check if EXTERNAL_IP_SUBNET is empty
if [ -z "$EXTERNAL_IP_SUBNET" ]; then
    echo "CIDR value is missing in $YAML_FILE"
    exit 1
fi

# Read the internal cidr value from the YAML file using yq
INTERNAL_IP_SUBNET=$(yq e '.user.cidr' "$YAML_FILE")

# Check if INTERNAL_IP_SUBNET is empty
if [ -z "$INTERNAL_IP_SUBNET" ]; then
    echo "CIDR value is missing in $YAML_FILE"
    exit 1
fi

# Variables
DOMAIN_NAME="weaver"
DOMAIN_DESC="Weaver Labs Domain"
PROJECT_NAME="weaver"
PROJECT_DESC="Weaver Labs Project"
ADMIN_USER="weaver"
EXTERNAL_NETWORK_NAME="external-network"
EXTERNAL_SUBNET_NAME="external-subnet"
EXTERNAL_IP_SUBNET="$EXTERNAL_IP_SUBNET"
INTERNAL_NETWORK_NAME="weaver-vpc-network"
INTERNAL_SUBNET_NAME="weaver-vpc-subnet"
INTERNAL_IP_SUBNET="$INTERNAL_IP_SUBNET"
ROUTER_NAME="weaver-router"
NEW_ROUTER_NAME="weaver"

# Rename the users domain
echo "Renaming the users domain..."
openstack domain set --name "$DOMAIN_NAME" --description "$DOMAIN_DESC" --enable users

# Rename the demo project
echo "Renaming the demo project..."
openstack project set --name "$PROJECT_NAME" --description "$PROJECT_DESC" demo

# Obtain the user ID of the weaver admin account
USER_ID=$(openstack user list --domain "$DOMAIN_NAME" -f value -c ID -c Name | grep "$ADMIN_USER" | awk '{print $1}')

# Add the admin role to the project and user
echo "Adding the admin role to the user and project..."
openstack role add --project "$PROJECT_NAME" --user "$USER_ID" admin

# Rename the internal VPC network
echo "Renaming the internal VPC network..."
openstack network set --name "${INTERNAL_NETWORK_NAME}" demo-network

# Rename the internal subnet
echo "Renaming the internal subnet..."
openstack subnet set --name "${INTERNAL_NETWORK_NAME}-${INTERNAL_IP_SUBNET}" demo-subnet

# Rename the router
echo "Renaming the router..."
openstack router set --name "$NEW_ROUTER_NAME" demo-router

# Share the external network
echo "Sharing the external network..."
openstack network set --share "$EXTERNAL_NETWORK_NAME"

# Enable DHCP on the external subnet
echo "Enabling DHCP on the external subnet..."
openstack subnet set --dhcp "$EXTERNAL_SUBNET_NAME"

# Set DNS servers for the external subnet
echo "Setting DNS servers for the external subnet..."
openstack subnet set --dns-nameserver 8.8.8.8 --dns-nameserver 1.1.1.1 "$EXTERNAL_SUBNET_NAME"

# Rename the external subnet
echo "Renaming the external subnet..."
openstack subnet set --name "external-${EXTERNAL_IP_SUBNET}" "$EXTERNAL_SUBNET_NAME"

echo "Domain Configuration completed successfully."
