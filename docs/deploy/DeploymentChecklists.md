# Post-Cluster Install

Assumption is that all infrastructure requirements are in place and configured as required.  An initial cluster installation has been completed, but no post-install configuration has yet been done.

## Platform Setup

**Host setup:**
- [x] idmapd.conf Set NFS Domain
- [x] iscsid.conf Set node.session.timeo.replacement_timeout = 5
- [x] Enable iscsid service
- [x] Enable multipathd service
- [x] initiatorname.iscsi Set InitiatorName
- [x] Set up other system configs
- [x] chrony.conf set NTP servers
- [x] Set vga=14c
- [ ] Basic Nagios monitoring
- [ ] Figure out Ignition for physicals/bonding
- [ ] Create DS for EnCase
- [ ] Create DS for lldptool
- [ ] Figure out how to do firmware patching
- [ ] Create something to configure iLO settings via API
- [ ] Create DS for HPE Tools (ie hard drive settings)

**Cluster setup:**
- [x] *Convert Infra nodes from workers to infras
  - [x] *Move cluster services to infra nodes
- [x] *Set up Trident configs
  - [x] *Set up Trident
  - [x] *Configure the SVM
  - [x] *Install tridentctl
  - [x] *Install Trident
  - [x] *Set up backends
  - [x] *Create storage classes
  - [x] *Storage Pool Configuration (netapp-block-standard, netapp-file-standard)
  - [x] Create new storage classes (flexvol direct volumes eg: netapp-block-extended, netapp-block-extended)
- [x] Scale registry to 3 infra nodes, add storage
  - [ ] *Registry configuration with object storage trial
  - [x] *Registry configuration with file storage (interim)
- [x] *Set up Aggregated Logging
- [x] *Add custom TLS certs for API and *.apps
- [x] *Set up GitHub authentication, delete default kubeadmin
- [x] *Configure F5 Controller
- [ ] *Configure Cluster Monitoring operator
- [ ] *ETCD Backup
- [ ] Cluster Metering(?)
- [ ] Rebuild OCP-Monitor checks

## Platform OCP Configuration

- [x] *Restricted cluster RBAC
  - [x] *Cluster Admins, Cluster Viewers
  - [x] *BCDevExch Service account and "oc --as" permission setup
  - [x] *Restricted project/namespace creation
  - ... *more?*
- [x] *Set default project template
- [ ] *Quota Applier
- [x] *Customize web console in LABs to add a banner
- [ ] *Service Catalog
  - [ ] *Samples* Operator (updater for openshift namespace templates and images)
  - [ ] **Template Service Broker
  - [ ] *Ansible Service Broker* (do we want to deploy this?)
- ... *more?*

## Licensed Platform Tools

- [ ] Sysdig
- [ ] Aporeto
  - [ ] Host protection mode
  - [ ] networksecuritypolicy operator
- [ ] Aqua
- [ ] Artifactory
  - [ ] Deploy
  - [ ] Operator(s)
  - [ ] replication?
- ... *more?*

## Feature additions

- [ ] Trident storage class for enterprise backup integrated volumes

