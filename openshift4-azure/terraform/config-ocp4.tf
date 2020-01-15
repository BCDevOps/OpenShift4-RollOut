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