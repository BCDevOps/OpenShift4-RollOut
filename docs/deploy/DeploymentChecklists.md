# Post-Cluster Install

Assumption is that all infrastructure requirements are in place and configured as required.  An initial cluster installation has been completed, but no post-install configuration has yet been done.

## Platform Setup

**Host setup:**
- [ ] idmapd.conf Set NFS Domain
- [ ] iscsid.conf Set node.session.timeo.replacement_timeout = 5
- [ ] Enable iscsid service
- [ ] Enable multipathd service
- [ ] initiatorname.iscsi Set InitiatorName
- [ ] Set up other system configs
- [ ] chrony.conf set NTP servers
- [ ] Set vga=14c
- [ ] Basic Nagios monitoring
- [ ] Figure out Ignition for physicals/bonding
- [ ] Create DS for EnCase
- [ ] Create DS for lldptool
- [ ] Figure out how to do firmware patching
- [ ] Create something to configure iLO settings via API
- [ ] Create DS for HPE Tools (ie hard drive settings)

**Cluster setup:**
- [ ] *Convert Infra nodes from workers to infras
  - [ ] *Move cluster services to infra nodes
- [ ] *Set up Trident configs
  - [ ] *Set up Trident
  - [ ] *Configure the SVM
  - [ ] *Install tridentctl
  - [ ] *Install Trident
  - [ ] *Set up backends
  - [ ] *Create storage classes
  - [ ] *Storage Pool Configuration (netapp-block-standard, netapp-file-standard)
  - [ ] Create new storage classes (flexvol direct volumes eg: netapp-block-extended, netapp-block-extended)
- [ ] Scale registry to 3 infra nodes, add storage
  - [ ] *Registry configuration with object storage trial
  - [ ] *Registry configuration with block storage (interim)
- [ ] *Set up Aggregated Logging
- [ ] *Add custom TLS certs for API and *.apps
- [ ] *Set up GitHub authentication, delete default kubeadmin
- [ ] *Configure F5 Controller
- [ ] *Configure Cluster Monitoring operator
- [ ] *ETCD Backup
- [ ] Cluster Metering(?)
- [ ] Rebuild OCP-Monitor checks

## Platform OCP Configuration

- [ ] *Restricted cluster RBAC
  - [ ] *Cluster Admins, Cluster Viewers
  - [ ] *BCDevExch Service account and "oc --as" permission setup
  - [ ] *Restricted project/namespace creation
  - ... *more?*
- [ ] *Set default project template
- [ ] *Quota Applier
- [ ] *Customize web console in LABs to add a banner
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

