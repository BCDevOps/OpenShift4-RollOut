# OpenShift 4 on Azure Readme


## Azure SP Account

Because OpenShift Container Platform and its installation program must create Microsoft Azure resources through Azure Resource Manager, we must create a service principal to represent it.

`az ad sp create-for-rbac --role Contributor --name ocp4lab-sp`

The service principal requires the legacy Azure Active Directory Graph → Application.ReadWrite.OwnedBy permission and the User Access Administrator role for the cluster to assign credentials for its components.

`az role assignment create --role "User Access Administrator" --assignee-object-id $(az ad sp list --filter "appId eq '<appId>'" | jq '.[0].objectId' -r)`

Approve the permissions request. If your account does not have the Azure Active Directory tenant administrator role, follow the guidelines for your organization to request that the tenant administrator approve your permissions request.

`az ad app permission add --id <appId> --api 00000002-0000-0000-c000-000000000000 --api-permissions 824c81eb-e3f8-4ee6-8f6d-de7f50d565b7=Role`

This may need to be done via the Azure web portal under the SP account and granting permission.

## Subscription Info

We will need a pull secret to give to the Openshift 4 installer. The pull secret can be obtained here: https://cloud.redhat.com/openshift/install/pull-secret after logging in with a Red Hat account.

When the cluster first comes up it will default to a 60 day evaluation. This will be fine as we plan to destroy and re-create. Once the cluster is up is a steady permanent state we will need to assign subscriptions to it via Red Hat portal.

## Node Details

The install will start with 3 Master nodes and 3 worker nodes. This can be grown via cluster re-install or by updating machine-set replica numbers inside the cluster.

The Master VM sizes will start with a bit more resources than the recommended minimum to handle the expected increased API traffic. The worker nodes will start at the recommended minimum but can be increased if needed.


| Size | vCPU | Memory: GiB | Temp storage (SSD) GiB | Max data disks | Max cached and temp storage throughput: IOPS / MBps (cache size in GiB) | Max uncached disk throughput: IOPS / MBps | Max NICs / Expected network bandwidth (Mbps) |
|-----------------|------|-------------|------------------------|----------------|-------------------------------------------------------------------------|-------------------------------------------|----------------------------------------------|
| **Standard_D2s_v3** | 2 | 8 | 16 | 4 | 4000 / 32 (50) | 3200 / 48 | 2 / 1000 |
| Standard_D4s_v3 | 4 | 16 | 32 | 8 | 8000 / 64 (100) | 6400 / 96 | 2 / 2000 |
| **Standard_D8s_v3** | 8 | 32 | 64 | 16 | 16000 / 128 (200) | 12800 / 192 | 4 / 4000 |


The nodes will receive 1 OS disks with 150GB of storage. This is around the recommended minimum disk sizes. A better disk and partition scheme will be determined at a later date so we are not relying on a single disk.

## Networking

The default networking options will be selected to start with, which can be changed at a later date.

```
networking:
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  machineCIDR: 10.0.0.0/16
  networkType: OpenShiftSDN
  serviceNetwork:
  - 172.30.0.0/16
  ```

### DNS

The subdomain `clearwater.devops.gov.bc.ca` has been selected for the time being which may be updated at a later date. This DNS zone is created in Azure so the cluster can dynamically create zone records.

The subdomain `clearwater.devops.gov.bc.ca` will need to be delegated to Azure NS records.

```
ns1-07.azure-dns.com.
ns2-07.azure-dns.net.
ns3-07.azure-dns.org.
ns4-07.azure-dns.info.
```

## Cluster PV Storage

We will be able to leverage Azure file and block options for PV usage in the cluster. We can also create PVs based on Azure disk performance/pricing options.

A more detailed PV design will be determined at a later date.

## Key Vault

An Azure KeyVault will be created to store secrets required for the OpenShift install. Secure information like node ssh keys, pull-secrets, and kubeadmin password will be stored here.

## Automation 

The Openshift 4 installer for Azure creates all required infrastructure via terraform files. This allows for an automated deploy of the cluster and easy tear down. State files from the cluster will be stored in Azure storage.

Any prep work needed in Azure to create the cluster will be automated via the terraform files located here.

## Authentication 

The cluster will be set up to use GitHub Organizations as the identity provider. Details to be added in.