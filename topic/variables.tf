# Confluent cloud environment id  
variable "environment" {
  type = string
}

# Confluent cloud cluster id  
variable "cluster" {
  type = string
}


variable "producer_sa_name" {
  type = string
}

variable "consumer_sa_name" {
  type = string
}



# RBAC enabled */
variable "rbac_enabled" {
  type = bool
}

# Topic definition list 
variable "topic" {
  type = object({
    name     = string
    partitions = number
    config   =  map(string)
    consumer = optional(string)
    producer = optional(string)
  })
}

# Service Account Credentials to create the topic ( requires a lower RBAC)
variable "admin_sa" {
  type = object({
    id     = string
    secret = string
  })
}

