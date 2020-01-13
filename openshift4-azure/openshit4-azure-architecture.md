# OpenShift 4 on Azure Readme

- [OpenShift 4 on Azure Readme](#openshift-4-on-azure-readme)
  - [Pre-req](#pre-req)
  - [Region](#region)
  - [Azure SP Account](#azure-sp-account)
  - [Subscription Info](#subscription-info)
  - [Node Details](#node-details)
  - [Networking](#networking)
    - [DNS](#dns)
  - [Cluster PV Storage](#cluster-pv-storage)
    - [Azure File](#azure-file)
      - [Resources:](#resources)
  - [Key Vault](#key-vault)
  - [Automation](#automation)
  - [Authentication](#authentication)
  - [SSL Certificates](#ssl-certificates)
  - [Costing](#costing)

## Pre-req

Microsoft.ManagedIdentity

not a full list of needed but this one was diabled and needed to be enabled.

## Region

If deploying to Canada Central or Canada East Azure regions there are no availability zone options. If a diaster occurred at one of these datacenters the OpenShift cluster would suffer an outage. Opposed to an Azure region that had multiple zones or locations.

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

INFRA NODES?!

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

A more detailed PV design will be determined at a later date. Azure Netapp Files is an option that can be looked at as well.

### Azure File

We create a storage account in Azure and specify this in the azure-file storage class so file storage can be dynamically created.

* Account Kind: StorageV2
* Performance: Standard 
* Replication: GRS
* Network: Public Endpoint (select the created ocp4 vnet & 2 subnets)
Note: This creates a publicly accessible storage service endpoints but locks down what networks can access it.
* Secure Transfer: Enabled

If we want to lock down the storage account to just the file service we can select Premium as the performance option. The issue is when using Premium the smallest size of the PV which relates to storage account quota is 100GB. Premium is priced on provisioned storage where standard is priced on used storage. Premium IO and network bandwidth limits scale with the provisioned share size.

In our azure-file storage class we set a value for secretNamespace parameter, as this is the namespace that stores the storage account keys in a secret. If not set the storage account credentials may be read by other users.

#### Resources:

* Pricing: https://azure.microsoft.com/en-us/pricing/details/storage/files/
* Storage Network Security: https://docs.microsoft.com/en-us/azure/storage/common/storage-network-security
* K8s azure-file SC info: https://kubernetes.io/docs/concepts/storage/storage-classes/#azure-file
* OCP manual Azure File: https://docs.openshift.com/container-platform/4.2/storage/persistent-storage/persistent-storage-azure-file.html
* OCP dynamic Azure File: https://docs.openshift.com/container-platform/4.2/storage/dynamic-provisioning.html#azure-file-definition_dynamic-provisioning
* Microsoft Docs K8s Azure File: https://docs.microsoft.com/en-us/azure/aks/azure-files-dynamic-pv

## Key Vault

An Azure KeyVault will be created to store secrets required for the OpenShift install. Secure information like node ssh keys, pull-secrets, and kubeadmin password will be stored here.

Push secrets to the key vault.

`az keyvault secret set --vault-name ocp4lab-kv --name ocp4lab-ssh-pub --encoding base64 --file ~/.ssh/key.pub`

Pull down the secret from the key vault.
 
`az keyvault secret download --vault-name ocp4lab-kv --name ocp4lab-ssh-pub --file ~/key.pub --encoding base64`

## Automation 

The Openshift 4 installer for Azure creates all required infrastructure via terraform files. This allows for an automated deploy of the cluster and easy tear down. State files from the cluster will be stored in Azure storage.

Any prep work needed in Azure to create the cluster will be automated via the terraform files located here.

## Authentication 

The cluster will be set up to use GitHub Organizations as the identity provider. Details to be added in.

Documentation here: https://docs.openshift.com/container-platform/4.2/authentication/identity_providers/configuring-github-identity-provider.html

We will need github oauth details for this step.

## SSL Certificates

## Costing

Put in cost estimations here.