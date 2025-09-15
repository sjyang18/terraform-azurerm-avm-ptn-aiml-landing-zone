variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

variable "location" {
  type        = string
  default     = "eastus2"
  description = <<DESCRIPTION
Azure region where all resources should be deployed.

This is set to eastus2 by default. Ensure the region has sufficient quotas for the resources.
DESCRIPTION
}