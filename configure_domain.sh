#!/bin/bash
# Exit on any error
set -e

# Step 7: Configure Domain
echo "Configuring the base Domain.."

sunbeam openrc > adminrc
source adminrc

openstack domain set --name weaver --description "Weaver Labs Domain" --enable users
openstack project create --domain weaver --description "Weaver Labs Project" weaver
openstack user create --domain weaver --password toor9999 weaver

# Variables for the domain, project, and role
USER_NAME="weaver"
DOMAIN_NAME="weaver"
PROJECT_NAME="weaver"
ROLE_NAME="admin"

# Check if openstack CLI is installed
if ! command -v openstack &> /dev/null; then
    echo "OpenStack CLI is not installed. Please install it before running this script."
    exit 1
fi

# Get IDs for the domain, project, user, and role
DOMAIN_ID=$(openstack domain list -f value -c ID -c Name | grep "$DOMAIN_NAME" | awk '{print $1}')
PROJECT_ID=$(openstack project list -f value -c ID -c Name | grep "$PROJECT_NAME" | awk '{print $1}')
USER_ID=$(openstack user list --domain "$DOMAIN_NAME" -f value -c ID -c Name | grep "$USER_NAME" | awk '{print $1}')
ROLE_ID=$(openstack role list -f value -c ID -c Name | grep "$ROLE_NAME" | awk '{print $1}')

echo "Domain ID:" $DOMAIN_ID
echo "Project ID:" $PROJECT_ID
echo "User ID:" $USER_ID
echo
# Check if the IDs are retrieved correctly
#if [ -z "$DOMAIN_ID" ] || [ -z "$PROJECT_ID" ] || [ -z "$USER_ID" ] || [ -z "$ROLE_ID" ]; then
#    echo "Failed to retrieve one or more IDs. Please check the names and ensure they exist."
#    exit 1
#fi

# Assign the role to the user in the project
echo "Assigning role $ROLE_ID to user $USER_ID in project $PROJECT_ID..."
openstack role add --project "$PROJECT_ID" --user "$USER_ID" "$ROLE_ID"

echo "Role assignment complete."
echo
echo "Setting network Names"
openstack network set --name weaver-network demo-network
openstack router set --name weaver-router demo-router
echo "Completed.."
echo
echo "Domain configuration completed."
