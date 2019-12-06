# OpenShift 4 on Azure Readme


## Azure SP Account

Because OpenShift Container Platform and its installation program must create Microsoft Azure resources through Azure Resource Manager, you must create a service principal to represent it.

az ad sp create-for-rbac --role Contributor --name ocp4lab-sp

The service principal requires the legacy Azure Active Directory Graph → Application.ReadWrite.OwnedBy permission and the User Access Administrator role for the cluster to assign credentials for its components.

az role assignment create --role "User Access Administrator" --assignee-object-id $(az ad sp list --filter "appId eq '<appId>'" | jq '.[0].objectId' -r)

Approve the permissions request. If your account does not have the Azure Active Directory tenant administrator role, follow the guidelines for your organization to request that the tenant administrator approve your permissions request.

az ad app permission add --id <appId> --api 00000002-0000-0000-c000-000000000000 --api-permissions 824c81eb-e3f8-4ee6-8f6d-de7f50d565b7=Role

This may need to be done via the Azure web portal under the SP account and granting permission.

## Subscription Info

Pull Secret  https://cloud.redhat.com/openshift/install/pull-secret

## Node Details

### Azure VM Size

### Node Counts

### Node Disk Sizes

## Networking

### DNS

### IP Details


## Cluster Storage

## Key Vault


## Automation Terraform

Tear down / up

## Authentication 