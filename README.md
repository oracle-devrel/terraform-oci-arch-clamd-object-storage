# terraform-oci-arch-clamd-object-storage

Low cost Antivirus for Oracle Cloud object store 

Improve security and maintain compliance by building a low cost antivirus to scan all your objects in a bucket and also scan an object when it is created using only an OCI instance and open source software.

You can store an unlimited amount of unstructured data of any content type in your internet-scale and high-performance object storage . You may want to run an antivirus to identify threats and then move those infected objects to another bucket called quarantine.

We are going to use Clamav open source antivirus engine for detecting trojans, viruses, malware and other malicious threats for this solution.

## Prerequisites

- Permission to `manage` the following types of resources in your Oracle Cloud Infrastructure tenancy: `vcns`, `internet-gateways`, `route-tables`, `security-lists`, `subnets`, `stream`, `stream-pull`, `stream-push`, and `instances`.

- Quota to create the following resources: 1 VCN, 1 subnet, 1 Internet Gateway, 1 route rule, 2 object store buckets, 1 Streaming Instance, 1 Event Service Rule, and 1 compute instances (Scan Instance).

If you don't have the required permissions and quota, contact your tenancy administrator. See [Policy Reference](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Reference/policyreference.htm), [Service Limits](https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/servicelimits.htm), [Compartment Quotas](https://docs.cloud.oracle.com/iaas/Content/General/Concepts/resourcequotas.htm).

## Deploy manually in the OCI Console

To setup this environment you need to have all the required privileges in the compartment or be part of an administrator group.

You can spin up your instance on a different **Compartment** and a new **Virtual Cloud Network** using a VCN Wizard or you can just start your instance on an existing subnet. 

We are going to use a new compartment called **Scan** and a new VCN using the Wizard. Besides that you'll need to setup the following resources:

### Compartment and VCN
Create a new compartment called **Scan** and annotate the compartment OCID. 
Create a VCN called **ScanVCN** using a VCN Wizard with internet connectivity. 

### Object Storage

1. Select a bucket with objects to scan and enable **Emit Object Events** on it or create a new bucket. Name: **checkinobj**
2. Create a standard bucket to move infected object to it. Name: **quarantine**

### Security 

3. Create a Dynamic Group with a rule that will qualify your instance. Name: **ScanDynGroup** Get the compartment_ocid to put in the Matching Rules.
``` 
All {instance.compartment.id = 'ocid1.compartment.oc1..aaaaaaaa......algq'} 
 ```
1. Create a policy to allow your Dynamic Group to manage objects. Name: **ScanPolicy** We are giving access in tenancy so you can scan any bucket.
```
Allow dynamic-group dyngroupscan to manage buckets in tenancy
Allow dynamic-group dyngroupscan to manage objects in tenancy
Allow dynamic-group dyngroupscan to manage stream-family in compartment Scan
Allow service objectstorage-sa-saopaulo-1 to manage object-family in tenancy
```
### Stream

5. Create a stream to receive event from object creation. Name **ScanStream**
for this component you need to annotate the streamID and endpoint 
```
streamingID = "ocid1.stream.oc1.sa-saopaulo-1.amaaaa......moxla"
endpoint = "https://cell-1.streaming.sa-saopaulo-1.oci.oraclecloud.com"
```
### Event
6. Create an event to track object create on bucket checkinobj and write to ScanStream. Name: **ScanEventRule**

### SSH Key pair 
7. Generate a ssh key par to use with your instance.

## Deploy Using Oracle Resource Manager

1. Click [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/oracle-devrel/terraform-oci-arch-clamd-object-storage/releases/latest/download/oci-arch-clamd-object-storage-stack-latest.zip)

    If you aren't already signed in, when prompted, enter the tenancy and user credentials.

2. Review and accept the terms and conditions.

3. Select the region where you want to deploy the stack.

4. Follow the on-screen prompts and instructions to create the stack.

5. After creating the stack, click **Terraform Actions**, and select **Plan**.

6. Wait for the job to be completed, and review the plan.

    To make any changes, return to the Stack Details page, click **Edit Stack**, and make the required changes. Then, run the **Plan** action again.

7. If no further changes are necessary, return to the Stack Details page, click **Terraform Actions**, and select **Apply**. 

## Deploy Using the Terraform CLI

### Clone the Module 

Now, you'll want a local copy of this repo. You can make that with the commands:
```
git clone https://github.com/oracle-devrel/terraform-oci-arch-clamd-object-storage
cd terraform-oci-arch-clamd-object-storage
ls
```
### Prerequisites
First off, you'll need to do some pre-deploy setup.  That's all detailed [here](https://github.com/cloud-partners/oci-prerequisites).

Secondly, create a `terraform.tfvars` file and populate with the following information:

```
# Authentication
tenancy_ocid       = "<tenancy_ocid>"
user_ocid          = "<user_ocid>"
fingerprint        = "<finger_print>"
private_key_path   = "<pem_private_key_path>"

# Region
region             = "<oci_region>"

# Compartment
compartment_ocid   = "<compartment_ocid>"

# AD
availability_domain_name = "<availability_domain_name>" # for example GrCH:US-ASHBURN-AD-1
```

### Create the Resources
Run the following commands:

    terraform init
    terraform plan
    terraform apply

### Destroy the Deployment
When you no longer need the deployment, you can run this command to destroy the resources:

    terraform destroy

## How to use with SCAN 

### To scan your bucket do the following:
1. Get a small python script called scan_bucket.py and run it to check for virus and move infected objects to quarantine.
```
wget https://raw.githubusercontent.com/oracle-quickstart/oci-arch-clamd-object-storage/main/scripts/scan_bucket.py
sudo python3 scan_bucket.py <your_bucket_name> quarantine
```

## How to use with PROTECT

### To protect your bucket scanning objects created on it do the following:
1. Get a small python script called scan_obj_create.py to check streaming and scan new objects.
   
   You need to provide source and target buckets and streaming OCID and endpoint that you can get from OCI console or terraform output
```
wget https://raw.githubusercontent.com/oracle-quickstart/oci-arch-clamd-object-storage/main/scripts/scan_obj_create.py
sudo python3 scan_obj_create.py checkinobj quarantine <stream_ocid> <stream_endpoint> 
```

## How to test with a fake threat

1. Copy this string to a file called EICAR_TEST.
```
X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*
```
2. Upload the file you just created to a bucket using the correct objects namespace.
```
oci os ns get --auth instance_principal
oci os object put -ns <namespace> -bn checkinobj --name infected_01.txt --file EICAR_TEST --auth instance_principal
```
3. Run the scripts to detect and move the infected objects to quarantine.

4. You can generate a test file with the python package we installed before doing the following as root user
```
python3
>>> import pyclamd
>>> cdsocket = pyclamd.ClamdUnixSocket()
>>> void = open('/root/EICAR_TEST','wb').write(cdsocket.EICAR())
```

## Roadmap and extensions 

1. Implement this solution with a different or commercial antivirus.  
2. Make the protect program a daemon to read the stream constantly.
3. Test for a bigger Unix socket size for the scan. Actually 1000MB
4. Send an alert e-mail when a threat is found. 
5. Implement error handling, timeout and a better python program.
6. Any great idea you may have.

## References

[Calling Services from an Instance:](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Tasks/callingservicesfrominstances.htm) \
[Managing Dynamic Groups:](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Tasks/managingdynamicgroups.htm) \
[Writing authorization policies for Dynamic Groups:](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Tasks/callingservicesfrominstances.htm#Writing) \
[OCI Command Line Interface (CLI):](https://docs.cloud.oracle.com/en-us/iaas/Content/API/Concepts/cliconcepts.htm) \
[CLI supported OS and Python versions:](https://docs.cloud.oracle.com/en-us/iaas/Content/API/Concepts/cliconcepts.htm#SupportedPythonVersionsandOperatingSystems) \
[OCI CLI Quick Start:](https://docs.cloud.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm) \
[Instance Principals:](https://blogs.oracle.com/cloud-infrastructure/announcing-instance-principals-for-identity-and-access-management)

## License

Clam AntiVirus is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

## Architecture Diagram
![](./images/oci-arch-clamd-object-storage.png)

## Reference Architecture

For details of the architecture, see [_Low cost antivirus for Object Storage_](https://docs.oracle.com/en/solutions/anti-virus/index.html)

## Attribution & Credits
Initially, this project was created and distributed in GitHub Oracle QuickStart space. For that reason, we would like to thank:
- Everson Forte (https://github.com/Everson4t)
- Flavio Pereira (https://github.com/flavio-santino)
- Lukasz Feldman (https://github.com/lfeldman)
- Fabio Silva and Fernando Costa who helped build this project

## License

Clam AntiVirus is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

Copyright (c) 2022 Oracle and/or its affiliates.
Licensed under the Universal Permissive License (UPL), Version 1.0
See [LICENSE](LICENSE) for more details.