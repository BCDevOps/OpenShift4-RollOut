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


resource "azurerm_storage_container" "example" {
  name                  = var.metering
  resource_group_name   = "${azurerm_resource_group.example.name}"
  storage_account_name  = "${azurerm_storage_account.example.name}"
  container_access_type = "private"
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
      oc --kubeconfig ../install-config-dir/auth/kubeconfig patch ingresscontroller/default -n openshift-ingress-operator -p '{"spec":{"nodePlacement":{"nodeSelector":{"matchLabels":{"node-role.kubernetes.io/infra":""}}}}}' --type merge
      oc --kubeconfig ../install-config-dir/auth/kubeconfig patch config/cluster -p '{"spec":{"nodeSelector":{"node-role.kubernetes.io/infra":""}}}' --type merge
      oc --kubeconfig ../install-config-dir/auth/kubeconfig apply -f ../ocp4-config/cluster-monitoring-configmap.yaml
      echo "Deploy loggging"
      oc --kubeconfig ../install-config-dir/auth/kubeconfig apply -f ../ocp4-config/logging-preconfig.yaml
      oc --kubeconfig ../install-config-dir/auth/kubeconfig apply -f ../ocp4-config/logging-deploy.yaml
      echo "Setup project template"
      oc --kubeconfig ../install-config-dir/auth/kubeconfig -n openshift-config apply -f https://raw.githubusercontent.com/BCDevOps/openshift-tools/master/templates/default/project-request.json
      oc --kubeconfig ../install-config-dir/auth/kubeconfig patch project.config.openshift.io/cluster -p '{"spec":{"projectRequestTemplate":{"name":"project-request1"}}}' --type merge 
      EOT
  }
}


#Deploy metering stack
- install the operator 
oc --kubeconfig ../install-config-dir/auth/kubeconfig apply -f ../ocp4-config/metering-operator.yaml
- install config - uses storage container and key
oc --kubeconfig ../install-config-dir/auth/kubeconfig apply -f ../ocp4-config/metering-config.yaml
- add in reports
oc --kubeconfig ../install-config-dir/auth/kubeconfig apply -f ../ocp4-config/metering-reports.yaml


#oc get -o jsonpath='{.status.infrastructureName}{"\n"}' infrastructure cluster

#      echo "Rename default Azure StorageClass"
#      oc --kubeconfig ../install-config-dir/auth/kubeconfig 