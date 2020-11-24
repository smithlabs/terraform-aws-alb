# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "elb_name" {
  description = "The name of the ELB and all its resources"
  type        = string
  default     = "smithlabs-elb-default"
}
