# OpenShift 4 on Azure Readme

- [OpenShift 4 on Azure Readme](#openshift-4-on-azure-readme)
  - [Region](#region)
  - [Azure SP Account](#azure-sp-account)
  - [Node Details](#node-details)
    - [Infrastructure nodes](#infrastructure-nodes)
  - [Subscription Info](#subscription-info)
    - [Subscription Count](#subscription-count)
  - [Networking](#networking)
    - [DNS](#dns)
  - [Cluster PV Storage](#cluster-pv-storage)
    - [Azure File](#azure-file)
      - [Resources:](#resources)
  - [Logging Stack](#logging-stack)
  - [Authentication](#authentication)
  - [SSL Certificates](#ssl-certificates)
  - [Costing](#costing)
  - [Metering](#metering)


## Region

If deploying to Canada Central or Canada East Azure regions there are no availability zone options. If a diaster occurred at one of these datacenters the OpenShift cluster would suffer an outage. Opposed to an Azure region that had multiple zones or locations.

## Azure SP Account

Because OpenShift Container Platform and its installation program must create Microsoft Azure resources, we must create a service principal to represent it.

The SP account will need to be created in the Azure AD associated to the subscription where OCP 4 will be installed. You will need the Tenant Administrator role in Azure AD to create the SP account. Details on creating this account are listed in the [OpenShift Documentation](https://docs.openshift.com/container-platform/4.2/installing/installing_azure/installing-azure-account.html#installation-azure-service-principal_installing-azure-account)


## Node Details

The install will start with 3 Master nodes and 3 worker nodes. This can be grown by updating machine-set replica numbers inside the cluster. 3 Infrastructure nodes will be deployed after the cluster is up and Infrastructure cluster components moved to these nodes.

### Infrastructure nodes

Infrastructure nodes are not counted toward the total number of subscriptions that are required to run the environment. The following OpenShift Container Platform components are infrastructure components:

* Kubernetes and OpenShift Container Platform control plane services that run on masters
* The default router
* The container image registry
* The cluster metrics collection, or monitoring service
* Cluster aggregated logging
* Service brokers

Any node that runs any other container, pod, or component is a worker node that your subscription must cover.

The Azure `Standard_D4s_v3` machine type will be used for all six nodes.


| Size | vCPU | Memory: GiB | Temp storage (SSD) GiB | Max data disks | Max cached and temp storage throughput: IOPS / MBps (cache size in GiB) | Max uncached disk throughput: IOPS / MBps | Max NICs / Expected network bandwidth (Mbps) |
|-----------------|------|-------------|------------------------|----------------|-------------------------------------------------------------------------|-------------------------------------------|----------------------------------------------|
| **Standard_D4s_v3** | 4 | 16 | 32 | 8 | 8000 / 64 (100) | 6400 / 96 | 2 / 2000 |
| Standard_D8s_v3 | 8 | 32 | 64 | 16 | 16000 / 128 (200) | 12800 / 192 | 4 / 4000 |
|  |  |  |  |  |  | |  |
| **Count/Totals:**   9 VMs | 36 | 144 | 32 | 9 x 128GB SSD Disk = 1.15TB  |  |  |

The nodes will receive 1 OS disks with 128GB of storage. This is around the recommended minimum disk sizes. A better disk and partition scheme will be determined at a later date so we are not relying on a single disk.

## Subscription Info

We will need a pull secret to give to the Openshift 4 installer. The pull secret can be obtained here: https://cloud.redhat.com/openshift/install/pull-secret after logging in with a Red Hat account.

When the cluster first comes up it will default to a 60 day evaluation. This will be fine as we plan to destroy and re-create. Once the cluster is up is a steady permanent state we will need to assign subscriptions to it via Red Hat portal. 

### Subscription Count

The worker nodes will be the only nodes needing an Red Hat OpenShift Subscription. Based on numbers above we will need `6` to start with.

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

## Logging Stack

## Authentication 

The cluster will be set up to use GitHub Organizations as the identity provider. Details to be added in.

Documentation here: https://docs.openshift.com/container-platform/4.2/authentication/identity_providers/configuring-github-identity-provider.html

We will need github oauth details for this step.

## SSL Certificates

## Costing

Put in cost estimations here.

## Metering

https://itnext.io/operator-metering-with-look-back-kubernetes-reports-85d6b86b1e3c

https://github.com/operator-framework/operator-metering