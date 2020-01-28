resource "null_resource" "ocp4-post-install" {
  provisioner "local-exec" { 
    command = <<EOT
      oc --kubeconfig ../install-config-dir/auth/kubeconfig apply -f ../ocp4-config/azure-file-clusterrole.yaml
      oc --kubeconfig ../install-config-dir/auth/kubeconfig adm policy add-cluster-role-to-user system:azure-file system:serviceaccount:kube-system:persistent-volume-binder
      oc --kubeconfig ../install-config-dir/auth/kubeconfig apply -f ../ocp4-config/storageclass-azure-file.yaml
      EOT
  }
}

#get -o jsonpath='{.status.infrastructureName}{"\n"}' infrastructure cluster
#oc --kubeconfig ../install-config-dir/auth/kubeconfig apply -f infra-machineset.yaml
#oc --kubeconfig ../install-config-dir/auth/kubeconfig patch ingresscontroller/default -n openshift-ingress-operator -p '{"spec":{"nodePlacement":{"nodeSelector":{"matchLabels":{"node-role.kubernetes.io/infra":""}}}}}'
#  oc create -f cluster-monitoring-configmap.yaml


#oc patch --namespace=openshift-ingress-operator --patch='{"spec": {"replicas": 2}}' --type=merge ingresscontroller/<name>


#oc adm policy remove-cluster-role-from-group self-provisioner system:authenticated:oauth
#oc annotate clusterrolebinding.rbac self-provisioners 'rbac.authorization.kubernetes.io/autoupdate=false' --overwritecluster role "self-provisioner" removed: "system:authenticated:oauth"
#https://docs.openshift.com/container-platform/4.3/applications/projects/configuring-project-creation.html#disabling-project-self-provisioning_configuring-project-creation


#githunb config
#https://docs.openshift.com/container-platform/4.2/authentication/identity_providers/configuring-github-identity-provider.html

oc edit config/cluster

  nodeSelector:
    node-role.kubernetes.io/infra: ""




$ oc edit ClusterLogging instance

