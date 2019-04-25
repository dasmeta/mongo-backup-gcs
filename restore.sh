#!/bin/bash

printenv > /etc/environment

PORT=${MONGODB_PORT:-27017}
HOST=${MONGODB_HOST:-""}


MONGODB_USER=${MONGO_INITDB_ROOT_USERNAME:-""}
MONGODB_PASS=${MONGO_INITDB_ROOT_PASSWORD:-""}

STORAGE=${GOOGLE_STORAGE}


#function mongo_user () {
#
#  cmd="
#if (!db.getUser('"${MONGO_INITDB_ROOT_USERNAME}"')) {
#    db.createUser({
#        user: '"${APP_MONGO_USER}"',
#        pwd: '"${APP_MONGO_PASS}"',
#        roles: [
#            {role: 'readWrite', db: '"$1"'}
#        ],
#        passwordDigestor: 'server',
#    })
#};
#"
#
#  echo ${cmd} > tmp_mongo_user.js
#  mongo --host ${MONGODB_HOST}\
#        --port ${MONGODB_PORT}\
#        -u ${MONGO_INITDB_ROOT_USERNAME}\
#        -p ${MONGO_INITDB_ROOT_PASSWORD}\
#        --authenticationDatabase admin \
#        $1 \
#        tmp_mongo_user.js
#  #rm -f tmp_mongo_user.js
#}

if [[ -n "${STORAGE}" ]]; then
    BACKUP_DIR="/restore"
    echo "=> Getting the newest backup file from Google Cloud Storage"
    gcloud auth activate-service-account --key-file /*.json
    gsutil cp $(gsutil ls gs://"${STORAGE}"/ | sort -r | head -n 1) ../
    BACKUP_FILE=$(ls -t /*.zip)
    echo "=> The newest backup is: ${BACKUP_FILE}"
    echo "=> Unzip backup file"
    unzip ${BACKUP_FILE} -d "${BACKUP_DIR}"/
    echo  "=> Removing zipped file"
    rm -f /"${BACKUP_FILE}.zip"
    echo "=> Restoring database from ${BACKUP_DIR}/${BACKUP_FILE}"
    RESTORE_DIR="${BACKUP_DIR}/$(ls -t /restore | head -1)"
else
    BACKUP_DIR="/backup"
    echo "=> GOOGLE_STORAGE variable was not set"
    echo "=> Searching in /backup directory..."
    BACKUP_FILE=$(ls -t "${BACKUP_DIR}"/)
    RESTORE_DIR="${BACKUP_DIR}/$(ls -t /${BACKUP_DIR} | head -1)"
fi

if [[ -n "${BACKUP_FILE}" ]]; then
    echo "=> The latest backup is:    ${BACKUP_FILE}"
    if mongorestore --host ${HOST} \
                    --port ${PORT} \
                    -u ${MONGODB_USER} \
                    -p ${MONGODB_PASS} \
                    --authenticationDatabase admin \
                    --drop \
                    ${RESTORE_DIR}; then
        echo "=> Restore succeeded"
    else
        echo "=> Restore failed"
        exit 2
    fi
else
    echo "=> ERROR:  No backup file found"
    exit 2
fi

#use admin
#db.createUser(
#  {
#    user: "root_username",
#    pwd: "very_secure_password",
#    roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
#  }
#)
