# Make a Staging Instance of the SoSOL MySQL DB

In the AWS RDS Dashboard:

1. Select the perseidsmysql db instance
2. Choose Restore to Point in Time instance action and use Latest Restorable Time

    License Model: general-public-license
    DB Instance Class: db.m1.medium
    Multi-AZ Deployment: No
    Storage Type: Magnetic
    DB Instance Identifier: sosol-staging
    VPC: Not in VPC
    Availability Zone: us-east-1d

3. Launch Instance

After the instance is launched:

4. Edit the instance to change the security group to be `perseids-mysql-group`
5. Edit the perseids-mysql-group to add the ip address of the sosol staging server

