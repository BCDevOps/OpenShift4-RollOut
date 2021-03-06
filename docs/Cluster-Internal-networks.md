# Cluster Internal Network design

This document contains the information used to decide whether to provision separate (unique) networks for each OpenShift 4 cluster.  The current design requires public IP addresses at the F5 ingress/egress points for each cluster, and private IP addresses for the rest of the networks.  The decision in question is whether we can re-use the same private network ranges for multiple clusters.  This decision supports critical cluster network components, which if changed, would require a full re-installation of a given cluster.

## Background

With each OpenShift cluster, internal networks are used for in-cluster communications.  These networks are private networks that rely on ingress and egress Network Address Translation.  If a network does not require external direct routing/exposure, then we can save on IP network reservations by re-using these private networks.  The following networks are the potential private networks for OCP 4:

- Host/Node Network - primary physical interface for each physical host in a cluster (outgoing NAT IP address for all pods on a node)
- Storage Network - connecting NAS storage (NetApp) to each of the hosts within a cluster.
- Pod Network - IP addresses assigned to each pod.
- Service Network - IP addresses assigned to services.

## Network usage

### Host/Node Network

Host IP addresses are used to NAT each hosted PODs outgoing traffic, as well as host specific node/cluster related services.  Incoming application traffic will not be directed at a host IP address.  While we are planning to use outgoing NAT on the F5, there may be situations in the future where we need to be able to direct route to these host IP addresses from other BC Gov networks (eg: future Aporeto design potential for bridging zone access may need route-able endpoints).

Changing the Host/Node network in the future would require a full cluster rebuild or migration.

A private and route-able Host/Node network for each cluster is recommended.

### Storage Network

This network will be leveraged for high speed communication between the NetApp appliance and the cluster Hosts/Nodes.  No other access is planned for a cluster's storage network, storage is not shared between clusters, and backup service integration will leverage a separate backup interface as determined by the hosting service.

A private and non-routable Storage network for each cluster is recommended.

### Cluster Pod and Service Networks

These networks are used by internal pod-pod communication while external cluster access (both incoming and outgoing) is routed through the host/node IP address or a routed ingress IP.  This makes these networks good candidates for re-using network ranges.

A known technology that will be impacted by this decision is the Istio Service Mesh implementation.  The internal pod and service networks are used for service discovery within a Mesh backplane.  One design for a multi-cluster deployment uses a single (shared) Istio backplane.  This design requires uniquely identifiable pod endpoints.  A second design uses separate Istio backplanes for each cluster, and replication between backplanes provides cross-cluster service discovery.  This design would NOT require uniquely identifiable pod endpoints between clusters.

Choosing to re-use the internal cluster networks (for pods and services) will remove the option to stretch an Istio Backplane across multiple clusters.  Requesting additional private networks for each production cluster will require requests for reserved network ranges from hosting services.

The current production architecture defines a *Silver* platform that includes a single cluster, and *Gold* platform that is made up of 2 clusters in separate physical regions.

## Recommendation

Leverage private non-routable cluster pod/service networks within each region.  This would enable the possibility for a single Istio Backplane across the Gold clusters in the future, while not demanding separate non-routable pod/service networks in every cluster.

Diagram to illustrate use of unique pod/service networks:

![Unique Networks](images/Internal-Network-Usage.png)

## Network Sizing

A brief note to highlight recommended sizing for the networks described above:

Host/Node Networks - The size recommended for a production environment is a `/25` network to allow for ~120 nodes in a cluster.  The size for a lab cluster can be shrunk to a `/26` or possibly a `/27`.  The Lab clusters are also much easier to re-deploy without production impact.

Storage Networks - The size recommended for a storage network should match the above Host/Node network size.

Internal Pod/Service Networks - The size recommended for a production environment is a `/16` for each of these networks.  This follows the Redhat Guidelines for sizing internal networks found here: <https://docs.openshift.com/container-platform/4.4/installing/installing_bare_metal/installing-bare-metal.html#installation-bare-metal-config-yaml_installing-bare-metal>

