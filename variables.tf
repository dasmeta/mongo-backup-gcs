variable "mongodb_host" {
  type    = string
  default = "host"
}

variable "mongodb_port" {
  type    = string
  default = "port"
}

variable "mongodb_uri" {
  type    = string
  default = "mongodb://username:password@host/database?replicaSet=rs0"
}

variable "mongo_initdb_root_username" {
  type    = string
  default = "user"
}

variable "mongo_initdb_root_password" {
  type    = string
  default = "password"
}

variable "google_storage" {
  type    = string
  default = "mongo-backup"
}

variable "max_backups" {
  type    = string
  default = "30"
}

variable "cron_time" {
  type    = string
  default = "*/3 * * * *"
}

variable "init_backup" {
  type    = string
  default = "false"
}

variable "init_restore" {
  type    = string
  default = "false"
}

variable "run_as_daemon" {
  type    = string
  default = "false"
}

variable "google_service_account_json" {
  type = any
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "storage_class" {
  type    = string
  default = "local-storage"
}

variable "storage_size" {
  type    = string
  default = "8Gi"
}
