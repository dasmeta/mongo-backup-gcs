provider "helm" {
  kubernetes {
    config_path = pathexpand("~/.kube/config_ncet")
  }
}

module "release" {
  source  = "terraform-module/release/helm"
  version = "2.6.0"

  namespace  = "default"
  repository = "https://charts.helm.sh/stable"

  app = {
    name          = "mongodb-backup"
    version       = "0.1.0"
    chart         = "${path.module}/helm/mongodb-backup-gcloud"
    force_update  = true
    wait          = false
    recreate_pods = false
    deploy        = 1
  }

  values = []

  set = [
    {
      name  = "google_service_account_json"
      value = "${var.google_service_account_json}"

    },
    {
      name  = "config.MONGODB_HOST"
      value = "${var.mongodb_host}"
    },
    {
      name  = "config.MONGODB_PORT"
      value = "${var.mongodb_port}"
    },
    {
      name  = "config.MONGODB_URI"
      value = "${var.mongodb_uri}"
    },
    {
      name  = "config.MONGO_INITDB_ROOT_USERNAME"
      value = "${var.mongo_initdb_root_username}"
    },
    {
      name  = "config.MONGO_INITDB_ROOT_PASSWORD"
      value = "${var.mongo_initdb_root_password}"
    },
    {
      name  = "config.GOOGLE_STORAGE"
      value = "${var.google_storage}"
    },
    {
      name  = "config.MAX_BACKUPS"
      value = "${var.max_backups}"
    },
    {
      name  = "config.CRON_SCHEDULE"
      value = "${var.cron_time}"
    },
    {
      name  = "config.INIT_BACKUP"
      value = "${var.init_backup}"
    },
    {
      name  = "config.INIT_RESTORE"
      value = "${var.init_restore}"
    },
    {
      name  = "config.RUN_AS_DAEMON"
      value = "${var.run_as_daemon}"
    },
    {
      name  = "volume.storageClass"
      value = "${var.storage_class}"
    },
    {
      name  = "volume.size"
      value = "${var.storage_size}"
    },
    {
      name  = "image.tag"
      value = "${var.image_tag}"
    }
  ]

  set_sensitive = []
}
