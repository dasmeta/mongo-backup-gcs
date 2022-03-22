# About
The mongo_backup_gcs Docker image will provide you a container to backup and restore a Mongo database.
There is a possibility of the subsequent shipping to Google Cloud Storage.

# Usage
Backup a Mongo DB replica.

```
module "mongodb_backup" {
  source                      = ""
  google_service_account_json = base64encode(file("google-service-account.json"))
  google_storage              = "mongo-backup/"
  mongodb_uri                 = "mongodb://username:password@mongodb-host-name:27017/database?replicaSet=rs0&authSource=database"
  cron_time                   = "*/2 * * * *"
}
```
