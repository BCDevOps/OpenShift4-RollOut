# DNS design for multi-cluster deployments

Individual Cluster DNS is expected to be used for dev/test functions during the initial development of an application.  Once an application is ready to deploy a production version the expectation is that an application specific vanity domain will be created.  An example vanity domain is developer.gov.bc.ca.  This domain will be used for all published platform service applications (eg: chat.developer.gov.bc.ca, sso.developer.gov.bc.ca, etc)

## Individual Cluster DNS

Each individual cluster will have it's own domain within the devops.gov.bc.ca base domain.

Base Domain: devops.gov.bc.ca

![Cluster DNS design](../images/design-cluster-dns-01.png)

- cluster_name: pacific (kprod) | salish (cprod) | cowichan (klab) | thetis (clab) | clearwater (Azure services) | fraser (New pathfinder)
- Cluster ID: <cluster_name>.devops.gov.bc.ca
- Cluster API: api.<cluster_name>.devops.gov.bc.ca
- App wildcard: *.apps.<cluster_name>.devops.gov.bc.ca

example test application URL: helloworld.apps.<cluster_name>.devops.gov.bc.ca

### Naming for Azure clusters

The <base_domain>s for the azure clusters will be devops.gov.bc.ca, and each cluster subdomain will be delegated to the azure DNS service.

#### Platform Services Cluster

This cluster is targeted to host the platform services that provide services to production clusters.

- Cluster ID: clearwater.devops.gov.bc.ca
- Cluster API: api.clearwater.devops.gov.bc.ca
- App wildcard: *.apps.clearwater.devops.gov.bc.ca
- Additional wildcard: *.developer.gov.bc.ca

example: chat.developer.gov.bc.ca

#### Pathfinder Cluster

This will become the new pathfinder cluster to explore new technologies.

- Cluster ID: fraser.devops.gov.bc.ca
- Cluster API: api.fraser.devops.gov.bc.ca
- App wildcard: *.apps.fraser.devops.gov.bc.ca
- Additional wildcard: *.pathfinder.devops.gov.bc.ca

example: coolapp.pathfinder.devops.gov.bc.ca

## BigIP DNS

Each public DNS for an application can be assigned an external IP address (a BigIP) at the GTM layer.  This will load balance between LTM pools for each application.  Currently this will load-balance with an active/passive (Kamloops/Calgary) approach that will only direct traffic to the Calgary cluster when the Kamloops service is unavailable.  The BigIP DNS will also be the primary target for all other multi-cluster application deployments as well.  (load balancing between an on-prem cluster an an Azure hosted cluster for example.)