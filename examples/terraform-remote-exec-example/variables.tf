# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "ssh_pub_key" {
  description = "A public ssh key - NOT private"
}

variable "ssh_priv_key" {
  description = "A private key to log in with"
}

variable "instance_tenancy" {
  description = "Instance Tenancy"
  type        = string
}

variable "region" {
  description = "The AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}
