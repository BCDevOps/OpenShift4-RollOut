# OpenShift 4 on Azure

[OCP 4 Azure Architecture doc](openshit4-azure-architecture.md)

## Azure Prep

A few items need to be in place in Azure before installing the cluster. Mainly a DNS zone and an Service Principal account. 

You will need the Tenant Administrator role in Azure AD to create the SP account

`az ad sp create-for-rbac --role Contributor --name ocp4lab-sp`

The service principal requires the legacy Azure Active Directory Graph → Application.ReadWrite.OwnedBy permission and the User Access Administrator role for the cluster to assign credentials for its components.

`az role assignment create --role "User Access Administrator" --assignee-object-id $(az ad sp list --filter "appId eq '<appId>'" | jq '.[0].objectId' -r)`

Approve the permissions request. If your account does not have the Azure Active Directory tenant administrator role, follow the guidelines for your organization to request that the tenant administrator approve your permissions request.

`az ad app permission add --id <appId> --api 00000002-0000-0000-c000-000000000000 --api-permissions 824c81eb-e3f8-4ee6-8f6d-de7f50d565b7=Role`

This may need to be done via the Azure web portal under the SP account and granting permission.

The `terraform/azure-prep` folder contains Terraform file and vars to deploy the needed DNS and create a KeyVault to store secrets. Update the vars file and run `terraform init && terraform apply` 

## Azure Resource Providers

Not a full list of needed enabled subscription resource providers but this one was disabled and needed to be enabled for the install to work.

* Microsoft.ManagedIdentity


### Azure KeyVault

An Azure KeyVault will be created to store secrets required for the OpenShift install. Secure information like node ssh keys, pull-secrets, and kubeadmin password will be stored here.

Push secrets to the key vault.

`az keyvault secret set --vault-name ocp4lab-kv --name ocp4lab-ssh-pub --encoding base64 --file ~/.ssh/key.pub`

Pull down the secret from the key vault.
 
`az keyvault secret download --vault-name ocp4lab-kv --name ocp4lab-ssh-pub --file ~/key.pub --encoding base64`

You will need to add Azure user to policies on the key vault to allow them to update or view secrets. This can be done via the UI or the az command.

`az keyvault set-policy --name ocp4lab-kv --upn shea.phillips_keystonesystems.ca#EXT#@bcgov.onmicrosoft.com --secret-permissions get list set delete --key-permissions create decrypt delete encrypt get list unwrapKey wrapKey`

## Deploy OCP 4 on Azure

* Update  in the details in `osServicePrincipal.json` to match the service principal set up in Azure for OCP4. Copy to `~/.azure` create directory if needed.

* Update `install-config.yaml` details, mainly the pull secret and ssh-key section

* Create an folder to use as the install directory for openshift-installer, copy `install-config.yaml` into this directory.

* Grab [OpenShift 4 installer](https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/) and extract to executable path directory.

* As some Azure resources providers are disabled we may need to add this environment variable before we kick off the install or it will error out. Detailed explanation [here].(https://www.terraform.io/docs/providers/azurerm/index.html#skip_provider_registration)
`export ARM_SKIP_PROVIDER_REGISTRATION=true`

* Run the installer `openshift-install create cluster --dir DIRECTORY_YOU_MADE/ --log-level debug`

* Destroy the installer `openshift-install destroy cluster --dir DIRECTORY_YOU_MADE/ --log-level debug`


## Configure OCP 4 on Azure

The post install configuration is handled with Ansible and Terraform using ocp config files in the `ocp4-config` directory.

`ansible-playbook -v azure-ocp4-postconfig.yml --extra-vars "github_oauth_secret=xxxx github_oauth_clientid=xxxx"`
