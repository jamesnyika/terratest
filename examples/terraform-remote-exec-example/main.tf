## we must provide at least 1 provider
   provider "aws" {

    ## pessimistic versioning
    ## the version of the provider to use: here >= 2.60.0 but < 2.61.0
    version = "~> 2.60.0"

    ## use a default profile
    profile = "default"

    # demonstrate use of variables for region
    region  = var.region
   }

   ## VPC - requirement
   resource aws_vpc "d_vpc" {
       #classless inter-domain routing block info
       cidr_block       = "10.0.0.0/16"

       # instance tenancy - another variable
       ## a variable indicating that multiple instances can run on one physical host. cheap option
       ## if you have an alternative requirement then you can set that
       ## BEWARE : If this is "dedicated" then you will get configuration not supported errors
       ## because that is only supported for larger more expensive instance types. Use "default"
       instance_tenancy = var.instance_tenancy

       ## we want dns and hostnames provided
       enable_dns_support = true
       enable_dns_hostnames = true

       #tags - - best practice
       tags = {
        Name = "TFDemo_VPC"
       }
   }

   ## Subnet - requirement
   resource aws_subnet "d_subnet" {
      #link the vpc in
      vpc_id = aws_vpc.d_vpc.id

      #address ranges
      cidr_block = "10.0.0.0/24"

      #give instances a public IP when you launch them
      map_public_ip_on_launch = true

      ## control availability zone: you can have multiple subnets IN an availability zone /logical DC
      availability_zone = "us-east-1a"

      #tags - best practice
       tags = {
        Name = "TFDemo_Subnet"
       }
   }

   ## Internet Gateway required if you want access to internet since 10.x.x.x are not internet routable
   resource aws_internet_gateway "d_igw" {
      #link the vpc in
      vpc_id = aws_vpc.d_vpc.id

      #tags - best practice
       tags = {
        Name = "TFDemo_InternetGateway"
       }
   }


   ## We need a route table to tie the subnet(s) to
   resource aws_route_table "d_route_table" {
      #link the vpc in
      vpc_id = aws_vpc.d_vpc.id

      ## the route - all non 10.x ips must be routed through the internet gateway
      route {
          #take all non vpc IPs...and
          cidr_block = "0.0.0.0/0"
          ##route through our internet gateway
          gateway_id = aws_internet_gateway.d_igw.id
      }

      #tags - best practice
       tags = {
        Name = "TFDemo_RouteTable"
       }
   }

   ## Associations
   resource "aws_route_table_association" "d_route_association" {
       # ties together subnet and route table
       # subnet
       subnet_id = aws_subnet.d_subnet.id

       # route table
       route_table_id = aws_route_table.d_route_table.id

       ## unfortunately - tags are not valid in this resource
   }


   ## Security Group  - like a firewall but managed in AWS
   resource aws_security_group "allow-ssh"{
     #link the vpc in
      vpc_id = aws_vpc.d_vpc.id

     # name it
     name = "allow-ssh"

     # custom security group/firewall to allow ssh in from MY ip address
     description  = "Allow ssh from my IP only "

     # define outgoing rules: allow all traffic out from all ports
     egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
     }

     # define incoming rules: Allow traffic from any address but only over port 22
     ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        ## notice : plural spelling
        cidr_blocks = ["0.0.0.0/0"]
     }

     ## tagging
        tags = {
           Name = "TFDemo_AllowSSH_SecurityGroup"
       }
   }

   ## SSH Keys
   resource aws_key_pair "d_keypair" {
      # name of the keypair..we use the same
      key_name = "d_keypair"

      ## reference your public key : NEVER UPLOAD PRIVATE KEY
      public_key = var.ssh_pub_key
   }

   # EC2 - requirement
    resource aws_instance "dec2_nginx" {
        #use profiles to simplify settings applied
        # ami           = "ami-043d56c674f1526d6" ## already has NGINX on it running
        ami = "ami-b374d5a5"
        instance_type = "t2.micro"

        ## tie to the correct subnet
        subnet_id = aws_subnet.d_subnet.id

        ## Security group - one or more. We want to be able to ssh into the box
        vpc_security_group_ids = [aws_security_group.allow-ssh.id]

        ## for ssh access
        key_name = aws_key_pair.d_keypair.key_name


       ## dump out ip to a text file
        provisioner "local-exec" {
          command = "echo ${aws_instance.dec2_nginx.public_ip} > ip_address.txt"
        }

        ## dump out ip to a text file
        provisioner "remote-exec" {
        inline = ["echo ${aws_instance.dec2_nginx.public_ip} > ip_address.txt",]
        }

       ## tagging
        tags = {
           Name = "TFDemo_EC2 Instance"
       }
    }
