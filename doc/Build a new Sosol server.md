# Build a new Sosol server

Although building most Perseids servers is simply a matter of creating a suitable EC2 instance and bootstrapping it with Puppet, there is an extra step for the Sosol server, because it requires a collection of Git repos to be present. Part of the procedure for building this server, therefore, is to restore the Git data from S3 backup.

## Back up current data

If there is an existing Sosol instance, the Git data may have been updated since the previous night's backup. If so, run a manual backup on the existing instance so that we have the latest changes.

On the existing Sosol instance:

1. Sudo to root

1. Lock Puppet and stop Tomcat:

        plock Running backup
        service tomcat6 stop
        
1. Start the backup process:

        duplicity_backup git /mnt/data/gitrepo/data
        
While the backup is running, you can start preparing the new Sosol instance.

## Prepare Sosol instance

1. Edit the AWS metadata file (`data/aws.yaml`) to add a new instance in the `aws::resources` section under `ec2_instance` with the following attributes:

      'sosol':
        ensure: 'running'
        region: "%{hiera('aws::region')}"
        subnet: "%{hiera('aws::subnet')}"
        security_groups: "%{hiera('aws::securitygroup')}"
        image_id: 'ami-2d39803a'
        instance_type: 'c3.2xlarge'
        associate_public_ip_address: true
        key_name: 'perseidskey'
        block_devices:
          - device_name: '/dev/sda1'
            volume_size: 50
          - device_name: '/dev/sdf'
            volume_size: 50

1. Commit and push this change, and either run Puppet manually on the AWS orchestration server (`monitor`) or wait a few minutes for it to auto-run. The new instance should appear in the AWS control panel.

## Format data volume

1. __As root__ on the server (`ssh -i /path/to/perseidskey.pem ubuntu@ipaddress`), create a filesystem on the data device:

        mkfs.ext4 -i 4096 /dev/xvdf

   Note that if the device name specified in the AWS metadata is `/dev/sdf`, the equivalent Linux device name will be `/dev/xvdf`. You can verify this using `lsblk` (for more info see [AWS Docs](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-using-volumes.html)) 
       
## Bootstrap the instance

1. Configure the server using the `rake bootstrap` task as detailed in the 'Bootstrap new server with Puppet' procedure. 

        rake CLIENT=<ipaddress> HOSTNAME=sosol PERSEIDS_ENV=<production|staging|development> bootstrap 

## Restore Git data

Once the bootstrap procedure has finished, follow these steps to restore the Git backup.

1. sudo to root

1. Check that the data volume is correctly mounted:

        mount |grep data
        /dev/xvdf on /mnt/data type ext4 (rw,noatime,_netdev)

1. Create the `gitrepo` directory:

        mkdir /mnt/data/gitrepo
        chown tomcat6:tomcat6 /mnt/data/gitrepo
        
1. Start the restore job:

        duplicity_restore git /mnt/data/gitrepo/data
        
    This will probably take about 45 minutes to run. Once it's completed, check the repos under `/mnt/data/gitrepo/data` to make sure everything has been restored correctly.
    
## Update Elastic IP

1. In the AWS console, go to 'Elastic IPs'. If the address `54.208.136.52` is associated with an existing instance, deassociate it.

1. Associate the address `54.208.136.52` with the new Sosol instance.

## Shut down old instance

If there is a previous instance of the Sosol server still running, shut it down (for one thing, it would otherwise overwrite the new backups with obsolete data).
