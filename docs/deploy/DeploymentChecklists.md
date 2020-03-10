# Post-Cluster Install

Assumption is that all infrastructure requirements are in place and configured as required.  An initial cluster installation has been completed, but no post-install configuration has yet been done.

## Platform Setup

- [ ] Storage Pool Configuration (netapp-block-standard, netapp-file-standard)
- [ ] Registry configuration with storage (S3? NFS)
- [ ] Certificates for external endpoints (may require procurements)
- [ ] Service Catalog
  - [ ] *Samples* Operator (updater for openshift namespace templates and images)
  - [ ] *Template Service Broker*
  - [ ] *Ansible Service Broker* (do we want to deploy this?)
- [ ] Cluster Logging
- [ ] Cluster Monitoring
- [ ] Cluster Metering

## Platform OCP Configuration

- [ ] Restricted cluster RBAC
  - [ ] Cluster Admins, Cluster Viewers
  - [ ] BCDevExch Service account and "oc --as" permission setup
  - [ ] Restricted project/namespace creation
  - ... *more?*
- [ ] Quota Applier
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