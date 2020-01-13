# OpenShift 4 on Azure

[OCP 4 Azure Architecture doc](openshit4-azure-architecture.md)


## Deploy OCP 4 on Azure

* Update  in the details in `osServicePrincipal.json` to match the service principal set up in Azure for OCP4. Copy to `~/.azure` create directory if needed.

* Update `install-config.yaml` details, mainly the pull secret and ssh-key section

* Create an folder to use as the install directory for openshift-installer, copy `install-config.yaml` into this directory.

* Grab [OpenShift 4 installer](https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/) and extract to executable path directory.

* As some Azure resources providers are disabled we'll need to add this environment variable before we kick off the install or it will error out. Detailed explanation [here].(https://www.terraform.io/docs/providers/azurerm/index.html#skip_provider_registration)
`export ARM_SKIP_PROVIDER_REGISTRATION=true`

* Run the installer `openshift-install create cluster --dir DIRECTORY_YOU_MADE/ --log-level debug`


## Configure OCP 4 on Azure

### Add Azure File Storage

* Add the cluster role to access to create and view secrets:

    `oc apply -f azure-file-clusterrole.yaml`

* Add the role to the persistent-volume-binder account:

    `oc adm policy add-cluster-role-to-user system:azure-file system:serviceaccount:kube-system:persistent-volume-binder`

* Create the storage class:
    `oc apply -f storageclass-azure-file.yaml`
