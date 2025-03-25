variable "kube_config" {
  type        = string
  default     = "~/.kube/config"
  description = "path to kubernetes configuration."
}

variable "kube_context" {
  type        = string
  default     = "default"
  description = "path to kubernetes configuration."
}

variable "s3_access_key" {
  type        = string
  description = "s3 access key"
}

variable "s3_secret_key" {
  type        = string
  description = "s3 secret key"
}

variable "le_email" {
  type        = string
  description = "Let's Encrypt ACME E-Mail address"
}
