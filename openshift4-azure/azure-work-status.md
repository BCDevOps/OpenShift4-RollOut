An update on the current status of OpenShift on Azure from my perspective.

---

### IPI vs UPI OpenShift installer

I still think the IPI (Installer provisioned infrastructure) OCP 4 is the best way forward as it's very simple to get a cluster up and running in Azure and it's getting set up the way Red Hat has designed things to be set up.

With OCP 4.3 IPI we have the option to install into existing Azure VNets and set up a private OCP cluster so it's only accessible by connecting to the private network in Azure. These two options seem to satisfy BC Gov requirements.

If we take the UPI path we first need to wait until OCP 4.4 to be available (RH is saying end of March) to do the UPI install in Azure. We also need to spend about 2 weeks - 80 hours to write/update/test Terraform code to create the infrastructure in Azure and then install OCP into this infrastructure. This does give us the ability to customize more. 

The one sticking point with the BC Gov just seems to be the Resource Group that gets created with the IPI method doesn't fit the naming standard. Seems moot to me, and spending 2 weeks to build out automation just to address this issue seems over kill. 

---

I heard 2 concerns about OpenShift in Azure that are very valid and probably need to be fleshed out.

* Who's supporting the OpenShift platform and Infrastructure on Azure. If something is broken, who gets notified and fixes?
* From a security perspective if there was to be a security breach into OpenShift on Azure who would be investigating? What/where network and logs would need to be reviewed. 

---

BC Gov is wanting to have public access into the OpenShift Azure cluster through on-prem load balancers which doesn't seem very cloud like at all. I do see the concern with wanting to control public access but I think that can be handle on the Azure side.
Network services available inside Azure that can be set up to capture network traffic as well as Firewall services that can be set up to control access.

---

I've stopped working on OCP Azure tasks for the time being. All documentation and code is up to date and stored in this git repo. There are some handy diagrams and some costing info in the architecture document.
