# About
The mongo_backup_gcs Docker image will provide you a container to backup and restore a Mongo database.
There is a possibility of the subsequent shipping to Google Cloud Storage.

# Usage
To backup a Mongo DB container you simply have to build Docker image from this source

[Visit our GitHub repository](https://github.com/fouraitch/mongo_backup_gcs.git)

    docker build -t image_name .
    
Please note the backup will be written to /backup by default, so you might want to mount that directory from your host.

## Useful example via docker compose

`IMPORTANT: `The Google Service account file (google-service-account.json) is required. You can create and/or download \
it in your [Credentials page.](https://console.developers.google.com/project/_/apiui/credential) or look at [official google docs](https://developers.google.com/android/management/service-account)

```
mongo_backup:
  build:
    context: .
  container_name: mongodb_backup_migrate
  volumes:
    - ./google-service-account.json:/google-service-account.json:ro
    - ./backup:/backup
  environment:
    MONGODB_HOST: host
    MONGODB_PORT: port
    MONGO_INITDB_ROOT_USERNAME: user
    MONGO_INITDB_ROOT_PASSWORD: password
    GOOGLE_STORAGE: google-storage-name
    MAX_BACKUPS: 30
    CRON_TIME: "0 0 * * *"
    INIT_BACKUP: 'false'
    INIT_RESTORE: 'false'
```
### Environment variables

#### `Note: Some variables are required` 
| Environment Variables | Description |
| ------ | ------ |
| `MONGODB_HOST` |(required) This is gonna be Mongo database Host name |
| `MONGODB_PORT` |(Optional) Mongo database host Port |
| `MONGO_INITDB_ROOT_USERNAME` |(required) Mongo database username |
| `MONGO_INITDB_ROOT_PASSWORD` |(required) Mongo database password |
| `GOOGLE_STORAGE` |(Optional) If storage variable is set the backups will be shipped/restored to/from Google Cloud Storage. `Otherwise It will be saved locally.`|
| `MAX_BACKUPS` | (Optional) Count of maximum backups on local machine. `Necessary if GOOGLE_STORAGE variable is not set. Default value is 30`|
| `CRON_TIME` | Please visit [CRON TIME](https://crontab.guru/) to choose your specific schedule time |
| `INIT_BACKUP` |(Optional) To make mongo backup on container startup mark value `true`. `Default is: 'false'`. If `GOOGLE_STORAGE` is set, the latest backup will be Shipped to cloud. Otherwise, database will be saved on local volume.|
| `INIT_RESTORE` |(Optional) To make mongo restore on container startup mark value `true`. `Default is: 'false'`. If `GOOGLE_STORAGE` is set, the latest backup will be downloaded from cloud. Otherwise, database will be restored from the local volume.|

It would be better to write environment variables in `.env` file.