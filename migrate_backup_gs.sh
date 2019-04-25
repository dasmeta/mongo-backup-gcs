#!/usr/bin/env bash

NEWEST_BACKUP_FILE=$(ls -t /backup | head -1)
STORAGE=${GOOGLE_STORAGE}

if [[ -n "${NEWEST_BACKUP_FILE}" ]]; then
    echo "=> Compressing ${NEWEST_BACKUP_FILE} file"
    echo "=> The latest mongo dump is: ${NEWEST_BACKUP_FILE}"
    cd /backup
    zip -r /"${NEWEST_BACKUP_FILE}.zip" ./"${NEWEST_BACKUP_FILE}"
    cd /
    echo "=> Compression done!"
    echo "=> Migrating to Google Cloud Storage..."
    gcloud auth activate-service-account --key-file /*.json
    gsutil cp /${NEWEST_BACKUP_FILE}.zip gs://"${STORAGE}"/
    echo "=> Migration done!"
    echo "=> Removing zipped file from container"
    rm -f /"${NEWEST_BACKUP_FILE}.zip"
    echo "=> Removed!"
    echo "=> Removing backup file from /backup directory"
    rm -rf /backup/"${NEWEST_BACKUP_FILE}"
    echo "=> Removed!"
else
    echo "=> No backup file found.."
fi
