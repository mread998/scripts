# scripts
I'm not much of a programmer but i've fumbled together a few scripts that i'm consolidating into th is repo for my own convieance.

## Bash

The scripts in this subdirectory are intended to be useful for various
aspects of managing the infrastructure.

- [`linux-instance-hardening`](linux-instance-hardening) 
  * This was a project where I was trying to harden ec2 instnaces closer to match what   was running in Aws Gov-Cloud.  Using AWS Inspector we were able to greadly imporve the secruity footprint.

- [`get_ssh_key.sh`](get_ssh_key.sh)
  * Requires an AWS access key and secret to be configured, either as
    environment variables or by using the aws configure commandline.
  * Running the script creates a PuTTy key in user's home directory.
    Move it somewhere safe, typically in *$HOME/.ssh/*.
  - Use the PuTTy app to directly load and use this key to connect to
    the Pexip jump boxen.  -OR-
  - Use the PuTTyGen app to convert this key to an OpenSSH style key,
    and use OpenSSH (Git for Windows) or Windows' PowerShell ssh to
    connect.

- [`list-instances.sh`](list-instances.sh)
  * Requires an AWS access key and secret to be configured, either as
    environment variables or by using the aws configure commandline.

- [`generate-ec2-inventory.sh`](generate-ec2-inventory.sh)
  * Generate inventory of EC2 instances and relevant tag data.  
  * Creates a .csv file for each region - `--region us-east-2` and `--region us-west-2` in a S3.
  * Can be running as monthly cron job.

- [`generate-ec2-ipaddress.sh`](generate-ec2-ipaddress.sh)
  * Generate inventory of EC2 instances and their respective IP addresses for use in disaster recovery.
  * Creates a .csv file for each region - `--region us-east-2` and `--region us-west-2` in to a S3 bucket. 
  * can running as monthly cron job.

- [`generate-server-certificate-list.sh`](generate-server-certificate-list.sh)
  * Generates list of server certificates (aka TLS certs) loaded into
    IAM and used by various ALBs.
  * Creates a text file in the S3 bucket for vaec-automation.

## Python

- [`restore_instance_to_snapshot.py`](restore_instance_to_snapshot.py)
  * blah blah blah

## Powershell

- [`ad.ps1`](ad.ps1)
  * blah blah blah

- [`new-prox-core-setup.ps1`](new-prox-core-setup.ps1)
  * blah blah blah

- [`set-static-ip.ps1`](set-static-ip.ps1)
  * blah blah blah



