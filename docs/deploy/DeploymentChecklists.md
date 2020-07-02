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
- [ ] Basic Nagios monitoring [ZH](https://app.zenhub.com/workspaces/openshift-4-build-out-5db73142897668000144f22b/issues/bcdevops/openshift4-rollout/273)
- [ ] Figure out Ignition for physicals/bonding [ZH](https://app.zenhub.com/workspaces/openshift-4-build-out-5db73142897668000144f22b/issues/bcdevops/openshift4-rollout/37)
- [ ] Create DS for EnCase [ZH](https://app.zenhub.com/workspaces/openshift-4-build-out-5db73142897668000144f22b/issues/bcdevops/openshift4-rollout/221)
- [ ] Create DS for lldptool [ZH](https://app.zenhub.com/workspaces/openshift-4-build-out-5db73142897668000144f22b/issues/bcdevops/openshift4-rollout/224)
- [ ] Figure out how to do firmware patching [ZH](https://app.zenhub.com/workspaces/openshift-4-build-out-5db73142897668000144f22b/issues/bcdevops/openshift4-rollout/219)
- [ ] Create something to configure iLO settings via API [ZH](https://app.zenhub.com/workspaces/openshift-4-build-out-5db73142897668000144f22b/issues/bcdevops/openshift4-rollout/274)
- [ ] Create DS for HPE Tools (ie hard drive settings) [ZH](https://app.zenhub.com/workspaces/openshift-4-build-out-5db73142897668000144f22b/issues/bcdevops/openshift4-rollout/220)

**Cluster setup:**
- [x] Convert Infra nodes from workers to infras
  - [x] Move cluster services to infra nodes
- [x] Set up Trident configs
  - [x] Set up Trident
  - [x] Configure the SVM
  - [x] Install tridentctl
  - [x] Install Trident
  - [x] Set up backends
  - [x] Create storage classes
  - [x] Storage Pool Configuration (netapp-block-standard, netapp-file-standard)
  - [x] Create new storage classes (flexvol direct volumes eg: netapp-block-extended, netapp-block-extended)
- [x] Scale registry to 3 infra nodes, add storage
  - [ ] Registry configuration with object storage trial [ZH](https://app.zenhub.com/workspaces/openshift-4-build-out-5db73142897668000144f22b/issues/bcdevops/openshift4-rollout/202)
  - [x] Registry configuration with file storage (interim)
- [x] Set up Aggregated Logging
- [x] Add custom TLS certs for API and *.apps
- [x] Set up GitHub authentication, delete default kubeadmin
- [x] Configure F5 Controller
- [x] Configure Cluster Monitoring operator
- [ ] ETCD Backup [ZH](https://app.zenhub.com/workspaces/openshift-4-build-out-5db73142897668000144f22b/issues/bcdevops/openshift4-rollout/216)
- [x] Cluster Metering
- [ ] Rebuild OCP-Monitor checks [ZH](https://app.zenhub.com/workspaces/openshift-4-build-out-5db73142897668000144f22b/issues/bcdevops/openshift4-rollout/222)

## Platform OCP Configuration

- [x] Restricted cluster RBAC
  - [x] Cluster Admins, Cluster Viewers
  - [x] BCDevExch Service account and "oc --as" permission setup
  - [x] Restricted project/namespace creation
- [x] Set default project template
- [ ] Quota Applier (will be handled with Argo) [ZH](https://app.zenhub.com/workspaces/openshift-4-build-out-5db73142897668000144f22b/issues/bcdevops/openshift4-rollout/195)
- [x] Customize web console in LABs to add a banner

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

- [x] Trident storage class for enterprise backup integrated volumes

