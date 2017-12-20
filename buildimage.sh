#!/bin/bash
#
# Basic helper script to automate the build of a packer image and optionally storing that
# as a managed image in Azure.  The script also checks that the environment is set up correctly
# and that the latest version of the hardening role is being used.
#

function usage()
{
	echo "Usage: $0"
	echo "  -h: displays this help"
	echo "  -r: resource name (also checks for AZURE_RESOURCE_GROUP)"
	echo "  -s: storage account (also checks for AZURE_STORAGE_ACCOUNT)"
	echo "  -i: converts VHD into managed image of name \"moj-centos-<DDMMYY>\" after build completes,"
	echo "      otherwise, build is left as blob in storage account"
}

function check_commands()
{
	command -v az >/dev/null 2>&1 || { echo "The Azure CLI 2.0 is required, but is not installed or not in the PATH.  Exiting..." >&2; exit 1; }
	command -v packer >/dev/null 2>&1 || { echo "Packer is required, but is not installed or not in the PATH.  Exiting..." >&2; exit 1; }
	command -v git >/dev/null 2>&1 || { echo "Git is required, but is not installed or not in the PATH.  Exiting..." >&2; exit 1; }
}

function check_vars()
{
	if [[ ! -v AZURE_STORAGE_ACCOUNT ]]; then
		echo "Azure storage account not specified and not passed as argument. Please enter storage account name:"
		read AZURE_STORAGE_ACCOUNT
	fi
	if [[ ! -v AZURE_RESOURCE_GROUP ]]; then
		echo "Azure resource group not specified and not passed as argument. Please enter resource group name:"
		read AZURE_RESOURCE_GROUP
	fi
}

function check_az_login()
{
	if ! az account show >>/dev/null ; then
		echo "Please log in to Azure with \"az login\" before running this script."
		exit 1
	fi
}

check_commands

while getopts hr:s:i option
do
case "${option}"
    in
        h) 
          usage
          exit 0
          ;;
        r)
          export AZURE_RESOURCE_GROUP=${OPTARG}
          ;;
        s)
          export AZURE_STORAGE_ACCOUNT=${OPTARG}
          ;;
        i)
          export create_image=true
          ;;
        *)
          usage
          exit 1
          ;;
    esac
done

check_az_login
check_vars
img_name="moj-centos-`date +"%d%m%y"`"

# Check to see if the ansible-hardening repo exists and update if it does
if [ ! -d ansible-hardening ]; then
	git clone https://github.com/openstack/ansible-hardening >> /dev/null 2>&1
else
	cd ansible-hardening && git pull >> /dev/null 2>&1 && cd - >>/dev/null 2>&1
fi
# Check to see if the ClamAV repo exists and update if it does
if [ ! -d ansible-role-clamav ]; then
        git clone https://github.com/contino/ansible-role-clamav .git >> /dev/null 2>&1
else
        cd ansible-role-clamav && git pull >> /dev/null 2>&1 && cd - >>/dev/null 2>&1
fi

if [ ! -d moj-hardening-ansible ]; then
        git clone https://github.com/contino/moj-hardening-ansible.git >> /dev/null 2>&1
else
        cd moj-hardening-ansible && git pull >> /dev/null 2>&1 && cd - >>/dev/null 2>&1
fi

# Get the required creds for the build process
read client_id client_secret tenant_id <<< $(az ad sp create-for-rbac --query [appId,password,tenant] -o tsv)
read subscription_id <<< $(az account show --query [id] -o tsv)

# Build the image with packer and output command output to a temp
temp_file=$(mktemp)
echo $temp_file
packer build -var azure_client_id=$client_id \
             -var azure_client_secret=$client_secret \
             -var azure_tenant_id=$tenant_id \
             -var azure_subscription_id=$subscription_id \
             -var azure_resource_group_name=$AZURE_RESOURCE_GROUP \
             -var azure_storage_account=$AZURE_STORAGE_ACCOUNT \
             os-centos-7.4-x86_64.json | tee $temp_file
RETVAL=$?

# Query temp file for the newly created blob URL
vhd_url=$(cat $temp_file | grep OSDiskUri: | cut -f2 -d" ")
echo vhd_url=$vhd_url
rm -f $temp_file

# Create the image, only if the packer command was successful
if [ "$CREATE_IMAGE" = true ] && [ "$RETVAL" -eq "0" ]; then
    #unused, but handy bit of code...
    #AZURE_STORAGE_KEY=$(az storage account keys list -g $AZURE_RESOURCE_GROUP -n $AZURE_STORAGE_ACCOUNT --query "[?keyName=='key1'] | [0].value" -o tsv)
    az image create --name $img_name --resource-group $AZURE_RESOURCE_GROUP --source $vhd_url --os-type Linux
    if [ "$?" -eq "0" ]; then
        echo "Image \"$IMG_NAME\" successfully created"
    fi
fi

exit 0
