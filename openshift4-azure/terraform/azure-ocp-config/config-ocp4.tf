data "azurerm_subnet" "master_subnet" {
  name                 = "ocp4lab-mbtr9-master-subnet"
  virtual_network_name = "ocp4lab-mbtr9-vnet"
  resource_group_name  = var.rg_name
}

data "azurerm_subnet" "worker_subnet" {
  name                 = "ocp4lab-mbtr9-worker-subnet"
  virtual_network_name = "ocp4lab-mbtr9-vnet"
  resource_group_name  = var.rg_name
}

resource "azurerm_storage_account" "ocp4labpv" {
  name                      = var.stor_account_name
  resource_group_name       = var.rg_name
  location                  = var.location
  account_tier              = var.account_tier
  account_replication_type  = var.replication_teir
  enable_https_traffic_only = var.https_traffic

  # network_rules {
  #   default_action             = "Deny"
  #   bypass                     = ["AzureServices"]
  #   virtual_network_subnet_ids = [
  #     data.azurerm_subnet.master_subnet.id,
  #     data.azurerm_subnet.worker_subnet.id,
  #   ]
  # }

  tags = {
    environment = var.tag
  }
}


resource "azurerm_storage_container" "example" {
 name                  = var.metering_name
 resource_group_name   = var.rg_name
 storage_account_name  = azurerm_storage_account.ocp4labpv.name
 container_access_type = "private"
}

# resource "null_resource" "ocp4-post-install" {
#   provisioner "local-exec" { 
#     command = <<EOT
#       echo "Setting up Azure File StorageClass"
#       oc --kubeconfig ../install-dir/auth/kubeconfig apply -f ../ocp4-config/azure-file-clusterrole.yaml
#       oc --kubeconfig ../install-dir/auth/kubeconfig adm policy add-cluster-role-to-user system:azure-file system:serviceaccount:kube-system:persistent-volume-binder
#       oc --kubeconfig ../install-dir/auth/kubeconfig apply -f ../ocp4-config/storageclass-azure-file.yaml
#       echo "Setting up GitHub OAuth config"
#       oc --kubeconfig ../install-dir/auth/kubeconfig create secret generic github-oatuh --from-literal=clientSecret=${var.clientsec} -n openshift-config
#       oc --kubeconfig ../install-dir/auth/kubeconfig apply -f ../ocp4-config/github-oauth.yaml
#       echo "Disabling project self-provisioning"
#       oc --kubeconfig ../install-dir/auth/kubeconfig adm policy remove-cluster-role-from-group self-provisioner system:authenticated:oauth
#       oc --kubeconfig ../install-dir/auth/kubeconfig annotate clusterrolebinding.rbac self-provisioners 'rbac.authorization.kubernetes.io/autoupdate=false' --overwritecluster role "self-provisioner" removed: "system:authenticated:oauth"
#       echo "Deploy and set up infrastructure nodes"
#       oc --kubeconfig ../install-dir/auth/kubeconfig apply -f ../ocp4-config/infra-machineset.yaml
#       watch
#       oc --kubeconfig ../install-dir/auth/kubeconfig patch ingresscontroller/default -n openshift-ingress-operator -p '{"spec":{"nodePlacement":{"nodeSelector":{"matchLabels":{"node-role.kubernetes.io/infra":""}}}}}' --type merge
#       oc --kubeconfig ../install-dir/auth/kubeconfig patch config/cluster -p '{"spec":{"nodeSelector":{"node-role.kubernetes.io/infra":""}}}' --type merge
#       oc --kubeconfig ../install-dir/auth/kubeconfig apply -f ../ocp4-config/cluster-monitoring-configmap.yaml
#       echo "Deploy loggging"
#       oc --kubeconfig ../install-dir/auth/kubeconfig apply -f ../ocp4-config/logging-preconfig.yaml
#       oc --kubeconfig ../install-dir/auth/kubeconfig apply -f ../ocp4-config/logging-deploy.yaml
#       echo "Setup project template"
#       oc --kubeconfig ../install-dir/auth/kubeconfig -n openshift-config apply -f https://raw.githubusercontent.com/BCDevOps/openshift-tools/master/templates/default/project-request.json
#       oc --kubeconfig ../install-dir/auth/kubeconfig patch project.config.openshift.io/cluster -p '{"spec":{"projectRequestTemplate":{"name":"project-request"}}}' --type merge 
#       EOT
#   }
# }

# # oc --kubeconfig ../install-dir/auth/kubeconfig get machineset ocp4lab-mbtr9-infra-canadacentral -n openshift-machine-api | awk 'NR>1 {print $4}'

# # - name: wait for {{ inventory_hostname }} to be ready
# #   shell: oc get nodes {{ inventory_hostname }} | awk 'NR>1 {print $2}'
# #   register: result
# #   until: result.stdout == "Ready,SchedulingDisabled"
# #   retries: 40
# #   delay: 15
# #   delegate_to: localhost


# #Deploy metering stack
# - install the operator 
# oc --kubeconfig ../install-config-dir/auth/kubeconfig apply -f ../ocp4-config/metering-operator.yaml
# - install config - uses storage container and key
# oc --kubeconfig ../install-config-dir/auth/kubeconfig apply -f ../ocp4-config/metering-config.yaml
# - add in reports
# oc --kubeconfig ../install-config-dir/auth/kubeconfig apply -f ../ocp4-config/metering-reports.yaml


# #oc get -o jsonpath='{.status.infrastructureName}{"\n"}' infrastructure cluster

# #      echo "Rename default Azure StorageClass"
# #      oc --kubeconfig ../install-config-dir/auth/kubeconfig 