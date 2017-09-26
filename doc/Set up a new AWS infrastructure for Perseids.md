# Set up a new AWS infrastructure for Perseids

## Prerequisites

You will need:

* An AWS account
* An access key ID and secret access key to an AWS IAM account with the necessary privileges to create instances, etc (or the AWS root account)
* A copy of the Puppet repo and GPG secret key
* Control of the DNS domain you will be using for Perseids services (for example, `perseids.org`)

## Preparing your AWS account

All the metadata describing the AWS configuration lives in the `data/aws.yaml` file in the Puppet repo. It looks like this:

    ---
      aws::test_mode: false
      aws::region: 'us-east-1'
      aws::az: 'us-east-1d'
      aws::subnet: 'perseids_subnet'
      aws::securitygroup: 'open'
      aws::ips:
        www: '54.208.137.53'
        www-staging: '52.90.161.212'
      ...

### Setting the VPC name

First log in to the AWS web console and select the region. This is set in the `aws.yaml` file (`aws::region`). For `us-east-1`, for example, select the 'N. Virginia' region in the web interface.

In the AWS console, select 'VPC' from the Services menu, and then 'Your VPCs' in the left-hand pane.

If this is a new AWS account, only the default VPC will be shown, but it will have no name. Click in the 'Name' field and enter `perseids_vpc` (Puppet expects to manage AWS resources in the default VPC, but this needs to be named `perseids_vpc` in order for Puppet to find it.)

### Setting the subnet name

Now select 'Subnets' in the left-hand pane. There are several default subnets, one for each availability zone. Again this is set in the `aws.yaml` file, under `aws::az`. Select the subnet that corresponds to the chosen availability zone (for example, `us-east-1d`). Click in the 'Name' field and enter `perseids_subnet`.

### Allocating Elastic IPs

Each of the Perseids web services has a DNS name (for example `www.perseids.org`) which maps to the IP address of the server running that service. Because AWS IPs are assigned at random when new EC2 instances are created, we need to use Amazon's Elastic IP service. This allows you to request a static IP which can be associated with a particular server, and if you recreate the server, you can just change the Elastic IP mapping to point to the new instance.

To set up a new Perseids infrastructure we need to allocate a set of Elastic IPs, and then record these in the `aws.yaml` file. Here is what the list of IPs looks like:

    aws::ips:
      www: '54.208.137.53'
      www-staging: '52.90.161.212'
      annotation: '54.208.137.53'
      sosol: '54.208.136.52'
      sosol-test: '54.144.228.168'
      digmill: '54.208.136.84'
      bsp: '54.208.196.174'
      services: '54.209.128.64'
      ci: '54.164.139.219'
      collections: '54.87.146.18'
      monitor: '54.88.205.232'

Select 'EC2' from the 'Services' menu, then 'Elastic IPs' from the left pane. Click the 'Allocate new address' button, then click 'Allocate'. You will see a message like this:

    New address request succeeded
    Elastic IP 34.206.224.247

Copy this IP address and enter it as the value for `www` in the `aws.yaml` file, in the list shown above.

Repeat this process until you have allocated all the required Elastic IPs and entered them in the metadata file. You only need a new Elastic IP for each separate server that you are going to use; if you co-locate services on the same server, you can re-use the same IP address for the service. In the example above, `www` and `annotation` have the same IP address, as they are co-located on the same server.

### Setting up Route 53 DNS

In the `aws.yaml` file, find the section beginning `'route53_zone':`:

    'route53_zone':
      'perseidstest.org.':
        ensure: present
 
Change `perseidstest.org` to the domain that you will be using for Perseids services. In the `'route53_a_record'` section, change the DNS names to use this domain. For example:

    'route53_a_record':
      'perseidstest.org.':
        ensure: present
        zone: 'perseidstest.org.'
        ttl: 300
        values: "%{hiera('aws::ips.www')}"
 
Do the same in the `'route53_cname_record'` section.

### Creating a key pair

AWS requires a crypto key pair to be associated with each EC2 instance, so that you can log into it using the administrative account. To create this key pair, select 'EC2' from the 'Services' menu and then select 'Key Pairs' in the left pane.

Click 'Create Key Pair' and enter a suitable name (for example `perseids_key`). It doesn't matter what name you use, but once you have created the key pair, enter the name into the `aws.yaml` file, as the value for `key_name` for each EC2 instance. For example:

      'annotation-www':
        ...
        key_name: 'perseids_key'
        ...

You will not actually need to use the key pair, unless there are any problems with building a particular instance.

## Orchestrating the AWS resources

Now that you have done the manual steps to set up the AWS account, Puppet will take care of creating the various resources: EC2 instances, DNS records, Elastic IP mappings, and so on. In order to do this we need a server to run Puppet on. This can be any computer with Puppet installed, plus the AWS SDK and your account credentials.

If you have a server that you can manage with Puppet, then Puppet itself can set up the required configuration to orchestrate AWS resources. Have the server's manifest include the `aws_orchestrator` role:

    node 'orchestrator' {
      include site::roles::aws_orchestrator
    }

When you apply Puppet on the orchestrator server, it will connect to AWS and start creating the specified resources:

    Notice: Scope(Class[Site::Profiles::Aws_credentials]): AWS orchestration is using the LIVE credentials
    Notice: Compiled catalog for orchestrator.perseids.org in environment production in 1.84 seconds
    Notice: /Stage[main]/Site::Profiles::Aws_resources/Ec2_vpc_subnet[perseids_subnet]/map_public_ip_on_launch: map_public_ip_on_launch changed 'true' to 'false'
    Notice: /Stage[main]/Site::Profiles::Aws_resources/Ec2_instance[annotation-www]/ensure: changed absent to running
    Notice: /Stage[main]/Site::Profiles::Aws_resources/Rds_instance[perseidsmysql]/multi_az: multi_az changed 'false' to 'true'
    Notice: /Stage[main]/Site::Profiles::Aws_resources/S3_bucket[perseids_data_backups_test]/ensure: created
    Notice: /Stage[main]/Site::Profiles::Aws_resources/Ec2_elastic_ip[34.206.224.247]/ensure: ensure changed 'detached' to 'attached'
    Notice: /Stage[main]/Site::Profiles::Aws_resources/Route53_a_record[perseidstest.org.]/ensure: created
    Notice: /Stage[main]/Site::Profiles::Aws_resources/Route53_cname_record[www.perseidstest.org.]/ensure: created
    ...

## Bootstrapping servers

Once all the required EC2 instances have been created, which may take a few minutes, you can bootstrap them with Puppet using the 'Bootstrap new server with Puppet' procedure and associated documentation.
