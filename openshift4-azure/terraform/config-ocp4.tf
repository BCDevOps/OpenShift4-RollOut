resource "azurerm_storage_account" "example" {
  name                     = "storageaccountname"
  resource_group_name      = "${azurerm_resource_group.example.name}"
  location                 = "${azurerm_resource_group.example.location}"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  enable_https_traffic_only = "true"

  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = ["${azurerm_subnet.example.id}"]
    bypass                     = AzureServices
  }

  tags = {
    environment = "staging"
  }
}

resource "null_resource" "ocp4-post-install" {
  provisioner "local-exec" { 
    command = <<EOT
      echo "Setting up Azure File StorageClass"
      oc --kubeconfig ../install-config-dir/auth/kubeconfig apply -f ../ocp4-config/azure-file-clusterrole.yaml
      oc --kubeconfig ../install-config-dir/auth/kubeconfig adm policy add-cluster-role-to-user system:azure-file system:serviceaccount:kube-system:persistent-volume-binder
      oc --kubeconfig ../install-config-dir/auth/kubeconfig apply -f ../ocp4-config/storageclass-azure-file.yaml
      echo "Setting up GitHub OAuth config"
      oc --kubeconfig ../install-config-dir/auth/kubeconfig create secret generic github-oatuh --from-literal=clientSecret=${var.clientsec} -n openshift-config
      oc --kubeconfig ../install-config-dir/auth/kubeconfig apply -f ../ocp4-config/github-oauth
      echo "Disabling project self-provisioning"
      oc --kubeconfig ../install-config-dir/auth/kubeconfig adm policy remove-cluster-role-from-group self-provisioner system:authenticated:oauth
      oc --kubeconfig ../install-config-dir/auth/kubeconfig annotate clusterrolebinding.rbac self-provisioners 'rbac.authorization.kubernetes.io/autoupdate=false' --overwritecluster role "self-provisioner" removed: "system:authenticated:oauth"
      echo "Deploy and set up infrastructure nodes"
      oc --kubeconfig ../install-config-dir/auth/kubeconfig apply -f ../ocp4-config/infra-machineset.yaml
      watch
      oc --kubeconfig ../install-config-dir/auth/kubeconfig patch ingresscontroller/default -n openshift-ingress-operator -p '{"spec":{"nodePlacement":{"nodeSelector":{"matchLabels":{"node-role.kubernetes.io/infra":""}}}}}'
      oc --kubeconfig ../install-config-dir/auth/kubeconfig patch config/cluster -p '{"spec":{"nodeSelector":{"node-role.kubernetes.io/infra":""}}}}}'
      oc --kubeconfig ../install-config-dir/auth/kubeconfig apply -f ../ocp4-config/cluster-monitoring-configmap.yaml
      echo "Deploy loggging"
      oc --kubeconfig ../install-config-dir/auth/kubeconfig apply -f ../ocp4-config/logging-preconfig.yaml
      oc --kubeconfig ../install-config-dir/auth/kubeconfig apply -f ../ocp4-config/logging-deploy.yaml
      EOT
  }
}

#oc get -o jsonpath='{.status.infrastructureName}{"\n"}' infrastructure cluster

#      echo "Rename default Azure StorageClass"
#      oc --kubeconfig ../install-config-dir/auth/kubeconfig 